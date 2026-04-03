import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';
import '../common/location_select_screen.dart';
import '../home/senior_home_screen.dart';
import '../../utils/place_model.dart';

class SeniorSignupScreen extends StatefulWidget {
  const SeniorSignupScreen({super.key});

  @override
  State<SeniorSignupScreen> createState() => _SeniorSignupScreenState();
}

class _SeniorSignupScreenState extends State<SeniorSignupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  String _authCode = '';
  String _name = '';
  String _gender = '남';
  int _birthYear = 1960;
  String _phone = '';
  String _town = '자주 가는 위치를 지정해주세요';
  List<PlaceModel> _selectedPlaces = []; // 백엔드 전송용 리스트 추가
  String _strengthText = '';
  List<String> _aiTags = [];
  bool _isGeneratingTags = false;
  bool _isSubmitting = false;

  void _next() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage++);
  }

  void _prev() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage--);
  }

  Future<void> _generateTags(String phone, String text) async {
    _phone = phone;
    _strengthText = text;
    setState(() => _isGeneratingTags = true);
    await Future.delayed(const Duration(seconds: 2));
    final tags = <String>[];
    final lower = text.toLowerCase();
    if (lower.contains('병원') || lower.contains('동행')) tags.add('#병원동행');
    if (lower.contains('말벗') || lower.contains('대화')) tags.add('#말벗');
    if (lower.contains('청소') || lower.contains('정리')) tags.add('#청소');
    if (lower.contains('장보') || lower.contains('마트')) tags.add('#장보기대행');
    if (lower.contains('강아지') || lower.contains('산책')) tags.add('#강아지산책');
    if (lower.contains('아이') || lower.contains('돌봄')) tags.add('#아이돌봄');
    if (lower.contains('요리') || lower.contains('반찬')) tags.add('#집밥제조');
    if (tags.isEmpty) tags.addAll(['#말벗', '#병원동행']);
    setState(() {
      _aiTags = tags;
      _isGeneratingTags = false;
    });
    _next();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final locationsData = _selectedPlaces.map((p) => {
      'location_name': p.name,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'is_primary': p.isPrimary,
    }).toList();

    final finalLocations = locationsData.isNotEmpty 
      ? locationsData 
      : [{
          'location_name': '기본 거점',
          'latitude': 37.5665,
          'longitude': 126.9780,
          'is_primary': true,
        }];

    final res = await AuthService.signupSenior(
      phoneNumber: _phone,
      name: _name,
      gender: _gender,
      birthYear: _birthYear,
      authCode: _authCode,
      tags: _aiTags,
      bioSummary: _strengthText,
      locations: finalLocations,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (res.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SeniorHomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? '가입 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _currentPage, total: 6),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepAuthCode(
                      onNext: (code) { _authCode = code; _next(); }),
                  _StepName(
                      onNext: (name) { _name = name; _next(); },
                      onBack: _prev),
                  _StepGender(
                      selected: _gender,
                      onNext: (g) { _gender = g; _next(); },
                      onBack: _prev),
                  _StepBirthYear(
                      onNext: (y) { _birthYear = y; _next(); },
                      onBack: _prev),
                  _StepLocation(
                    town: _town,
                    onLocationChanged: (List<PlaceModel> places) {
                      setState(() {
                        _selectedPlaces = places;
                        if (places.isNotEmpty) {
                          final primary = places.firstWhere((p) => p.isPrimary, orElse: () => places.first);
                          _town = places.length > 1 ? "${primary.name} 외 ${places.length - 1}곳" : primary.name;
                        } else {
                          _town = '';
                        }
                      });
                    },
                    onNext: _next,
                    onBack: _prev,
                  ),
                  _StepStrength(
                    onNext: _generateTags,
                    onBack: _prev,
                    isLoading: _isGeneratingTags,
                  ),
                  _StepPreview(
                    name: _name,
                    gender: _gender,
                    birthYear: _birthYear,
                    town: _town,
                    tags: _aiTags,
                    onSubmit: _submit,
                    onBack: _prev,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: List.generate(
          total,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepWrapper extends StatelessWidget {
  final Widget child;
  const _StepWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 160,
        child: child,
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String text;
  const _StepTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: AppColors.text,
      ),
    );
  }
}

// Step 0: 복지관 코드
class _StepAuthCode extends StatefulWidget {
  final void Function(String) onNext;
  const _StepAuthCode({required this.onNext});

  @override
  State<_StepAuthCode> createState() => _StepAuthCodeState();
}

class _StepAuthCodeState extends State<_StepAuthCode> {
  final _controller = TextEditingController(text: 'SEMO-2026');

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('복지관 코드를\n입력해주세요'),
          const SizedBox(height: 8),
          const Text(
            '복지관에서 받은 고유 코드를 입력해주세요',
            style: TextStyle(fontSize: 14, color: AppColors.subText),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'SEMO-2026'),
          ),
          const Spacer(),
          AppButton(
            text: '다음',
            onTap: () {
              if (_controller.text.trim().isEmpty) return;
              widget.onNext(_controller.text.trim());
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Step 1: 이름
class _StepName extends StatefulWidget {
  final void Function(String) onNext;
  final VoidCallback onBack;
  const _StepName({required this.onNext, required this.onBack});

  @override
  State<_StepName> createState() => _StepNameState();
}

class _StepNameState extends State<_StepName> {
  final _controller = TextEditingController();
  bool _isListening = false;
  late stt.SpeechToText _speech;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening' && _isListening) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
      },
    );
    if (!mounted) return;
    setState(() {});
  }

  void _toggleListening() async {
    if (!_speechEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다. 설정에서 허용해주세요.')),
        );
      }
      return;
    }
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isListening = true);
    await _speech.listen(
      localeId: 'ko_KR',
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('이름을\n입력해주세요'),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '홍길동',
              suffixIcon: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: _toggleListening,
              ),
            ),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(text: '이전', filled: false, onTap: widget.onBack)),
            const SizedBox(width: 12),
            Expanded(child: AppButton(text: '다음', onTap: () {
              if (_controller.text.trim().isEmpty) return;
              widget.onNext(_controller.text.trim());
            })),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Step 2: 성별
