import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/auth/forgot_password_use_case.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_page_theme.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_primary_button.dart';
import 'package:uztelecom/ui/pages/auth/widgets/phone_number_formatter.dart';
import 'package:uztelecom/ui/widgets/status_banner.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late final ForgotPasswordUseCase _forgotPassword;
  bool _isLoading = false;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _forgotPassword = context.read<ForgotPasswordUseCase>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
    final phone = _normalizePhone(_phoneController.text);
    try {
      await _forgotPassword(phone: phone);
      if (!mounted) return;
      AppNavigator.replaceWithOtp(context, login: phone, resetPassword: true);
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
        backgroundColor: const Color(0xFFF7F9FC),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = (constraints.maxHeight * 0.22)
                    .clamp(132.0, 220.0)
                    .toDouble();
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(18, topPadding, 18, 18),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 380),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x160F172A),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autoValidate
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Parolni unutdingizmi?',
                              style: TextStyle(
                                color: AppColors.lightText,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Telefon raqamingizni kiriting, parolni tiklashda yordam beramiz.',
                              style: TextStyle(
                                color: AppColors.lightText.withValues(
                                  alpha: 0.72,
                                ),
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 34),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                                const PhoneNumberFormatter(maxDigits: 9),
                              ],
                              textInputAction: TextInputAction.done,
                              decoration: AuthPageTheme.inputDecoration(
                                label: tr(context, TrKey.phoneNumber),
                                hint: '-- --- -- --',
                                icon: Icons.phone_iphone,
                                prefixText: '+998',
                              ),
                              validator: (value) {
                                final digits = _normalizePhone(value ?? '');
                                if (digits.isEmpty) {
                                  return tr(
                                    context,
                                    TrKey.telefonRaqamKiriting,
                                  );
                                }
                                if (digits.length < 9) {
                                  return tr(
                                    context,
                                    TrKey.telefonRaqam9TaRaqamdan,
                                  );
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 36),
                            AuthPrimaryButton(
                              label: 'Yuborish',
                              onPressed: _submit,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _normalizePhone(String value) => value.replaceAll(RegExp(r'\D'), '');
}
