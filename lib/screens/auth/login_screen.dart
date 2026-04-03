import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../senior_signup/senior_intro_screen.dart';
import '../requester_signup/requester_signup_screen.dart';
import 'phone_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String _logoPath = 'assets/logo/seenear_logo.png';
  static const String _requesterImagePath =
      'assets/onboarding/requester_card.png';
  static const String _seniorImagePath = 'assets/onboarding/senior_card.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Image.asset(
                  _logoPath,
                  width: 210,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.image_not_supported_outlined, size: 80),
                      SizedBox(height: 12),
                      Text('assets/logo/seenear_logo.png 확인'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 78),
              const Text(
                '처음 오셨나요?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.subText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              _MainActionButton(
                text: '회원가입 하기',
                filled: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectScreen(
                      requesterImagePath: _requesterImagePath,
                      seniorImagePath: _seniorImagePath,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _MainActionButton(
                text: '로그인하러 가기',
                filled: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                ),
              ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSelectScreen extends StatelessWidget {
  final String requesterImagePath;
  final String seniorImagePath;

  const RoleSelectScreen({
    super.key,
    required this.requesterImagePath,
    required this.seniorImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.subText,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '어떤 역할로\n시작할까요?',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 22),
              _RoleImageCard(
                badgeText: '도움받기 >',
                title: '도움을 받으러\n오셨나요?',
                subtitle: '공고를 작성하고 시니어를 추천받아요',
                imagePath: requesterImagePath,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequesterSignupScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _RoleImageCard(
                badgeText: '도움주기 >',
                title: '도움을 주러\n오셨나요?',
                subtitle: '시니어로 가입하고 공고를 확인해요',
                imagePath: seniorImagePath,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SeniorIntroScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _MainActionButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: filled ? 0 : 3,
          shadowColor: filled ? Colors.transparent : Colors.black12,
          backgroundColor: filled ? AppColors.primary : const Color(0xFFF1F1F1),
          foregroundColor: filled ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _RoleImageCard extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _RoleImageCard({
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 126,
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  imagePath,
                  height: 118,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
