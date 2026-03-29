import 'package:flutter/material.dart';
import '../requester_signup/requester_signup_screen.dart';
import '../senior_signup/senior_intro_screen.dart';
import 'phone_login_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  final bool isSignup;

  const RoleSelectScreen({
    super.key,
    required this.isSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              const SizedBox(height: 10),
              Text(
                isSignup ? '어떤 도움으로\n시작할까요?' : '어떤 역할로\n로그인할까요?',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 28),

              _RoleCard(
                title: '도움을 받으러 오셨나요?',
                subtitle: '공고를 작성하고 시니어를 추천받아요',
                icon: Icons.favorite_border,
                onTap: () {
                  if (isSignup) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequesterSignupScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PhoneLoginScreen(role: 'requester'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _RoleCard(
                title: '도움을 주러 오셨나요?',
                subtitle: '시니어로 가입하고 공고를 확인해요',
                icon: Icons.volunteer_activism_outlined,
                onTap: () {
                  if (isSignup) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SeniorIntroScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PhoneLoginScreen(role: 'senior'),
                      ),
                    );
                  }
                },
              ),
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
              backgroundColor: const Color(0xFFFFE6DF),
              child: Icon(icon, color: const Color(0xFFFF6B4A), size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}