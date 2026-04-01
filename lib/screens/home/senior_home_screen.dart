import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/matching_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';
import '../auth/login_screen.dart';
import 'job_detail_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';

class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  int _currentIndex = 0;

  void _goHome() => setState(() => _currentIndex = 0);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _JobListPage(),
      const SearchPage(isSenior: true),
      const _MatchingPage(),
      _ProfilePage(onGoHome: _goHome),
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
                  builder: (_) => const NotificationScreen(isSenior: true)),
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
              icon: Icon(Icons.work_outline), label: '공고'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined), label: '매칭'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '마이페이지'),
        ],
      ),
    );
  }
}

// ── 공고 리스트 ────────────────────────────────────────────
class _JobListPage extends StatefulWidget {
  const _JobListPage();

  @override
  State<_JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<_JobListPage> {
  final List<String> _allTags = [
    '#말벗', '#병원동행', '#강아지산책', '#장보기대행', '#아이돌봄', '#청소',
  ];
  String? _selectedTag;

  final List<Map<String, dynamic>> _jobs = [
    {
      'post_id': 'post-001',
      'title': '병원 동행 도와주세요',
      'content': '접수와 진료 동행을 부탁드려요.',
      'job_date': '2026-03-30',
      'start_time': '10:00',
      'location_name': '회기역 근처 내과',
      'reward': 25000,
      'requesterName': '김민지',
      'requesterGender': '여성',
      'phone': '010-2222-3333',
      'category_tag': '#병원동행',
      'tags': ['#병원동행', '#말벗'],
      'status': 'OPEN',
    },
    {
      'post_id': 'post-002',
      'title': '강아지 산책 부탁드려요',
      'content': '30분 단지 산책을 부탁드립니다.',
      'job_date': '2026-03-31',
      'start_time': '16:00',
      'location_name': '휘경동 아파트 단지',
      'reward': 15000,
      'requesterName': '박소연',
      'requesterGender': '여성',
      'phone': '010-4444-5555',
      'category_tag': '#강아지산책',
      'tags': ['#강아지산책', '#말벗'],
      'status': 'OPEN',
    },
    {
      'post_id': 'post-003',
      'title': '장보기와 반찬 정리 도와주세요',
      'content': '마트 장보기 + 냉장고 정리를 부탁드려요.',
      'job_date': '2026-04-01',
      'start_time': '14:00',
      'location_name': '이문동 자택',
      'reward': 20000,
      'requesterName': '이수정',
      'requesterGender': '여성',
      'phone': '010-8888-9999',
      'category_tag': '#장보기대행',
      'tags': ['#장보기대행', '#청소'],
      'status': 'OPEN',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTag == null) return _jobs;
    return _jobs
        .where((j) =>
            ((j['tags'] as List?)?.cast<String>() ?? [])
                .contains(_selectedTag))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const Text('태그를 눌러\n공고를 찾아보세요',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, height: 1.3)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _allTags.map((tag) {
              final sel = _selectedTag == tag;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedTag = sel ? null : tag),
                  child: TagChip(label: tag, highlighted: sel),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        if (_filtered.isEmpty)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(40),
            child: Text('해당 태그의 공고가 없어요',
                style: TextStyle(color: AppColors.subText)),
          ))
        else
          ..._filtered.map((job) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _JobCard(post: job),
              )),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _JobCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final tags = (post['tags'] as List?)?.cast<String>() ?? [];
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => JobDetailScreen(post: post, isSenior: true)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 16,
                offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['title'] ?? '',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  tags.take(3).map((t) => TagChip(label: t)).toList(),
            ),
            const SizedBox(height: 14),
            _Line(Icons.access_time_rounded,
                '${post['job_date'] ?? ''} / ${post['start_time'] ?? ''}'),
            const SizedBox(height: 6),
            _Line(Icons.place_outlined, post['location_name'] ?? ''),
            const SizedBox(height: 6),
            _Line(Icons.payments_outlined, '${post['reward'] ?? 0}원'),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Line(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }
}

