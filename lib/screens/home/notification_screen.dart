import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  final bool isSenior;
  const NotificationScreen({super.key, required this.isSenior});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final res = await NotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = res.data ?? [];
        _isLoading = false;
      });
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'PROPOSAL': return Icons.person_add_outlined;
      case 'ACCEPT': return Icons.check_circle_outline;
      case 'REJECT': return Icons.cancel_outlined;
      case 'JOB': return Icons.work_outline;
      default: return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'PROPOSAL': return AppColors.primary;
      case 'ACCEPT': return AppColors.success;
      case 'REJECT': return AppColors.subText;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('알림')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? const Center(child: Text('알림이 없어요'))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final type = item['type'] as String? ?? 'JOB';
                    final isRead = item['is_read'] as bool? ?? false;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isRead
                              ? AppColors.border
                              : AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _colorFor(type).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_iconFor(type), color: _colorFor(type), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item['content'] as String? ?? '',
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}