import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../auth/login_screen.dart';

class RequesterSignupScreen extends StatefulWidget {
  const RequesterSignupScreen({super.key});

  @override
  State<RequesterSignupScreen> createState() => _RequesterSignupScreenState();
}

class _RequesterSignupScreenState extends State<RequesterSignupScreen> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final phoneController = TextEditingController();
  final birthController = TextEditingController();

  String gender = '여성';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('요청자 회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(labelText: '성별'),
              items: const [
                DropdownMenuItem(value: '여성', child: Text('여성')),
                DropdownMenuItem(value: '남성', child: Text('남성')),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value ?? '여성';
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '010-1234-5678',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: birthController,
              decoration: const InputDecoration(
                labelText: '생년월일',
                hintText: '1999-05-11',
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              text: '회원가입 완료',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('회원가입 완료'),
                    content: const Text('이제 로그인해서 공고를 작성해보세요.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('확인'),
                      ),
                    ],
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