// ── 매칭 페이지 ────────────────────────────────────────────
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
        const Text('매칭된 일거리',
            style:
                TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary))
        else if (_matched.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 56, color: AppColors.border),
                  const SizedBox(height: 16),
                  const Text('매칭된 일거리가 없어요',
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline,
                        color: AppColors.primary),
                  ),
                  title: Text(
                      match['post_id']?.toString() ?? '매칭된 공고',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800)),
                  subtitle: Text('상태: ${match['status'] ?? ''}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(
                        post: match,
                        showTerminateButton: true,
                        isSenior: true,
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
class _ProfilePage extends StatefulWidget {
  final VoidCallback onGoHome;
  const _ProfilePage({required this.onGoHome});

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isEditing = false;

  final _bioController = TextEditingController();
  final _nameController = TextEditingController();
  int _selectedIconIndex = 0;

  final _icons = [
    Icons.favorite_rounded,
    Icons.park_rounded,
    Icons.pets_rounded,
    Icons.child_care_rounded,
    Icons.restaurant_rounded,
    Icons.local_hospital_outlined,
    Icons.directions_walk_rounded,
    Icons.shopping_basket_outlined,
  ];

  final _colors = [
    AppColors.primary,
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
  ];
  int _selectedColorIndex = 0;

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
        _bioController.text = res.data?['bio_summary'] ?? '';
        _nameController.text = res.data?['name'] ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    await AuthService.updateMe({
      'name': _nameController.text,
      'bio_summary': _bioController.text,
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

    final tags =
        (_profile?['tags'] as List?)?.cast<String>() ?? ['#말벗', '#병원동행'];
    final name = _profile?['name'] ?? '시니어';
    final score = _profile?['trust_score'] ?? 50;
    final cardColor = _colors[_selectedColorIndex];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 프로필 카드
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(_icons[_selectedIconIndex],
                        size: 58, color: cardColor),
                  ),
                  if (_isEditing)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconIndex =
                              (_selectedIconIndex + 1) % _icons.length;
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x20000000),
                                blurRadius: 6)
                          ],
                        ),
                        child: Icon(Icons.refresh,
                            size: 16, color: cardColor),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  : Text(name,
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: tags.map((t) => TagChip(label: t)).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 카드 색상 선택
        if (_isEditing) ...[
          const Text('카드 색상',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_colors.length, (i) {
              final sel = _selectedColorIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _colors[i],
                    shape: BoxShape.circle,
                    border: sel
                        ? Border.all(
                            color: AppColors.text, width: 3)
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // 아이콘 선택
          const Text('아이콘 선택',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_icons.length, (i) {
              final sel = _selectedIconIndex == i;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedIconIndex = i),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel
                            ? AppColors.primary
                            : AppColors.border),
                  ),
                  child: Icon(_icons[i],
                      color:
                          sel ? Colors.white : AppColors.subText),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
        ],

        // 한줄 소개
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('한줄 소개',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            TextButton(
              onPressed: () =>
                  setState(() => _isEditing = !_isEditing),
              child: Text(_isEditing ? '취소' : '수정',
                  style:
                      const TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _isEditing
            ? TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: '자신을 소개하는 문구를 적어보세요'),
              )
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _bioController.text.isEmpty
                      ? '소개를 입력해주세요'
                      : _bioController.text,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5),
                ),
              ),

        const SizedBox(height: 24),

        // 활동 태그
        const Text('활동 태그',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map((t) => TagChip(label: t, highlighted: true))
              .toList(),
        ),

        const SizedBox(height: 24),

        // 배지
        const Text('획득한 배지',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(label: '🏆 친절왕'),
            TagChip(label: '⏰ 시간엄수'),
            TagChip(label: '💬 말벗전문'),
          ],
        ),

        const SizedBox(height: 28),

        if (_isEditing)
          AppButton(text: '저장하기', onTap: _saveProfile)
        else ...[
          AppButton(
            text: '로그아웃',
            filled: false,
            onTap: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}