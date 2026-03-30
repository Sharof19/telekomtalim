import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/widgets/status_banner.dart';

class OtpPage extends StatefulWidget {
  final String login;

  const OtpPage({super.key, required this.login});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with CodeAutoFill {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final AuthRepository _loginService = AuthRepository();
  final ProfileRepository _profileService = ProfileRepository();
  Timer? _timer;

  bool _autoValidate = false;
  bool _isLoading = false;
  int _resendSeconds = 0;
  String? _lastCopiedOtp;

  @override
  void initState() {
    super.initState();
    _startResendTimer(60);
    _startOtpAutofill();
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    _codeController.dispose();
    _loginService.dispose();
    _profileService.dispose();
    super.dispose();
  }

  Future<void> _startOtpAutofill() async {
    try {
      await SmsAutoFill().listenForCode();
    } catch (_) {
      // Ignore; manual OTP entry is still available.
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
      await _loginService.verifyCode(login: login, code: code);
      try {
        await _profileService.fetchProfile(forceRefresh: true);
      } catch (_) {
        // Login flow should continue even if profile prefetch fails.
      }
      if (!mounted) return;
      TextInput.finishAutofillContext();
      AppNavigator.replaceWithHome(context);
    } catch (e) {
      if (!mounted) return;
      await StatusBanner.show(
        context,
        success: false,
        title: tr(context, uz: 'Xatolik', ru: 'Ошибка'),
        message: _errorText(e),
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
      final resentText = tr(
        context,
        uz: 'Kod qayta yuborildi.',
        ru: 'Код отправлен повторно.',
      );
      await _loginService.resendCode(login: login);
      if (!mounted) return;
      _startResendTimer(60);
      await _startOtpAutofill();
      messenger.showSnackBar(SnackBar(content: Text(resentText)));
    } catch (e) {
      if (!mounted) return;
      await StatusBanner.show(
        context,
        success: false,
        title: tr(context, uz: 'Xatolik', ru: 'Ошибка'),
        message: _errorText(e),
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
    final raw = error.toString();
    return raw.startsWith('Exception: ')
        ? raw.replaceFirst('Exception: ', '')
        : raw;
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandBlue,
        secondary: AppColors.brandBlue,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: Colors.black87,
      ),
      iconTheme: const IconThemeData(color: AppColors.brandBlue),
    );
    return Theme(
      data: lightTheme,
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          final textPrimary = scheme.onSurface;
          final textMuted = scheme.onSurface.withValues(alpha: 0.6);
          return Scaffold(
            backgroundColor: AppColors.authBackground,
            appBar: AppBar(
              backgroundColor: AppColors.authBackground,
              elevation: 0,
              foregroundColor: textPrimary,
              title: Text(
                tr(context, uz: 'Tasdiqlash kodi', ru: 'Код подтверждения'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, uz: 'Kod kiritish', ru: 'Введите код'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr(
                        context,
                        uz: 'Kod ${_formattedLogin()} raqamiga yuborildi.',
                        ru: 'Код отправлен на номер ${_formattedLogin()}.',
                      ),
                      style: TextStyle(fontSize: 13, color: textMuted),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autoValidate
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _codeController,
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
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.authBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.authBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: scheme.primary,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                final digits = (value ?? '').trim();
                                if (digits.isEmpty) {
                                  return tr(
                                    context,
                                    uz: 'Kod kiriting.',
                                    ru: 'Введите код.',
                                  );
                                }
                                if (digits.length < 6) {
                                  return tr(
                                    context,
                                    uz: "Kod 6 ta raqamdan iborat bo'lsin.",
                                    ru: 'Код должен состоять из 6 цифр.',
                                  );
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _verifyCode(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _verifyCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            scheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        tr(
                                          context,
                                          uz: 'Tasdiqlash',
                                          ru: 'Подтвердить',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _resendSeconds > 0
                                  ? null
                                  : _resendCode,
                              child: Text(
                                _resendSeconds > 0
                                    ? tr(
                                        context,
                                        uz: 'Qayta yuborish ($_resendSeconds)',
                                        ru: 'Отправить повторно ($_resendSeconds)',
                                      )
                                    : tr(
                                        context,
                                        uz: 'Qayta yuborish',
                                        ru: 'Отправить повторно',
                                      ),
                                style: TextStyle(
                                  color: textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