class _StepGender extends StatefulWidget {
  final String selected;
  final void Function(String) onNext;
  final VoidCallback onBack;
  const _StepGender(
      {required this.selected, required this.onNext, required this.onBack});

  @override
  State<_StepGender> createState() => _StepGenderState();
}

class _StepGenderState extends State<_StepGender> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('성별을\n선택해주세요'),
          const SizedBox(height: 36),
          Row(
            children: ['남', '여'].map((g) {
              final sel = _selected == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = g),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    height: 60,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: Text(g,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: sel ? Colors.white : AppColors.text,
                          )),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(text: '이전', filled: false, onTap: widget.onBack)),
            const SizedBox(width: 12),
            Expanded(child: AppButton(text: '다음', onTap: () => widget.onNext(_selected))),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Step 3: 생년월일
class _StepBirthYear extends StatefulWidget {
  final void Function(int) onNext;
  final VoidCallback onBack;
  const _StepBirthYear({required this.onNext, required this.onBack});

  @override
  State<_StepBirthYear> createState() => _StepBirthYearState();
}

class _StepBirthYearState extends State<_StepBirthYear> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('생년월일을\n입력해주세요'),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '예: 19650712'),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(text: '이전', filled: false, onTap: widget.onBack)),
            const SizedBox(width: 12),
            Expanded(child: AppButton(text: '다음', onTap: () {
              final text = _controller.text.trim();
              if (text.length < 4) return;
              final year = int.tryParse(text.substring(0, 4));
              if (year == null) return;
              widget.onNext(year);
            })),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Step 4: 위치 선택
