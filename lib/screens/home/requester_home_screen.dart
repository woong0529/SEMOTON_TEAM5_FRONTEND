import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/matching_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';
import '../auth/login_screen.dart';
import 'job_detail_screen.dart';
import 'notification_screen.dart';
import '../common/job_location_screen.dart';
import '../../utils/place_model.dart';
import 'recommend_screen.dart';

class RequesterHomeScreen extends StatefulWidget {
  const RequesterHomeScreen({super.key});

  @override
  State<RequesterHomeScreen> createState() => _RequesterHomeScreenState();
}

class _RequesterHomeScreenState extends State<RequesterHomeScreen> {
  int _currentIndex = 0;

  void _goHome() => setState(() => _currentIndex = 0);

  @override
  Widget build(BuildContext context) {
    final pages = [
      SeniorSearchPage(onGoToPost: () => setState(() => _currentIndex = 1)),
      const PostCreatePage(),
      const _MatchingPage(),
      _MyPage(onGoHome: _goHome),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: GestureDetector(
          onTap: _goHome,
          child: Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              const Text('SEE:NEAR',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.1)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationScreen(isSenior: false)),
            ),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subText,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: '추천'),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit_document), label: '공고 작성'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined), label: '매칭'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '마이페이지'),
        ],
      ),
    );
  }
}

// ── 추천 페이지 ────────────────────────────────────────────
class SeniorSearchPage extends StatefulWidget {
  const SeniorSearchPage({required this.onGoToPost, super.key});
  final VoidCallback onGoToPost;

  @override
  State<SeniorSearchPage> createState() => _SeniorSearchPageState();
}

class _SeniorSearchPageState extends State<SeniorSearchPage> {
  // 상태 관리 변수
  String _selectedGender = '전체'; // 기본값 '전체'
  String? _selectedCategory; // 선택된 카테고리 (없을 수 있음)

  final List<String> _genders = ['전체', '남성', '여성'];
  final List<String> _categories = ['말벗', '산책', '병원동행', '식사보조', '운동', '등산'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          '시니어 검색',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // 기존 추천 페이지로 이동하는 버튼
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecommendScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.blueAccent,
              ),
              label: const Text(
                'AI 추천',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 성별 선택 섹션
            const Text(
              '성별',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: _genders.map((gender) {
                final isSel = _selectedGender == gender;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGender = gender),
                  child: TagChip(label: gender, highlighted: isSel),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // 2. 카테고리 선택 섹션
            const Text(
              '카테고리',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // 이미 선택된 걸 누르면 해제, 아니면 선택
                      _selectedCategory = isSel ? null : cat;
                    });
                  },
                  child: TagChip(label: cat, highlighted: isSel),
                );
              }).toList(),
            ),

            const Spacer(),

            // 3. 검색 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  print('🔍 검색: 성별=$_selectedGender, 카테고리=$_selectedCategory');
                  // 여기에 API 호출 로직 추가 (필터 데이터 전달)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '검색하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 공고 작성 ──────────────────────────────────────────────
class PostCreatePage extends StatefulWidget {
  const PostCreatePage();

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  PlaceModel? _selectedLocation;
  final _rewardController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = '#병원동행';
  bool _isSubmitting = false;

  final List<String> _categories = [
    '#집밥제조', '#장보기대행', '#청소', '#병원동행', '#말벗',
    '#강아지산책', '#아이돌봄', '#관공서동행',
  ];

