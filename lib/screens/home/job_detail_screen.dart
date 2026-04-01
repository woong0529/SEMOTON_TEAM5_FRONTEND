import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/matching_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool showDecisionButtons;
  final bool showPhoneNumber;
  final bool showTerminateButton;
  final bool isSenior;
  final String? matchId;

  const JobDetailScreen({
    super.key,
    required this.post,
    this.showDecisionButtons = false,
    this.showPhoneNumber = false,
    this.showTerminateButton = false,
    required this.isSenior,
    this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final tags = (post['tags'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('공고 상세')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 18, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post['title'] ?? '',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3)),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8,
                  children: tags.map((t) => TagChip(label: t)).toList()),
              const SizedBox(height: 22),
              _InfoRow(title: '요청 내용', value: post['content'] ?? ''),
              _InfoRow(
                title: '날짜 / 시간',
                value: '${post['job_date'] ?? ''} / ${post['start_time'] ?? ''}',
              ),
              _InfoRow(title: '위치', value: post['location_name'] ?? ''),
              _InfoRow(
                title: '보수',
                value: post['reward'] != null ? '${post['reward']}원' : '',
              ),
              if (post['requesterName'] != null)
                _InfoRow(
                  title: '요청자 정보',
                  value: '${post['requesterName']} / ${post['requesterGender'] ?? ''}',
                ),
              if (showPhoneNumber && post['phone'] != null)
                _InfoRow(title: '전화번호', value: post['phone'], highlighted: true),
              const SizedBox(height: 24),
              if (showDecisionButtons) ...[
                Row(children: [
                  Expanded(child: AppButton(
                    text: '거절', filled: false,
                    onTap: () async {
                      if (matchId != null) {
                        await MatchingService.updateMatchStatus(matchId!, 'REJECTED');
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: AppButton(
                    text: '수락',
                    onTap: () async {
                      if (matchId != null) {
                        await MatchingService.updateMatchStatus(matchId!, 'ACCEPTED');
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                  )),
                ]),
              ] else if (showTerminateButton) ...[
                AppButton(
                  text: '일 종료',
                  onTap: () async {
                    if (matchId != null) {
                      await MatchingService.completeJob(matchId!);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('일이 종료되었어요')),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ] else ...[
                AppButton(
                  text: '신청하기',
                  onTap: () async {
                    final postId = post['post_id'] as String?;
                    if (postId != null) {
                      final res = await MatchingService.applyJob(postId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res.success ? '신청이 완료되었어요' : res.error ?? '신청 실패')),
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final bool highlighted;
  const _InfoRow({required this.title, required this.value, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: AppColors.subText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                fontSize: highlighted ? 17 : 15,
                fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
                color: highlighted ? AppColors.primary : AppColors.text,
                height: 1.45,
              )),
        ],
      ),
    );
  }
}