import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/matching_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tag_chip.dart';

class JobDetailScreen extends StatefulWidget {
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
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  // ⭐ '일 종료' 버튼이 눌렸는지 확인하는 상태 변수
  bool _isJobTerminated = false;

  @override
  Widget build(BuildContext context) {
    final tags = (widget.post['tags'] as List?)?.cast<String>() ?? [];

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
              Text(
                widget.post['title'] ?? '',
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
                children: tags.map((t) => TagChip(label: t)).toList(),
              ),
              const SizedBox(height: 22),
              _InfoRow(title: '요청 내용', value: widget.post['content'] ?? ''),
              _InfoRow(
                title: '날짜 / 시간',
                value:
                    '${widget.post['job_date'] ?? ''} / ${widget.post['start_time'] ?? ''}',
              ),
              _InfoRow(title: '위치', value: widget.post['location_name'] ?? ''),
              _InfoRow(
                title: '보수',
                value: widget.post['reward'] != null
                    ? '${widget.post['reward']}원'
                    : '',
              ),
              if (widget.post['requesterName'] != null)
                _InfoRow(
                  title: '요청자 정보',
                  value:
                      '${widget.post['requesterName']} / ${widget.post['requesterGender'] ?? ''}',
                ),
              if (widget.showPhoneNumber && widget.post['phone'] != null)
                _InfoRow(
                  title: '전화번호',
                  value: widget.post['phone'],
                  highlighted: true,
                ),
              const SizedBox(height: 24),

              // --- 버튼 섹션 ---
              if (widget.showDecisionButtons) ...[
                _buildDecisionButtons(),
              ] else if (widget.showTerminateButton) ...[
                _buildTerminateOrReportButtons(),
              ] else ...[
                _buildApplyButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ 핵심: 일 종료 버튼 및 전환 로직
  Widget _buildTerminateOrReportButtons() {
    if (_isJobTerminated) {
      // 1. 일 종료 버튼을 누른 후의 화면 (신고 & 확인)
      return Column(
        children: [
          const Text(
            '일이 정상적으로 종료되었습니다.\n불편한 점이 있으셨나요?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subText, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '신고하기',
                  filled: false,
                  onTap: () => _showReportDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: '확인',
                  onTap: () => Navigator.pop(context), // 여기서 최종 pop
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // 2. 처음 보여지는 '일 종료' 버튼
      return AppButton(
        text: '일 종료',
        onTap: () async {
          if (widget.matchId != null) {
            await MatchingService.completeJob(widget.matchId!);
            setState(() {
              _isJobTerminated = true; // 상태 변경 -> 버튼 교체됨
            });
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('업무가 종료 처리되었습니다.')));
            }
          }
        },
      );
    }
  }

  // 거절/수락 버튼
  Widget _buildDecisionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: '거절',
            filled: false,
            onTap: () async {
              if (widget.matchId != null) {
                await MatchingService.updateMatchStatus(
                  widget.matchId!,
                  'REJECTED',
                );
              }
              if (mounted) Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            text: '수락',
            onTap: () async {
              if (widget.matchId != null) {
                await MatchingService.updateMatchStatus(
                  widget.matchId!,
                  'ACCEPTED',
                );
              }
              if (mounted) Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  // 신청하기 버튼
  Widget _buildApplyButton() {
    return AppButton(
      text: '신청하기',
      onTap: () async {
        final postId = widget.post['post_id'] as String?;
        if (postId != null) {
          final res = await MatchingService.applyJob(postId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  res.success ? '신청이 완료되었어요' : res.error ?? '신청 실패',
                ),
              ),
            );
          }
        }
      },
    );
  }

  // 신고 팝업 다이얼로그 (위와 동일)
  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고 및 리포트'),
        content: TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '신고 사유나 특이사항을 적어주세요.',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
            },
            child: const Text('제출'),
          ),
        ],
      ),
    );
  }
}

// _InfoRow는 기존과 동일하므로 생략
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.subText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: highlighted ? 17 : 15,
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
