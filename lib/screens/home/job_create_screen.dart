import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/job_service.dart';
import '../../widgets/app_button.dart';
import 'package:intl/intl.dart';

class JobCreateScreen extends StatefulWidget {
  final VoidCallback onSuccess; // 등록 성공 시 호출할 함수
  const JobCreateScreen({super.key, required this.onSuccess});

  @override
  State<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends State<JobCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _rewardController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<String> _recommendedMainTags = [];
  List<String> _recommendedSubTags = [];
  List<String> _selectedSubTags = [];

  bool _isAnalyzing = false; // AI 분석 상태
  bool _isSubmitting = false; // 최종 등록 상태
  bool _showDetails = false; // 분석 완료 후 상세 입력 노출 여부

  // ... (날짜/시간 선택 함수는 기존과 동일) ...

  // 캘린더 날짜 선택
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // 다이얼 시간 선택
  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // 1단계: AI 태그 추천 호출
  Future<void> _analyzeTags() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목과 내용을 먼저 입력해주세요.')));
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    final res = await JobService.getRecommendedTags(
      title: _titleController.text,
      content: _contentController.text,
    );

    if (res.success && res.data != null) {
      setState(() {
        _recommendedMainTags = List<String>.from(
          res.data!['recommended_main_tags'],
        );
        _recommendedSubTags = List<String>.from(
          res.data!['recommended_sub_tags'],
        );
        _selectedSubTags = List.from(_recommendedSubTags); // 초기값은 전체 선택
        _showDetails = true; // 상세 입력란 노출
      });
    }
    setState(() => _isAnalyzing = false);
  }

  // 2단계: 최종 공고 등록
  Future<void> _submitJob() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedSubTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목(날짜, 시간, 태그)을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await JobService.createJob(
      title: _titleController.text,
      content: _contentController.text,
      mainTags: _recommendedMainTags,
      subTags: _selectedSubTags,
      jobDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      startTime:
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
      locationName: "서울특별시 용인시 (임시)",
      latitude: 37.1234,
      longitude: 127.1234,
      reward: int.tryParse(_rewardController.text) ?? 0,
    );
    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('공고가 성공적으로 등록되었습니다!')));
      widget.onSuccess(); // 홈 화면의 인덱스를 0으로 바꿔주는 함수 실행

      // 등록 성공 후 추천 탭으로 강제 이동시키거나 화면을 새로고침하는 로직
      // 예: 상위 HomeScreen의 탭을 0번으로 변경하는 콜백 호출 등
    } else {
      // 실패 시 에러 메시지 처리
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('등록 실패: ${res.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('공고 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [입력 섹션 1] 제목 및 내용
            _buildInputLabel("무엇을 도와드리면 될까요?"),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "제목을 입력하세요"),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            _buildInputLabel("구체적인 요청사항"),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "AI가 이 내용을 분석하여 태그를 추천해드려요.",
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 20),

            // [버튼 1] AI 분석 버튼
            if (!_showDetails)
              AppButton(
                text: _isAnalyzing ? 'AI 분석 중...' : '내용 분석 및 태그 추천받기',
                onTap: _isAnalyzing ? () {} : () => _analyzeTags(),
              ),

            // [입력 섹션 2] 분석 결과 및 상세 입력 (분석 완료 시에만 등장)
            if (_showDetails) ...[
              const Divider(height: 40),
              _buildInputLabel("추천된 태그 (클릭해서 선택)"),
              Wrap(
                spacing: 8,
                children: _recommendedSubTags.map((tag) {
                  final isSelected = _selectedSubTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        val
                            ? _selectedSubTags.add(tag)
                            : _selectedSubTags.remove(tag);
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              _buildInputLabel("언제 방문하면 될까요?"),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _selectedDate == null
                            ? "날짜 선택"
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _selectedTime == null
                            ? "시간 선택"
                            : _selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildInputLabel("보수 (원)"),
              TextField(
                controller: _rewardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: "원",
                  hintText: "예: 10000",
                ),
              ),
              const SizedBox(height: 40),

              // [버튼 2] 최종 등록 버튼
              AppButton(
                text: _isSubmitting ? "공고 등록 중..." : "공고 등록하기",
                onTap: _isSubmitting ? () {} : () => _submitJob(),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _showDetails = false),
                  child: const Text("내용 수정하기"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
