import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
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
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _RecommendationPage(),
      const _PostCreatePage(),
      const _RequesterMyPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              currentIndex = 0;
            });
          },
          child: const Text(
            'SEE:NEAR',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(isSenior: false),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '추천'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: '공고작성'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}

class _RecommendationPage extends StatelessWidget {
  const _RecommendationPage();

  @override
  Widget build(BuildContext context) {
    final senior = {
      'title': '최재철 시니어',
      'content': '아이와 반려동물을 잘 돌보며 병원 동행도 가능합니다.',
      'date': '추천 시니어',
      'time': '매칭 가능',
      'location': '서울 동대문구',
      'reward': '시니어 점수 86점',
      'requesterName': '최재철',
      'requesterGender': '남성',
      'phone': '010-9864-3734',
      'tags': ['#강아지산책', '#병원동행', '#말벗'],
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '제안서를 바탕으로\n매칭해드릴게요',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: Center(
              child: Container(
                width: 290,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '최재철',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '시니어 점수 86점',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '아이 돌봄과 반려동물 케어에 자신 있어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        TagChip(label: '#강아지산책'),
                        TagChip(label: '#병원동행'),
                        TagChip(label: '#말벗'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: '세부정보 보기',
                      filled: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailScreen(
                              post: senior,
                              showDecisionButtons: false,
                              showPhoneNumber: false,
                              isSenior: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Text(
            '카드를 눌러 더 자세한 내용을 확인해보세요',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _PostCreatePage extends StatefulWidget {
  const _PostCreatePage();

  @override
  State<_PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<_PostCreatePage> {
  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final rewardController = TextEditingController();
  final contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '도움받기 공고 작성',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: '제목'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: timeController,
            decoration: const InputDecoration(
              labelText: '시간',
              hintText: '2026-03-31 / 오후 3시',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(labelText: '위치'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: rewardController,
            decoration: const InputDecoration(labelText: '보수'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: '구체적인 요청 사항',
              hintText: '어떤 도움이 필요한지 자세히 적어주세요.',
            ),
          ),
          const SizedBox(height: 22),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'AI 추출 예상 태그',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip(label: '#병원동행'),
              TagChip(label: '#말벗'),
              TagChip(label: '#장보기대행'),
            ],
          ),
          const SizedBox(height: 22),
          AppButton(
            text: '공고 등록',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공고가 등록되었어요')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequesterMyPage extends StatelessWidget {
  const _RequesterMyPage();

  @override
  Widget build(BuildContext context) {
    final myPosts = [
      {'title': '병원 동행 도와주세요', 'status': 'OPEN'},
      {'title': '강아지 산책 부탁드려요', 'status': 'MATCHED'},
      {'title': '장보기와 반찬 정리 도와주세요', 'status': 'DONE'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '내가 올린 공고',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        ...myPosts.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  item['status']!,
                  style: TextStyle(
                    color: item['status'] == 'OPEN'
                        ? AppColors.primary
                        : item['status'] == 'MATCHED'
                            ? AppColors.success
                            : AppColors.subText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          text: '로그아웃',
          filled: false,
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}