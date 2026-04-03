import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. 서비스를 추가해야 포매터 사용 가능
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
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
                      // 2. 포매터 적용: 숫자만 허용 + 최대 13자(하이픈 포함) + 자동 하이픈
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                        PhoneNumberFormatter(),
                      ],
                      decoration: const InputDecoration(
                        hintText: '010-2345-6789',
                        // 에러 발생 시 시각적 피드백을 위해 필요하면 추가
                      ),
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
                          : const Text(
                              '인증',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
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
    final phone = _controller.text.trim(); // 포매터 덕분에 010-XXXX-XXXX 형태임

    if (phone.isEmpty) {
      _showSnackBar('전화번호를 입력해주세요');
      return;
    }

    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
    if (!phoneRegex.hasMatch(phone)) {
      _showSnackBar('전화번호는 010-XXXX-XXXX 형식으로 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);
    final res = await AuthService.requestOtp(phone);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (res.success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpVerifyScreen(phoneNumber: phone)),
      );
    } else {
      _showSnackBar(res.error ?? 'OTP 발송 실패');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// 3. 자동 하이픈 삽입 포매터 클래스
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = "";

    if (text.length >= 1) {
      formatted += text.substring(0, text.length >= 3 ? 3 : text.length);
    }
    if (text.length >= 4) {
      formatted += "-${text.substring(3, text.length >= 7 ? 7 : text.length)}";
    }
    if (text.length >= 8) {
      formatted +=
          "-${text.substring(7, text.length >= 11 ? 11 : text.length)}";
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
