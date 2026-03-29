import 'package:flutter/material.dart';
import 'job_detail_screen.dart';

class NotificationScreen extends StatelessWidget {
  final bool isSenior;

  const NotificationScreen({
    super.key,
    required this.isSenior,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': isSenior ? '요청자의 요청이 도착했어요' : '시니어 지원이 들어왔어요',
        'post': {
          'title': '병원 동행 도와주세요',
          'content': '오전 진료 동행과 접수 보조가 필요합니다.',
          'date': '2026-03-30',
          'time': '오전 10:00',
          'location': '경희대 인근 병원',
          'reward': '25,000원',
          'requesterName': '김민지',
          'requesterGender': '여성',
          'phone': '010-2222-3333',
          'tags': ['#병원동행', '#말벗', '#관공서동행'],
        }
      },
      {
        'title': '공고가 수락되었어요',
        'post': {
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
        }
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('알림')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('눌러서 상세 내용을 확인하세요'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobDetailScreen(
                    post: item['post'] as Map<String, dynamic>,
                    showDecisionButtons: true,
                    showPhoneNumber: true,
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemCount: items.length,
      ),
    );
  }
}