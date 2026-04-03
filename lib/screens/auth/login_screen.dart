import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../senior_signup/senior_intro_screen.dart';
import '../requester_signup/requester_signup_screen.dart';
import 'phone_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 120,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  '처음 오셨나요?',
                  style: TextStyle(fontSize: 14, color: AppColors.subText),
                ),
              ),
              const SizedBox(height: 14),
              _BigButton(
                text: '회원가입 하기',
                filled: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoleSelectScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _BigButton(
                text: '로그인하러 가기',
                filled: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PhoneLoginScreen()),
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

// ── 역할 선택 (카드형 스타일) ──────────────────────────────
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              const SizedBox(height: 10),
              const Text(
                '어떤 역할로\n시작할까요?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const Spacer(),
              _RoleCard(
                title: '도움을 받으러 오셨나요?',
                subtitle: '공고를 작성하고 시니어를 추천받아요',
                icon: Icons.favorite_border,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RequesterSignupScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                title: '도움을 주러 오셨나요?',
                subtitle: '시니어로 가입하고 공고를 확인해요',
                icon: Icons.volunteer_activism_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SeniorIntroScreen()),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primarySoft,
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.subText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.subText),
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;
  const _BigButton(
      {required this.text, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled ? AppColors.primary : Colors.white,
          foregroundColor: filled ? Colors.white : AppColors.text,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: filled ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}