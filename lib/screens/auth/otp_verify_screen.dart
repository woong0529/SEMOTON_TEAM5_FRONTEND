import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../home/requester_home_screen.dart';
import '../home/senior_home_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String role;

  const OtpVerifyScreen({
    super.key,
    required this.role,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
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
            const Text(
              '인증번호 입력',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '문자로 받은 6자리 인증번호를 입력해주세요',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '인증번호',
                hintText: '123456',
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: '로그인',
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        isSenior
                            ? const SeniorHomeScreen()
                            : const RequesterHomeScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}