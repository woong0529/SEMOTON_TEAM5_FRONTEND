import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import 'senior_signup_screen.dart';

class SeniorIntroScreen extends StatelessWidget {
  const SeniorIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              const Spacer(),
              const Text(
                '프로필을\n완성해주세요',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '복지관 고유 코드로 가입한 뒤,\n자신 있는 일을 입력하면 AI가 태그를 뽑아드려요.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '가입 시 입력 정보',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('• 복지관 고유 코드'),
                    Text('• 이름 / 성별 / 생년월일'),
                    Text('• 전화번호'),
                    Text('• 어떤 일에 자신 있으신가요?'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              AppButton(
                text: '시작하기',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SeniorSignupScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}