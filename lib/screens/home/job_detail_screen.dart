import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../services/matching_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool showDecisionButtons; // 수락/거절 버튼 표시 여부 (요청자가 시니어에게 제안했을 때 등)
  final bool showPhoneNumber; // 매칭 완료 후 전화번호 표시 여부
  final bool showTerminateButton; // 시니어가 업무 완료 버튼을 눌러야 할 때
  final bool isSenior; // 현재 사용자가 시니어인지 여부
  final String? matchId; // 매칭 관련 처리를 위한 ID

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
    // 백엔드에서 내려오는 main_tags와 sub_tags를 합쳐서 표시
    final mainTags = (post['main_tags'] as List?)?.cast<String>() ?? [];
    final subTags = (post['sub_tags'] as List?)?.cast<String>() ?? [];
    final allTags = [...mainTags, ...subTags];

    // 금액 포맷팅 (예: 10,000원)
    final formatter = NumberFormat('#,###');
    final rewardText = post['reward'] != null
        ? '${formatter.format(post['reward'])}원'
        : '0원';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('공고 상세'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                post['title'] ?? '제목 없음',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 14),

              // 태그 리스트 (AI 추천 결과 포함)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allTags.isEmpty
                    ? [const TagChip(label: '일반')]
                    : allTags.map((t) => TagChip(label: t)).toList(),
              ),
              const SizedBox(height: 28),

              // 상세 정보 섹션
              _InfoRow(title: '요청 내용', value: post['content'] ?? '내용이 없습니다.'),

              _InfoRow(
                title: '날짜 / 시간',
                value:
                    '${post['job_date'] ?? ''}  |  ${post['start_time']?.toString().substring(0, 5) ?? ''}',
              ),

              _InfoRow(title: '위치', value: post['location_name'] ?? '위치 정보 없음'),

              _InfoRow(title: '보수', value: rewardText, highlighted: true),

              // 요청자 정보 (데이터가 있을 경우에만 표시)
              if (post['requester_nickname'] != null)
                _InfoRow(
                  title: '요청자 정보',
                  value: '${post['requester_nickname']} 님',
                ),

              // 매칭 완료 후 노출되는 긴급 연락처
              if (showPhoneNumber && post['phone'] != null)
                _InfoRow(title: '연락처', value: post['phone'], highlighted: true),

              const SizedBox(height: 32),

              // 하단 버튼 로직
              if (showDecisionButtons) ...[
                // 1. 수락/거절 단계 (제안을 받았을 때)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: '거절',
                        filled: false,
                        onTap: () async {
                          if (matchId != null) {
                            await MatchingService.updateMatchStatus(
                              matchId!,
                              'REJECTED',
                            );
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: '수락하기',
                        onTap: () async {
                          if (matchId != null) {
                            await MatchingService.updateMatchStatus(
                              matchId!,
                              'ACCEPTED',
                            );
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (showTerminateButton) ...[
                // 2. 업무 종료 단계
                AppButton(
                  text: '업무 완료 알림',
                  onTap: () async {
                    if (matchId != null) {
                      await MatchingService.completeJob(matchId!);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('업무가 성공적으로 종료되었습니다.')),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ] else if (isSenior && post['status'] == 'OPEN') ...[
                // 3. 일반적인 신청하기 단계 (시니어 시점)
                AppButton(
                  text: '이 일 신청하기',
                  onTap: () async {
                    final postId = post['post_id']?.toString();
                    if (postId != null) {
                      final res = await MatchingService.applyJob(postId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              res.success
                                  ? '신청이 완료되었습니다!'
                                  : res.error ?? '신청에 실패했습니다.',
                            ),
                          ),
                        );
                        if (res.success) Navigator.pop(context);
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

// 정보 한 줄을 표시하는 내부 위젯
class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final bool highlighted;

  const _InfoRow({
    required this.title,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subText,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: highlighted ? 18 : 16,
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
              color: highlighted ? AppColors.primary : AppColors.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
