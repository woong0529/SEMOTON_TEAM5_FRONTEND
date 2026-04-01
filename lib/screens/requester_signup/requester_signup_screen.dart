import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../home/requester_home_screen.dart';

class RequesterSignupScreen extends StatefulWidget {
  const RequesterSignupScreen({super.key});

  @override
  State<RequesterSignupScreen> createState() => _RequesterSignupScreenState();
}

class _RequesterSignupScreenState extends State<RequesterSignupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  String _name = '';
  String _gender = '남';
  int _birthYear = 1990;
  String _phone = '';
  bool _isSubmitting = false;

  void _next() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage++);
  }

  void _prev() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage--);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final res = await AuthService.signupRequester(
      phoneNumber: _phone,
      nickname: _name,
      gender: _gender,
      birthYear: _birthYear,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (res.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RequesterHomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? '가입 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _currentPage, total: 4),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepField(
                    title: '이름을\n입력해주세요',
                    hint: '홍길동',
                    onNext: (v) { _name = v; _next(); },
                    showBack: false,
                    onBack: () {},
                  ),
                  _StepGender(
                    selected: _gender,
                    onNext: (g) { _gender = g; _next(); },
                    onBack: _prev,
                  ),
                  _StepField(
                    title: '생년월일을\n입력해주세요',
                    hint: '예: 19990511',
                    keyboardType: TextInputType.number,
                    onNext: (v) {
                      if (v.length >= 4) {
                        _birthYear = int.tryParse(v.substring(0, 4)) ?? 1990;
                      }
                      _next();
                    },
                    onBack: _prev,
                  ),
                  _StepPhone(
                    onNext: (phone) { _phone = phone; _submit(); },
                    onBack: _prev,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: List.generate(
          total,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepWrapper extends StatelessWidget {
  final Widget child;
  const _StepWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 160,
        child: child,
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String text;
  const _StepTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800,
            height: 1.3, color: AppColors.text));
  }
}

class _StepField extends StatefulWidget {
  final String title;
  final String hint;
  final TextInputType keyboardType;
  final void Function(String) onNext;
  final VoidCallback onBack;
  final bool showBack;

  const _StepField({
    required this.title,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.onNext,
    required this.onBack,
    this.showBack = true,
  });

  @override
  State<_StepField> createState() => _StepFieldState();
}

class _StepFieldState extends State<_StepField> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(widget.title),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            autofocus: true,
            decoration: InputDecoration(hintText: widget.hint),
          ),
          const Spacer(),
          Row(children: [
            if (widget.showBack) ...[
              Expanded(child: AppButton(
                  text: '이전', filled: false, onTap: widget.onBack)),
              const SizedBox(width: 12),
            ],
            Expanded(child: AppButton(text: '다음', onTap: () {
              if (_controller.text.trim().isEmpty) return;
              widget.onNext(_controller.text.trim());
            })),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StepGender extends StatefulWidget {
  final String selected;
  final void Function(String) onNext;
  final VoidCallback onBack;
  const _StepGender(
      {required this.selected, required this.onNext, required this.onBack});

  @override
  State<_StepGender> createState() => _StepGenderState();
}

class _StepGenderState extends State<_StepGender> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('성별을\n선택해주세요'),
          const SizedBox(height: 36),
          Row(
            children: ['남', '여'].map((g) {
              final sel = _selected == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = g),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    height: 60,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: Text(g,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: sel ? Colors.white : AppColors.text,
                          )),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(
                text: '이전', filled: false, onTap: widget.onBack)),
            const SizedBox(width: 12),
            Expanded(child: AppButton(
                text: '다음', onTap: () => widget.onNext(_selected))),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StepPhone extends StatefulWidget {
  final void Function(String) onNext;
  final VoidCallback onBack;
  final bool isLoading;
  const _StepPhone(
      {required this.onNext, required this.onBack, required this.isLoading});

  @override
  State<_StepPhone> createState() => _StepPhoneState();
}

class _StepPhoneState extends State<_StepPhone> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('전화번호를\n입력해주세요'),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '010-1234-5678'),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: AppButton(
                text: '이전', filled: false, onTap: widget.onBack)),
            const SizedBox(width: 12),
            Expanded(
              child: widget.isLoading
                  ? Container(
                      height: 60,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text('가입 중...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  : AppButton(
                      text: '가입 완료',
                      onTap: () {
                        if (_controller.text.trim().isEmpty) return;
                        widget.onNext(_controller.text.trim());
                      },
                    ),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}