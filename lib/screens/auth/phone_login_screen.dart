import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import 'otp_verify_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  String _formatPhoneNumber(String input) {
    String digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) digits = digits.substring(0, 11);
    
    String formatted = '';
    if (digits.length >= 1) {
      formatted = digits.substring(0, min(3, digits.length));
    }
    if (digits.length >= 4) {
      formatted += '-' + digits.substring(3, min(7, digits.length));
    }
    if (digits.length > 7) {
      formatted += '-' + digits.substring(7);
    }
    
    return formatted;
  }

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
              const SizedBox(height: 16),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                '로그인에는\nOTP 인증이 필요해요',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '전화번호로 인증번호를 보내드릴게요',
                style: TextStyle(fontSize: 14, color: AppColors.subText),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        String formatted = _formatPhoneNumber(value);
                        if (formatted != value) {
                          _controller.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      },
                      decoration:
                          const InputDecoration(hintText: '01023456789'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('인증',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '테스트 인증번호: 123456',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호를 입력해주세요')),
      );
      return;
    }

    // 포매팅된 형식 검증 (010-XXXX-XXXX)
    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호는 010-XXXX-XXXX 형식으로 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await AuthService.requestOtp(phone);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (res.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(phoneNumber: phone),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'OTP 발송 실패')),
      );
    }
  }
}