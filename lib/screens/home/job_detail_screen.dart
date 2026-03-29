import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool showDecisionButtons;
  final bool showPhoneNumber;

  const JobDetailScreen({
    super.key,
    required this.post,
    this.showDecisionButtons = false,
    this.showPhoneNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    final tags = (post['tags'] as List<String>?) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('공고 상세')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((e) => TagChip(label: e)).toList(),
              ),
              const SizedBox(height: 22),
              _info('구체적인 요청 사항', post['content']),
              _info('시간', '${post['date']} / ${post['time']}'),
              _info('위치', post['location']),
              _info('보수', post['reward']),
              _info(
                '요청자 정보',
                '${post['requesterName']} / ${post['requesterGender']}',
              ),
              if (showPhoneNumber)
                _info(
                  '전화번호',
                  post['phone'] ?? '010-1234-5678',
                  highlighted: true,
                ),
              const SizedBox(height: 24),
              if (showDecisionButtons) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: '거절',
                        filled: false,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: '수락',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                AppButton(
                  text: '신청하기',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신청이 완료되었어요')),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String title, String value, {bool highlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              fontSize: highlighted ? 17 : 16,
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
              color: highlighted ? AppColors.primary : AppColors.text,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}