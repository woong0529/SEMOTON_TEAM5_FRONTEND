import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../auth/login_screen.dart';

class SeniorSignupScreen extends StatefulWidget {
  const SeniorSignupScreen({super.key});

  @override
  State<SeniorSignupScreen> createState() => _SeniorSignupScreenState();
}

class _SeniorSignupScreenState extends State<SeniorSignupScreen> {
  final authCodeController = TextEditingController();
  final nameController = TextEditingController();
  final birthController = TextEditingController();
  final phoneController = TextEditingController();
  final strengthController = TextEditingController();

  String gender = '여성';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시니어 회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            TextField(
              controller: authCodeController,
              decoration: const InputDecoration(
                labelText: '복지관 고유 코드',
                hintText: '예: 1011-01',
              ),
            ),
            const SizedBox(height: 14),
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
              controller: birthController,
              decoration: const InputDecoration(
                labelText: '생년월일',
                hintText: '1965-07-12',
              ),
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
              controller: strengthController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'OOO님은 어떤 일에 자신이 있으신가요?',
                hintText: '예: 아이와 잘 놀아주고, 장보기나 병원 동행도 꼼꼼하게 할 수 있어요.',
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
                    content: const Text('태그가 생성되었어요.\n로그인해서 공고를 확인해보세요.'),
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