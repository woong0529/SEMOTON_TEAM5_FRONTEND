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
      _RecommendPage(onGoToPost: () => setState(() => _currentIndex = 1)),
      const _PostCreatePage(),
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
class _RecommendPage extends StatefulWidget {
  final VoidCallback onGoToPost;
  const _RecommendPage({required this.onGoToPost});

  @override
  State<_RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<_RecommendPage> {
  int _cardIndex = 0;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _myPosts = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _seniors = [
    {
      'user_id': 'senior-001',
      'name': '최재철',
      'trust_score': 86,
      'bio_summary': '아이 돌봄과 반려동물 케어에 자신 있어요',
      'tags': ['#강아지산책', '#병원동행', '#말벗'],
      'gender': '남성',
    },
    {
      'user_id': 'senior-002',
      'name': '이순자',
      'trust_score': 91,
      'bio_summary': '청소와 장보기, 말벗을 잘 할 수 있어요',
      'tags': ['#청소', '#장보기대행', '#말벗'],
      'gender': '여성',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profileRes = await AuthService.getMe();
    final postsRes = await JobService.getMyJobs();
    if (mounted) {
      setState(() {
        _profile = profileRes.data;
        _myPosts = postsRes.data ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final nickname = _profile?['nickname'] ?? '요청자';

    // 공고가 없으면 안내 화면
    if (_myPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.edit_document,
                    size: 52, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                '공고를 먼저 작성해주세요!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '공고를 등록하면\n딱 맞는 시니어를 추천해드려요',
                style: TextStyle(
                    fontSize: 15,
                    color: AppColors.subText,
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: '공고 작성하러 가기',
                onTap: widget.onGoToPost,
              ),
            ],
          ),
        ),
      );
    }

    final senior = _seniors[_cardIndex % _seniors.length];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$nickname님께\n추천 시니어예요',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3)),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: GestureDetector(
                onHorizontalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -300) {
                    setState(() => _cardIndex++);
                  } else if ((d.primaryVelocity ?? 0) > 300) {
                    _proposeMatch(context, senior);
                  }
                },
                child: _SeniorCard(
                  senior: senior,
                  onSkip: () => setState(() => _cardIndex++),
                  onPropose: () => _proposeMatch(context, senior),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('← 넘기기   |   제안하기 →',
                style: TextStyle(fontSize: 13, color: AppColors.subText)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _proposeMatch(BuildContext context, Map<String, dynamic> senior) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('매칭 제안'),
        content: Text('${senior['name']}님께 매칭을 제안할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final postId = _myPosts.isNotEmpty
                  ? _myPosts.first['post_id']?.toString() ?? 'post-001'
                  : 'post-001';
              await MatchingService.proposeMatch(
                postId: postId,
                seniorId: senior['user_id'] as String,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${senior['name']}님께 제안했어요')),
                );
              }
            },
            child: const Text('제안하기'),
          ),
        ],
      ),
    );
  }
}

class _SeniorCard extends StatelessWidget {
  final Map<String, dynamic> senior;
  final VoidCallback onSkip;
  final VoidCallback onPropose;
  const _SeniorCard(
      {required this.senior, required this.onSkip, required this.onPropose});

  @override
  Widget build(BuildContext context) {
    final tags = (senior['tags'] as List?)?.cast<String>() ?? [];
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
              color: Color(0x30FF6B4A),
              blurRadius: 24,
              offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.person, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(senior['name'] as String,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('신뢰 점수 ${senior['trust_score']}점',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(senior['bio_summary'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: tags.map((t) => TagChip(label: t)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('넘기기'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPropose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('제안하기',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 공고 작성 ──────────────────────────────────────────────
class _PostCreatePage extends StatefulWidget {
  const _PostCreatePage();

  @override
  State<_PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<_PostCreatePage> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _rewardController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = '#병원동행';
  bool _isSubmitting = false;

  final List<String> _categories = [
    '#집밥제조', '#장보기대행', '#청소', '#병원동행', '#말벗',
    '#강아지산책', '#아이돌봄', '#관공서동행',
  ];

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
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
      locationName: _locationController.text.isEmpty
          ? '미정'
          : _locationController.text,
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
      _locationController.clear();
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
          TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: '위치')),
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