import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';
import '../auth/login_screen.dart';
import 'job_detail_screen.dart';
import 'notification_screen.dart';

class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> jobPosts = [
    {
      'title': '병원 동행 도와주세요',
      'content': '접수와 진료 동행을 부탁드려요.',
      'date': '2026-03-30',
      'time': '오전 10:00',
      'location': '회기역 근처 내과',
      'reward': '25,000원',
      'requesterName': '김민지',
      'requesterGender': '여성',
      'phone': '010-2222-3333',
      'tags': ['#병원동행', '#말벗', '#관공서동행'],
    },
    {
      'title': '강아지 산책 부탁드려요',
      'content': '30분 정도 단지 산책을 부탁드립니다.',
      'date': '2026-03-31',
      'time': '오후 4:00',
      'location': '휘경동 아파트 단지',
      'reward': '15,000원',
      'requesterName': '박소연',
      'requesterGender': '여성',
      'phone': '010-4444-5555',
      'tags': ['#강아지산책', '#반려동물', '#산책친구'],
    },
    {
      'title': '장보기와 반찬 정리 도와주세요',
      'content': '근처 마트에서 장을 보고 냉장고 정리를 부탁드려요.',
      'date': '2026-04-01',
      'time': '오후 2:00',
      'location': '이문동 자택',
      'reward': '20,000원',
      'requesterName': '이수정',
      'requesterGender': '여성',
      'phone': '010-8888-9999',
      'tags': ['#장보기대행', '#집밥제조', '#냉장고정리'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _JobListPage(jobPosts: jobPosts),
      const _MatchingPage(),
      const _ProfilePage(),
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
                  builder: (_) => const NotificationScreen(isSenior: true),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '공고찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '매칭조회'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}

class _JobListPage extends StatelessWidget {
  final List<Map<String, dynamic>> jobPosts;

  const _JobListPage({required this.jobPosts});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text(
          '태그를 눌러\n공고를 찾아보세요',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(label: '#말벗', highlighted: true),
            TagChip(label: '#병원동행'),
            TagChip(label: '#강아지산책'),
            TagChip(label: '#장보기대행'),
            TagChip(label: '#놀이학습'),
          ],
        ),
        const SizedBox(height: 22),
        ...jobPosts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _JobCard(post: post),
          ),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const _JobCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final tags = (post['tags'] as List<String>?) ?? [];

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 180),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['title'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.take(3).map((e) => TagChip(label: e)).toList(),
            ),
            const SizedBox(height: 18),
            _line(Icons.access_time, '${post['date']} / ${post['time']}'),
            const SizedBox(height: 10),
            _line(Icons.place_outlined, post['location']),
            const SizedBox(height: 10),
            _line(Icons.payments_outlined, post['reward']),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchingPage extends StatelessWidget {
  const _MatchingPage();

  @override
  Widget build(BuildContext context) {
    final matched = [
      {
        'title': '병원 동행 도와주세요',
        'content': '접수와 진료 동행을 부탁드려요.',
        'date': '2026-03-30',
        'time': '오전 10:00',
        'location': '회기역 근처 내과',
        'reward': '25,000원',
        'requesterName': '김민지',
        'requesterGender': '여성',
        'phone': '010-2222-3333',
        'tags': ['#병원동행', '#말벗'],
      }
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '매칭된 일거리',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        ...matched.map(
          (post) => Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              title: Text(
                post['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${post['date']} / ${post['time']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailScreen(
                      post: post,
                      showDecisionButtons: false,
                      showPhoneNumber: true,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('일 종료 처리가 완료되었어요')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            '일 종료',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final introController = TextEditingController(
    text: '아이와 대화하는 것을 좋아하고, 병원 동행이나 장보기 도움도 꼼꼼하게 할 수 있어요.',
  );

  int selectedIconIndex = 0;
  final icons = [
    Icons.favorite,
    Icons.park,
    Icons.pets,
    Icons.child_care,
    Icons.restaurant,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                '최재철',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '시니어 점수 86점',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  TagChip(label: '#병원동행'),
                  TagChip(label: '#말벗'),
                  TagChip(label: '#강아지산책'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '한줄 문구',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: introController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '자신을 소개하는 문구를 적어보세요',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '아이콘 선택',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: List.generate(
            icons.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() => selectedIconIndex = index);
              },
              child: CircleAvatar(
                radius: 26,
                backgroundColor: selectedIconIndex == index
                    ? AppColors.primary
                    : Colors.white,
                child: Icon(
                  icons[index],
                  color: selectedIconIndex == index
                      ? Colors.white
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '배지',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            TagChip(label: '친절왕'),
            TagChip(label: '시간엄수'),
            TagChip(label: '말벗전문'),
          ],
        ),
        const SizedBox(height: 28),
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