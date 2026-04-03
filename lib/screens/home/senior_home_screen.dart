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
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            label: '추천',
          ),
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

// ── 공고 리스트 (Null Safety 강화 버전) ──────────────────────────

class _JobListPage extends StatefulWidget {
  const _JobListPage();

  @override
  State<_JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<_JobListPage> {
  final List<Map<String, dynamic>> _tagsData = [
    {"main": "전체", "sub": []},
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
  String _selectedSub = "";
  String _selectedGender = "전체";
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    if (!mounted) return;
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

  // 💡 수정된 필터 로직: 모든 단계에서 Null 및 타입 체크 강화
  // 💡 타입 에러를 완전히 방지하도록 수정한 필터 로직
  List<dynamic> get _filtered {
    return _jobs.where((j) {
      if (j == null || j is! Map) return false;

      // 1. 성별 필터 (Null 및 타입 방어)
      final String genderLimit = (j['gender_limit'] ?? '전체').toString();
      bool matchGender =
          _selectedGender == "전체" || (genderLimit == _selectedGender);
      if (!matchGender) return false;

      // 2. 태그 필터링
      // 서버에서 온 데이터가 리스트인지 확인하고, 각 요소를 String으로 안전하게 변환
      final List jobSubs = (j['sub_tags'] is List) ? j['sub_tags'] : [];
      final List<String> safeJobSubs = jobSubs
          .where((s) => s != null)
          .map((s) => s.toString())
          .toList();

      if (_selectedSub.isNotEmpty) {
        // 소분류 태그 선택 시
        return safeJobSubs.contains(_selectedSub);
      } else if (_selectedMain != "전체") {
        // 대분류만 선택 시
        final currentData = _tagsData.firstWhere(
          (d) => d['main'] == _selectedMain,
          orElse: () => {"main": "전체", "sub": []},
        );

        // 💡 에러 발생 지점: d['sub']를 가져올 때 safe 하게 처리
        final List rawSubList = (currentData['sub'] is List)
            ? currentData['sub']
            : [];
        final List<String> mainSubs = rawSubList
            .map((e) => e.toString())
            .toList();

        return safeJobSubs.any((s) => mainSubs.contains(s));
      }

      return true; // "전체"일 때
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchJobs,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        physics: const AlwaysScrollableScrollPhysics(),
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
          _buildFilterSection(),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_filtered.isEmpty)
            _buildEmptyState()
          else
            ..._filtered.map((job) {
              // 안전하게 Map<String, dynamic>으로 변환
              final jobMap = Map<String, dynamic>.from(job as Map);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _JobCard(post: jobMap),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final currentMainData = _tagsData.firstWhere(
      (d) => d['main'] == _selectedMain,
      orElse: () => {"main": "전체", "sub": []},
    );
    final List<String> subTags = List<String>.from(currentMainData['sub']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGenderTabs(),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _tagsData.map((data) {
              final name = data['main'] ?? '전체';
              final isSel = _selectedMain == name;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedMain = name;
                    _selectedSub = "";
                  }),
                  child: TagChip(label: name, highlighted: isSel),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedMain != "전체" && subTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: subTags.map((tag) {
                final isSel = _selectedSub == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedSub = isSel ? "" : tag;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSel ? Colors.white : AppColors.subText,
                          fontWeight: isSel
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderTabs() {
    return Container(
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
                          const BoxShadow(
                            color: Color(0x0D000000),
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
              '조건에 맞는 공고가 없어요\n다른 태그를 선택해보세요',
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
    // Tag 처리 시 Null 및 데이터 타입 방어
    final List<String> mainTags =
        (post['main_tags'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    final List<String> subTags =
        (post['sub_tags'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    final List<String> allTags = [...mainTags, ...subTags];

    final genderLimit = post['gender_limit']?.toString() ?? '전체';

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
          border: Border.all(color: Colors.grey[200]!),
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
              post['title']?.toString() ?? '제목 없음',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
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
            _Line(
              Icons.calendar_today_rounded,
              post['job_date']?.toString() ?? '날짜 정보 없음',
            ),
            const SizedBox(height: 8),
            _Line(
              Icons.place_outlined,
              post['location_name']?.toString() ?? '위치 정보 없음',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Line(Icons.payments_outlined, '${post['reward'] ?? 0}원'),
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

  Widget _Line(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.subText),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.subText,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── 매칭 페이지 (기존 유지) ───────────────────────────────

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
    try {
      final res = await MatchingService.getActiveMatches();
      if (mounted) {
        setState(() {
          _matched = (res.data as List?)?.cast<Map<String, dynamic>>() ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
          const _EmptyState(
            icon: Icons.assignment_outlined,
            text: '매칭된 일거리가 없어요',
          )
        else
          ..._matched.map((match) => _MatchingCard(match: match)),
      ],
    );
  }
}

class _MatchingCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _MatchingCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: const Icon(Icons.work_outline, color: AppColors.primary),
        ),
        title: Text(
          match['title']?.toString() ?? '매칭된 공고',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('상태: ${match['status'] ?? '진행중'}'),
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
    );
  }
}

// ── 마이페이지 (기존 유지) ───────────────────────────────

class _ProfilePage extends StatefulWidget {
  final VoidCallback onGoHome;
  const _ProfilePage({required this.onGoHome});

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  final _bioController = TextEditingController();
  final _nameController = TextEditingController();

  final _icons = [
    Icons.favorite_rounded,
    Icons.park_rounded,
    Icons.pets_rounded,
    Icons.child_care_rounded,
  ];
  final _colors = [
    AppColors.primary,
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
  ];

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );

    final tags = (_profile?['tags'] as List?)?.cast<String>() ?? [];
    final name = _profile?['name'] ?? '시니어';
    final score = _profile?['trust_score'] ?? 50;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildProfileCard(name, score, tags),
        const SizedBox(height: 24),
        const Text(
          '한줄 소개',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        _buildBioSection(),
        const SizedBox(height: 24),
        AppButton(
          text: '활동 거점 수정하기',
          filled: false,
          onTap: () async {
            final response = await LocationService.getMyLocations();
            if (response.success && response.data != null && context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LocationEditScreen(initialLocations: response.data!),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 12),
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
    );
  }

  Widget _buildProfileCard(String name, int score, List<String> tags) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text('신뢰 점수 $score점', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) => TagChip(label: t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _bioController.text.isEmpty ? '등록된 소개가 없습니다.' : _bioController.text,
        style: const TextStyle(height: 1.5),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 56, color: AppColors.border),
            const SizedBox(height: 16),
            Text(text, style: const TextStyle(color: AppColors.subText)),
          ],
        ),
      ),
    );
  }
}
