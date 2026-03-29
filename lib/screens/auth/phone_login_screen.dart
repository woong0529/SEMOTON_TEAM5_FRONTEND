import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import 'otp_verify_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  final String role;

  const PhoneLoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isSenior = widget.role == 'senior';

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSenior ? '시니어 로그인' : '요청자 로그인',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '전화번호로 인증번호를 보내드릴게요',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '010-1234-5678',
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: '인증번호 받기',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpVerifyScreen(role: widget.role),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}