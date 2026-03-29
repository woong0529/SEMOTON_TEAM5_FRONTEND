import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import 'role_select_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'SEE:NEAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Text(
                '시니어와\n가까운 도움을 연결해요',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '도움을 주고, 도움을 받고,\n따뜻한 연결이 시작되는 곳',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: '회원가입',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectScreen(isSignup: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              AppButton(
                text: '로그인',
                filled: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectScreen(isSignup: false),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              AppButton(
                text: '구글 계정으로 계속하기',
                filled: false,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              AppButton(
                text: '네이버 계정으로 계속하기',
                filled: false,
                onTap: () {},
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}