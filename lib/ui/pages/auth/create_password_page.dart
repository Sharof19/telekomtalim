import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/auth/create_password_use_case.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_backdrop.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_form_card.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_page_theme.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_primary_button.dart';
import 'package:uztelecom/ui/widgets/status_banner.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final CreatePasswordUseCase _createPassword;

  bool _isLoading = false;
  bool _autoValidate = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _createPassword = context.read<CreatePasswordUseCase>();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      if (!_autoValidate) {
        setState(() => _autoValidate = true);
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _createPassword(
        newPassword: _passwordController.text.trim(),
        confirmPassword: _confirmController.text.trim(),
      );
      if (!mounted) return;
      AppNavigator.replaceWithHome(context);
    } catch (e) {
      if (!mounted) return;
      await StatusBanner.show(
        context,
        success: false,
        title: tr(context, TrKey.xatolik2),
        message: appFailureMessage(e),
        normalizeNetworkMessage: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuthPageTheme.light(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              const AuthBackdrop(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final keyboard = MediaQuery.of(context).viewInsets.bottom;
                    return AnimatedPadding(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 16 + keyboard),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - keyboard - 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 28),
                              const Text(
                                'Parol yarating',
                                style: TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'HRM orqali kirish yakunlandi. Davom etish uchun yangi parol qo‘ying.',
                                style: TextStyle(
                                  color: AppColors.lightText.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontSize: 15,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              AuthFormCard(
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: _autoValidate
                                      ? AutovalidateMode.onUserInteraction
                                      : AutovalidateMode.disabled,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.next,
                                        decoration: _decoration(
                                          context,
                                          label: 'Yangi parol',
                                          obscure: _obscurePassword,
                                          onToggle: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        validator: _passwordValidator,
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _confirmController,
                                        obscureText: _obscureConfirm,
                                        textInputAction: TextInputAction.done,
                                        decoration: _decoration(
                                          context,
                                          label: 'Parolni tasdiqlang',
                                          obscure: _obscureConfirm,
                                          onToggle: () {
                                            setState(() {
                                              _obscureConfirm =
                                                  !_obscureConfirm;
                                            });
                                          },
                                        ),
                                        validator: (value) {
                                          final text = value?.trim() ?? '';
                                          if (text.isEmpty) {
                                            return 'Parolni qayta kiriting.';
                                          }
                                          if (text !=
                                              _passwordController.text.trim()) {
                                            return 'Parollar mos kelmadi.';
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) => _submit(),
                                      ),
                                      const SizedBox(height: 18),
                                      AuthPrimaryButton(
                                        label: 'Saqlash',
                                        onPressed: _submit,
                                        isLoading: _isLoading,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return AuthPageTheme.inputDecoration(
      label: label,
      icon: Icons.lock_outline_rounded,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
      ),
    );
  }

  String? _passwordValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Yangi parol kiriting.';
    }
    if (text.length < 8) {
      return 'Parol kamida 8 ta belgidan iborat bo‘lsin.';
    }
    return null;
  }
}
