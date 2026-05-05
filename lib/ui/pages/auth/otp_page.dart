import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uztelecom/application/use_cases/auth/forgot_password_use_case.dart';
import 'package:uztelecom/application/use_cases/auth/resend_otp_use_case.dart';
import 'package:uztelecom/application/use_cases/auth/verify_otp_use_case.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_page_theme.dart';
import 'package:uztelecom/ui/pages/auth/widgets/otp_intro_section.dart';
import 'package:uztelecom/ui/pages/auth/widgets/otp_form_card.dart';
import 'package:uztelecom/ui/widgets/status_banner.dart';

class OtpPage extends StatefulWidget {
  final String login;
  final bool resetPassword;

  const OtpPage({super.key, required this.login, this.resetPassword = false});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with CodeAutoFill {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  late final VerifyOtpUseCase _verifyOtp;
  late final ResendOtpUseCase _resendOtp;
  late final ForgotPasswordUseCase _forgotPassword;
  Timer? _timer;

  bool _autoValidate = false;
  bool _isLoading = false;
  int _resendSeconds = 0;
  String? _lastCopiedOtp;

  @override
  void initState() {
    super.initState();
    _verifyOtp = context.read<VerifyOtpUseCase>();
    _resendOtp = context.read<ResendOtpUseCase>();
    _forgotPassword = context.read<ForgotPasswordUseCase>();
    _startResendTimer(60);
    _startOtpAutofill();
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _startOtpAutofill() async {
    try {
      await SmsAutoFill().listenForCode();
    } catch (error, stackTrace) {
      // Ignore; manual OTP entry is still available.
      AppLogger.warning(
        'Failed to start OTP autofill listener.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void codeUpdated() {
    if (!mounted) return;
    final value = code?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (value.isEmpty) return;
    final normalized = value.length > 6 ? value.substring(0, 6) : value;
    if (_codeController.text != normalized) {
      _codeController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
    if (normalized.length == 6) {
      final isAndroid =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
      if (isAndroid && _lastCopiedOtp != normalized) {
        Clipboard.setData(ClipboardData(text: normalized));
        _lastCopiedOtp = normalized;
      }
      _verifyCode();
    }
  }

  void _startResendTimer(int seconds) {
    _timer?.cancel();
    setState(() => _resendSeconds = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  Future<void> _verifyCode() async {
    if (_isLoading) return;
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) {
      if (!_autoValidate) {
        setState(() => _autoValidate = true);
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final login = _normalizeLogin(widget.login);
    final code = _codeController.text.trim();

    try {
      await _verifyOtp(login: login, code: code);
      if (!mounted) return;
      TextInput.finishAutofillContext();
      if (widget.resetPassword) {
        AppNavigator.replaceWithChangePassword(context);
        return;
      }
      AppNavigator.replaceWithHome(context);
    } catch (e) {
      if (!mounted) return;
      await StatusBanner.show(
        context,
        success: false,
        title: tr(context, TrKey.xatolik2),
        message: _errorText(e),
        normalizeNetworkMessage: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    if (_resendSeconds > 0 || _isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final login = _normalizeLogin(widget.login);

    try {
      final messenger = ScaffoldMessenger.of(context);
      final resentText = tr(context, TrKey.kodQaytaYuborildi);
      if (widget.resetPassword) {
        await _forgotPassword(phone: login);
      } else {
        await _resendOtp(login: login);
      }
      if (!mounted) return;
      _startResendTimer(60);
      await _startOtpAutofill();
      messenger.showSnackBar(SnackBar(content: Text(resentText)));
    } catch (e) {
      if (!mounted) return;
      await StatusBanner.show(
        context,
        success: false,
        title: tr(context, TrKey.xatolik2),
        message: _errorText(e),
        normalizeNetworkMessage: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _normalizeLogin(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _formattedLogin() {
    final digits = _normalizeLogin(widget.login);
    if (digits.length != 9) return digits;
    return '${digits.substring(0, 2)} '
        '${digits.substring(2, 5)} '
        '${digits.substring(5, 7)} '
        '${digits.substring(7, 9)}';
  }

  String _errorText(Object error) {
    return appFailureMessage(error);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuthPageTheme.light(),
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          final textPrimary = scheme.onSurface;
          final textMuted = scheme.onSurface.withValues(alpha: 0.6);
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              foregroundColor: textPrimary,
              title: Text(
                tr(context, TrKey.verificationCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OtpIntroSection(
                      title: tr(context, TrKey.enterCode),
                      subtitle: tr(
                        context,
                        TrKey.kodRaqamigaYuborildi,
                        params: {'p1': _formattedLogin()},
                      ),
                      titleColor: textPrimary,
                      subtitleColor: textMuted,
                    ),
                    const SizedBox(height: 24),
                    OtpFormCard(
                      formKey: _formKey,
                      codeController: _codeController,
                      autoValidate: _autoValidate,
                      isLoading: _isLoading,
                      resendSeconds: _resendSeconds,
                      textMuted: textMuted,
                      onVerify: _verifyCode,
                      onResend: _resendCode,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
