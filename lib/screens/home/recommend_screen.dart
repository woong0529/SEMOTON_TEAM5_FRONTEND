import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/matching_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';
import 'requester_home_screen.dart';


class RecommendScreen extends StatefulWidget {
  final VoidCallback? onGoToPost;
  const RecommendScreen({super.key, this.onGoToPost});

  @override
  State<RecommendScreen> createState() => RecommendScreenState();
}

class RecommendScreenState extends State<RecommendScreen> {
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
    return Scaffold(
      // ⭐ 뒤로가기 버튼이 자동으로 포함되는 AppBar 추가
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('AI 맞춤 추천', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _buildBody(),
    );
  }

  Widget _buildBody() {
    final nickname = _profile?['nickname'] ?? '요청자';

    if (_myPosts.isEmpty) {
      return _buildNoPostView();
    }

    final senior = _seniors[_cardIndex % _seniors.length];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$nickname님께\n추천 시니어예요',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.3),
          ),
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
                child: _SeniorCardWidget( // 위젯 클래스명 변경
                  senior: senior,
                  onSkip: () => setState(() => _cardIndex++),
                  onPropose: () => _proposeMatch(context, senior),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '← 넘기기   |   제안하기 →',
              style: TextStyle(fontSize: 13, color: AppColors.subText),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }


Widget _buildNoPostView() {
    return Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.edit_document,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '공고를 먼저 작성해주세요!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '공고를 등록하면\n딱 맞는 시니어를 추천해드려요',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.subText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(text: '공고 작성하러 가기', onTap: () {
                // ⭐ 직접 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostCreatePage(),
                  ),
                );
              },
            ),
            ],
          ),
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
            child: const Text('취소'),
          ),
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

class _SeniorCardWidget extends StatelessWidget {
  final Map<String, dynamic> senior;
  final VoidCallback onSkip;
  final VoidCallback onPropose;

  const _SeniorCardWidget({
    required this.senior,
    required this.onSkip,
    required this.onPropose,
  });

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
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            senior['name'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '신뢰 점수 ${senior['trust_score']}점',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            senior['bio_summary'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '제안하기',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
