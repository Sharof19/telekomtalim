import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_form_card.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_page_theme.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_primary_button.dart';

class OtpFormCard extends StatelessWidget {
  const OtpFormCard({
    super.key,
    required this.formKey,
    required this.codeController,
    required this.autoValidate,
    required this.isLoading,
    required this.resendSeconds,
    required this.textMuted,
    required this.onVerify,
    required this.onResend,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final bool autoValidate;
  final bool isLoading;
  final int resendSeconds;
  final Color textMuted;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AuthFormCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Form(
        key: formKey,
        autovalidateMode: autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          children: [
            TextFormField(
              controller: codeController,
              autofillHints: const [AutofillHints.oneTimeCode],
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontSize: 20,
                letterSpacing: 12,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(
                  fontSize: 20,
                  letterSpacing: 12,
                  color: textMuted,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: AuthPageTheme.inputBorder(),
                enabledBorder: AuthPageTheme.inputBorder(),
                focusedBorder: AuthPageTheme.focusedInputBorder(scheme.primary),
              ),
              validator: (value) {
                final digits = (value ?? '').trim();
                if (digits.isEmpty) {
                  return tr(context, TrKey.kodKiriting);
                }
                if (digits.length < 6) {
                  return tr(context, TrKey.kod6TaRaqamdanIborat);
                }
                return null;
              },
              onFieldSubmitted: (_) => onVerify(),
            ),
            const SizedBox(height: 16),
            AuthPrimaryButton(
              label: tr(context, TrKey.tasdiqlash),
              onPressed: onVerify,
              isLoading: isLoading,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: resendSeconds > 0 ? null : onResend,
              child: Text(
                resendSeconds > 0
                    ? tr(
                        context,
                        TrKey.qaytaYuborish,
                        params: {'p1': resendSeconds},
                      )
                    : tr(context, TrKey.qaytaYuborish2),
                style: TextStyle(color: textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
