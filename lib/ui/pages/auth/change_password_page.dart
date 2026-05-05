import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/auth/change_password_use_case.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_backdrop.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_form_card.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_page_theme.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_primary_button.dart';
import 'package:uztelecom/ui/widgets/status_banner.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final ChangePasswordUseCase _changePassword;
  bool _isLoading = false;
  bool _autoValidate = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _changePassword = context.read<ChangePasswordUseCase>();
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
      if (!_autoValidate) setState(() => _autoValidate = true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _changePassword(
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
      if (mounted) setState(() => _isLoading = false);
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yangi parol',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hisobingiz uchun yangi parol yarating.',
                        style: TextStyle(
                          color: AppColors.lightText.withValues(alpha: 0.62),
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthFormCard(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autoValidate
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              _PasswordField(
                                controller: _passwordController,
                                label: 'Yangi parol',
                                obscure: _obscurePassword,
                                onToggle: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                validator: _passwordValidator,
                              ),
                              const SizedBox(height: 14),
                              _PasswordField(
                                controller: _confirmController,
                                label: 'Parolni tasdiqlang',
                                obscure: _obscureConfirm,
                                onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                onSubmitted: _submit,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Parolni qayta kiriting.';
                                  }
                                  if (text != _passwordController.text.trim()) {
                                    return 'Parollar mos kelmadi.';
                                  }
                                  return null;
                                },
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
            ],
          ),
        ),
      ),
    );
  }

  String? _passwordValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Yangi parol kiriting.';
    if (text.length < 8) return 'Parol kamida 8 ta belgidan iborat bo‘lsin.';
    return null;
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      decoration: AuthPageTheme.inputDecoration(
        label: label,
        icon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: validator,
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
