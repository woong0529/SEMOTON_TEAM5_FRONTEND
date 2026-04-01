import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_button.dart';
import 'senior_signup_screen.dart';

class SeniorIntroScreen extends StatelessWidget {
  const SeniorIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              const SizedBox(height: 32),
              const Text(
                '프로필을\n완성해주세요',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '복지관 고유 코드로 가입한 뒤,\n자신 있는 일을 말씀해주시면\nAI가 태그를 자동으로 만들어드려요.',
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.subText,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '가입 시 입력 정보',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                        icon: Icons.qr_code_rounded,
                        text: '복지관 고유 코드 (SEMO-2026)'),
                    _InfoRow(
                        icon: Icons.person_outline,
                        text: '이름 / 성별 / 생년월일'),
                    _InfoRow(icon: Icons.phone_outlined, text: '전화번호'),
                    _InfoRow(
                      icon: Icons.mic_none_rounded,
                      text: '어떤 일에 자신 있으신가요?',
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: '시작하기',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SeniorSignupScreen()),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;
  const _InfoRow(
      {required this.icon, required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: highlight ? AppColors.primarySoft : AppColors.chipGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 18,
                color: highlight ? AppColors.primary : AppColors.subText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}