class _StepLocation extends StatefulWidget {
  final String town;
  final void Function(List<PlaceModel>) onLocationChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _StepLocation({
    required this.town,
    required this.onLocationChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<_StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<_StepLocation> {

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('자주 활동하는\n위치를 알려주세요'),
          const SizedBox(height: 8),
          const Text(
            '공고 추천에 활용돼요',
            style: TextStyle(fontSize: 14, color: AppColors.subText),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: widget.town,
            filled: false,
            onTap: () async {
              final List<PlaceModel>? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LocationSelectionScreen(),
                ),
              );
              if (result != null && result.isNotEmpty) {
                setState(() {
                  widget.onLocationChanged(result);
                });
              }
            },
          ),
          const SizedBox(height: 12),
          if (widget.town != '자주 가는 위치를 지정해주세요')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.town,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(text: '이전', filled: false, onTap: widget.onBack)),
            const SizedBox(width: 12),
            Expanded(child: AppButton(text: '다음', onTap: widget.onNext)),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Step 5: 강점 입력
class _StepStrength extends StatefulWidget {
  final void Function(String phone, String text) onNext;
  final VoidCallback onBack;
  final bool isLoading;
  const _StepStrength(
      {required this.onNext, required this.onBack, required this.isLoading});

  @override
  State<_StepStrength> createState() => _StepStrengthState();
}

class _StepStrengthState extends State<_StepStrength> {
  final _phoneController = TextEditingController();
  final _textController = TextEditingController();
  bool _isListening = false;
  late stt.SpeechToText _speech;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening' && _isListening) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
      },
    );
    if (!mounted) return;
    setState(() {});
  }

  void _toggleListening() async {
    if (!_speechEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다. 설정에서 허용해주세요.')),
        );
      }
      return;
    }
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isListening = true);
    await _speech.listen(
      localeId: 'ko_KR',
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    _phoneController.dispose();
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('전화번호와\n강점을 알려주세요'),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                labelText: '전화번호', hintText: '010-1234-5678'),
          ),
          const SizedBox(height: 20),
          const Text('어떤 일을 잘 하시나요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('AI가 자동으로 태그를 만들어드려요',
              style: TextStyle(fontSize: 14, color: AppColors.subText)),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '예: 아이와 잘 놀아주고, 병원 동행도 꼼꼼하게 할 수 있어요',
              suffixIcon: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: _toggleListening,
              ),
            ),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(text: '이전', filled: false, onTap: widget.onBack)),
            const SizedBox(width: 12),
            Expanded(
              child: widget.isLoading
                  ? Container(
                      height: 60,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text('AI 분석 중...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  : AppButton(
                      text: '태그 생성',
                      onTap: () {
                        final phone = _phoneController.text.trim();
                        final text = _textController.text.trim();
                        if (phone.isEmpty || text.isEmpty) return;
                        widget.onNext(phone, text);
                      },
                    ),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Step 6: 프로필 미리보기
class _StepPreview extends StatelessWidget {
  final String name;
  final String gender;
  final int birthYear;
  final String town;
  final List<String> tags;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final bool isLoading;

  const _StepPreview({
    required this.name,
    required this.gender,
    required this.birthYear,
    required this.town,
    required this.tags,
    required this.onSubmit,
    required this.onBack,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('AI 태그를\n만들었어요'),
          const SizedBox(height: 8),
          const Text('아래 프로필로 공고를 추천받게 돼요',
              style: TextStyle(fontSize: 15, color: AppColors.subText)),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.person,
                      size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('$gender · $birthYear년생',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                if (town.isNotEmpty &&
                    town != '자주 가는 위치를 지정해주세요') ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.place_outlined,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(town,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: tags.map((t) => TagChip(label: t)).toList(),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(text: '이전', filled: false, onTap: onBack)),
            const SizedBox(width: 12),
            Expanded(child: AppButton(
                text: isLoading ? '가입 중...' : '가입 완료',
                onTap: isLoading ? () {} : onSubmit)),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}