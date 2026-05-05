import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_form_card.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_page_theme.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_primary_button.dart';
import 'package:uztelecom/ui/pages/auth/widgets/phone_number_formatter.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    required this.autoValidate,
    required this.obscurePassword,
    required this.isLoading,
    required this.isHrmLoading,
    required this.onSubmit,
    required this.onHrmLogin,
    required this.onForgotPassword,
    required this.onTogglePasswordVisibility,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool autoValidate;
  final bool obscurePassword;
  final bool isLoading;
  final bool isHrmLoading;
  final VoidCallback onSubmit;
  final VoidCallback onHrmLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onTogglePasswordVisibility;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AuthFormCard(
      child: Form(
        key: formKey,
        autovalidateMode: autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          children: [
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
                const PhoneNumberFormatter(maxDigits: 9),
              ],
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context: context,
                label: tr(context, TrKey.phoneNumber),
                hint: '-- --- -- --',
                icon: Icons.phone_iphone,
                prefixText: '+998 ',
              ),
              cursorColor: AppColors.brandBlue,
              validator: (value) {
                final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                if (digits.isEmpty) {
                  return tr(context, TrKey.telefonRaqamKiriting);
                }
                if (digits.length < 9) {
                  return tr(context, TrKey.telefonRaqam9TaRaqamdan);
                }
                return null;
              },
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(
                context: context,
                label: tr(context, TrKey.password),
                hint: tr(context, TrKey.parolingizniKiriting),
                icon: Icons.key_rounded,
                suffixIcon: IconButton(
                  onPressed: onTogglePasswordVisibility,
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: scheme.primary,
                  ),
                ),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return tr(context, TrKey.parolKiriting);
                }
                return null;
              },
              cursorColor: AppColors.brandBlue,
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                child: Text(
                  tr(context, TrKey.parolniUnutdingizmi),
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AuthPrimaryButton(
              label: tr(context, TrKey.kirish),
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
            const SizedBox(height: 22),
            _AuthDivider(label: tr(context, TrKey.orRegisterVia)),
            const SizedBox(height: 14),
            _HrmLoginButton(
              label: tr(context, TrKey.loginViaHrm),
              isLoading: isHrmLoading,
              onPressed: onHrmLogin,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return AuthPageTheme.inputDecoration(
      label: label,
      hint: hint,
      icon: icon,
      prefixText: prefixText?.trim(),
      suffixIcon: suffixIcon,
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.4);
    return Row(
      children: [
        Expanded(child: Divider(color: muted, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: muted, height: 1)),
      ],
    );
  }
}

class _HrmLoginButton extends StatelessWidget {
  const _HrmLoginButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.32)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