  Future<void> _selectLocation() async {
    final selected = await Navigator.push<PlaceModel>(
      context,
      MaterialPageRoute(builder: (_) => const JobLocationPicker()),
    );
    if (selected != null) {
      setState(() => _selectedLocation = selected);
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치를 선택해주세요')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final res = await JobService.createJob(
      title: _titleController.text,
      content: _contentController.text,
      categoryTag: _selectedCategory,
      jobDate: _dateController.text.isEmpty
          ? DateTime.now().toIso8601String().substring(0, 10)
          : _dateController.text,
      startTime: _timeController.text.isEmpty
          ? '09:00:00'
          : '${_timeController.text}:00',
      locationName: _selectedLocation!.name,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      reward: int.tryParse(_rewardController.text) ?? 0,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(res.success ? '공고가 등록되었어요' : res.error ?? '등록 실패')),
    );
    if (res.success) {
      _titleController.clear();
      _contentController.clear();
      _selectedLocation = null;
      _rewardController.clear();
      _dateController.clear();
      _timeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('도움받기\n공고 작성',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3)),
          const SizedBox(height: 20),
          TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목')),
          const SizedBox(height: 12),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
                labelText: '날짜', hintText: '2026-04-01'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timeController,
            decoration: const InputDecoration(
                labelText: '시작 시간', hintText: '14:00'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _selectLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.place),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLocation?.name ?? '위치 선택',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rewardController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '보수 (원)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '구체적인 요청 사항',
              hintText: '어떤 도움이 필요한지 자세히 적어주세요',
            ),
          ),
          const SizedBox(height: 20),
          const Text('카테고리 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _categories.map((cat) {
              final sel = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: TagChip(label: cat, highlighted: sel),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: _isSubmitting ? '등록 중...' : '공고 등록',
            onTap: _isSubmitting ? () {} : _submit,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── 매칭 조회 ──────────────────────────────────────────────
class _MatchingPage extends StatefulWidget {
  const _MatchingPage();

  @override
  State<_MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<_MatchingPage> {
  List<Map<String, dynamic>> _matched = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await MatchingService.getActiveMatches();
    if (mounted) {
      setState(() {
        _matched = res.data ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('매칭 조회',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
        else if (_matched.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 56, color: AppColors.border),
                  const SizedBox(height: 16),
                  const Text('진행 중인 매칭이 없어요',
                      style: TextStyle(color: AppColors.subText)),
                ],
              ),
            ),
          )
        else
          ..._matched.map((match) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 14,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.handshake_outlined,
                        color: AppColors.primary),
                  ),
                  title: Text(
                      match['post_id']?.toString() ?? '매칭된 공고',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('상태: ${match['status'] ?? ''}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(
                        post: match,
                        showDecisionButtons: true,
                        isSenior: false,
                        matchId: match['match_id']?.toString(),
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

// ── 마이페이지 ─────────────────────────────────────────────
class _MyPage extends StatefulWidget {
  final VoidCallback onGoHome;
  const _MyPage({required this.onGoHome});

  @override
  State<_MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<_MyPage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nicknameController = TextEditingController();
  final _birthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final res = await AuthService.getMe();
    if (mounted) {
      setState(() {
        _profile = res.data;
        _nicknameController.text = res.data?['nickname'] ?? '';
        _birthController.text = res.data?['birth_year']?.toString() ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    await AuthService.updateMe({
      'nickname': _nicknameController.text,
      'birth_year': int.tryParse(_birthController.text) ?? 1990,
    });
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었어요')),
      );
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final nickname = _profile?['nickname'] ?? '요청자';
    final score = _profile?['trust_score'] ?? 50;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 프로필 카드
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFF8C6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person,
                    size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              Text(nickname,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('신뢰 점수 $score점',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('내 정보',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            TextButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              child: Text(_isEditing ? '취소' : '수정',
                  style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _InfoField(
                label: '닉네임',
                controller: _nicknameController,
                isEditing: _isEditing,
              ),
              const Divider(height: 24),
              _InfoField(
                label: '출생연도',
                controller: _birthController,
                isEditing: _isEditing,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text('내가 올린 공고',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _MyPostsList(),

        const SizedBox(height: 24),

        if (_isEditing)
          AppButton(text: '저장하기', onTap: _saveProfile)
        else
          AppButton(
            text: '로그아웃',
            filled: false,
            onTap: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType keyboardType;

  const _InfoField({
    required this.label,
    required this.controller,
    required this.isEditing,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.subText,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: isEditing
              ? TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                )
              : Text(controller.text,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _MyPostsList extends StatefulWidget {
  @override
  State<_MyPostsList> createState() => _MyPostsListState();
}

class _MyPostsListState extends State<_MyPostsList> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await JobService.getMyJobs();
    if (mounted) {
      setState(() {
        _posts = res.data ?? [];
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'OPEN': return AppColors.primary;
      case 'MATCHED': return AppColors.success;
      default: return AppColors.subText;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_posts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text('등록한 공고가 없어요',
              style: TextStyle(color: AppColors.subText)),
        ),
      );
    }
    return Column(
      children: _posts
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(item['title'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(item['status'] as String? ?? '')
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status'] as String? ?? '',
                        style: TextStyle(
                          color: _statusColor(
                              item['status'] as String? ?? ''),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}