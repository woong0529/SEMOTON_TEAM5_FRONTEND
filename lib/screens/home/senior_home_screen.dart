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
import '../../services/location_service.dart';
import '../common/location_edit_screen.dart';
import '../../services/job_service.dart';

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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SEE:NEAR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationScreen(isSenior: true),
              ),
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
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: '공고'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: '매칭',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '마이페이지',
          ),
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
  // 제공해주신 TAGS_DATA 반영
  final List<Map<String, dynamic>> _tagsData = [
    {"main": "전체", "sub": []}, // 전체 보기 추가
    {
      "main": "가사 및 환경 관리",
      "sub": [
        "#집밥제조",
        "#밑반찬",
        "#장보기대행",
        "#냉장고정리",
        "#부분청소",
        "#분리수거",
        "#헌옷수거",
        "#단줄이기",
      ],
    },
    {
      "main": "동행 및 돌봄",
      "sub": [
        "#강아지산책",
        "#고양이케어",
        "#등하원픽업",
        "#놀이학습",
        "#병원동행",
        "#관공서동행",
        "#말벗",
        "#산책친구",
      ],
    },
    {
      "main": "운반 및 심부름",
      "sub": [
        "#짐들어주기",
        "#택배수령",
        "#약배달",
        "#줄서기",
        "#번호표뽑기",
        "#꽃물주기",
        "#우편물수거",
        "#무거운짐",
      ],
    },
    {
      "main": "전문 기술 및 노하우",
      "sub": [
        "#형광등교체",
        "#수전교체",
        "#가구조립",
        "#한자교육",
        "#서예",
        "#전통요리전수",
        "#화초관리",
        "#뜨개질",
      ],
    },
    {
      "main": "비즈니스 지원",
      "sub": ["#전단지배포", "#매장지키기", "#단기알바", "#포장작업", "#주차안내", "#행사보조"],
    },
  ];

  String _selectedMain = "전체";
  String _selectedGender = "전체";
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    try {
      final res = await JobService.getRecommendedJobs();
      if (mounted) {
        setState(() {
          _jobs = res.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 필터링 로직
  List<dynamic> get _filtered {
    return _jobs.where((j) {
      // 1. 대분류 필터 (main_tags에 포함되어 있는지 확인)
      bool matchMain = _selectedMain == "전체";
      if (!matchMain) {
        final List mainTags = j['main_tags'] ?? [];
        matchMain = mainTags.contains(_selectedMain);
      }

      // 2. 성별 필터
      bool matchGender = _selectedGender == "전체";
      if (!matchGender) {
        matchGender = (j['gender_limit'] == _selectedGender);
      }

      return matchMain && matchGender;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchJobs,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const Text(
            '근처에 도움을\n기다리는 분들이에요',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          // --- 필터 섹션 ---
          _buildFilterSection(),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (_filtered.isEmpty)
            _buildEmptyState()
          else
            ..._filtered.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _JobCard(post: job),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 성별 선택 (가독성 높은 탭 스타일)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: ['전체', '남성', '여성'].map((g) {
              final isSel = _selectedGender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      g,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSel ? AppColors.text : AppColors.subText,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // 2. 대분류 카테고리 (가로 스크롤)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _tagsData.map((data) {
              final name = data['main'];
              final isSel = _selectedMain == name;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMain = name),
                  child: TagChip(label: name, highlighted: isSel),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.border),
            SizedBox(height: 16),
            Text(
              '조건에 맞는 공고가 없어요\n다른 카테고리를 선택해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _JobCard({required this.post});

  @override
  Widget build(BuildContext context) {
    // 1. null 체크 및 안전한 리스트 변환 (가장 빈번한 에러 발생 지점)
    final List<String> mainTags =
        (post['main_tags'] as List?)
            ?.map((e) => e?.toString() ?? '') // 각 요소가 null일 경우 대비
            .where((e) => e.isNotEmpty) // 빈 문자열 제외
            .toList() ??
        [];

    final List<String> subTags =
        (post['sub_tags'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    final List<String> allTags = [...mainTags, ...subTags];

    // 2. 문자열 변수들 안전하게 추출
    final String title = post['title']?.toString() ?? '제목 없음';
    final String genderLimit = post['gender_limit']?.toString() ?? '전체';
    final String jobDate = post['job_date']?.toString() ?? '날짜 정보 없음';
    final String location = post['location_name']?.toString() ?? '위치 정보 없음';
    final String reward = post['reward']?.toString() ?? '0';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobDetailScreen(post: post, isSenior: true),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[200]!), // 100보다 살짝 진하게 조정
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 성별 뱃지
            if (genderLimit != '전체')
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  genderLimit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // 태그 리스트
            if (allTags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 8,
                children: allTags
                    .map(
                      (tag) => TagChip(
                        label: tag,
                        highlighted: mainTags.contains(tag),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 18),
            Divider(color: Colors.grey[50], thickness: 1.5),
            const SizedBox(height: 12),
            _Line(Icons.calendar_today_rounded, jobDate),
            const SizedBox(height: 8),
            _Line(Icons.place_outlined, location),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Line(Icons.payments_outlined, '$reward원'),
                const Text(
                  '자세히 보기 >',
                  style: TextStyle(
                    color: AppColors.subText,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 아이콘과 텍스트를 한 줄로 보여주는 헬퍼 위젯
Widget _Line(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 16,
        color: AppColors.subText,
      ), // AppColors.subText가 없다면 Colors.grey 사용
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.subText,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis, // 텍스트가 너무 길면 줄임표 처리
        ),
      ),
    ],
  );
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
        const Text(
          '매칭된 일거리',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (_matched.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 56,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '매칭된 일거리가 없어요',
                    style: TextStyle(color: AppColors.subText),
                  ),
                ],
              ),
            ),
          )
        else
          ..._matched.map(
            (match) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
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
                  child: const Icon(
                    Icons.work_outline,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  match['post_id']?.toString() ?? '매칭된 공고',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
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
            ),
          ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로필이 저장되었어요')));
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
                    child: Icon(
                      _icons[_selectedIconIndex],
                      size: 58,
                      color: cardColor,
                    ),
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
                            BoxShadow(color: Color(0x20000000), blurRadius: 6),
                          ],
                        ),
                        child: Icon(Icons.refresh, size: 16, color: cardColor),
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
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  : Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '신뢰 점수 $score점',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
          const Text(
            '카드 색상',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
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
                        ? Border.all(color: AppColors.text, width: 3)
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // 아이콘 선택
          const Text(
            '아이콘 선택',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_icons.length, (i) {
              final sel = _selectedIconIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedIconIndex = i),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    _icons[i],
                    color: sel ? Colors.white : AppColors.subText,
                  ),
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
            const Text(
              '한줄 소개',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              child: Text(
                _isEditing ? '취소' : '수정',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _isEditing
            ? TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '자신을 소개하는 문구를 적어보세요',
                ),
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
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),

        const SizedBox(height: 24),

        // 활동 태그
        const Text(
          '활동 태그',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
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
        const Text(
          '획득한 배지',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
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

        // 마이페이지 UI 부분
        AppButton(
          text: '활동 거점 수정하기',
          filled: false, // 테두리만 있는 스타일 (선택사항)
          onTap: () async {
            // 1. 서버에서 현재 내 위치 리스트를 가져옵니다.
            // (로딩 다이얼로그를 띄우면 더 친절한 UI가 됩니다)
            final response = await LocationService.getMyLocations();

            if (response.success && response.data != null) {
              // 2. 데이터를 성공적으로 가져오면 수정 페이지로 이동!
              if (!context.mounted) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LocationEditScreen(initialLocations: response.data!),
                ),
              );

              // 3. 수정 페이지에서 '저장' 후 돌아왔을 때
              // 추가로 할 작업이 있다면 여기에 작성 (현재는 필요 없음)
            } else {
              // 4. 실패 시 에러 메시지 표시
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response.error ?? '위치 정보를 불러오지 못했습니다.')),
              );
            }
          },
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
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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
