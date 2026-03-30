import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/widgets/status_banner.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthRepository _loginService = AuthRepository();
  bool _autoValidate = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _loginService.dispose();
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

    setState(() {
      _isLoading = true;
    });

    final login = _normalizeLogin(_phoneController.text);
    final password = _passwordController.text;

    try {
      await _loginService.requestLogin(login: login, password: password);
      if (!mounted) return;
      AppNavigator.replaceWithOtp(context, login: login);
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

  void _skip() {
    AppNavigator.replaceWithHome(context);
  }

  String _normalizeLogin(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
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
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brandBlue,
        selectionColor: Color(0x33396495),
        selectionHandleColor: AppColors.brandBlue,
      ),
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
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  Positioned(
                    top: -140,
                    right: -120,
                    child: _BackdropCircle(
                      size: 260,
                      color: AppColors.brandBlue.withValues(alpha: 0.12),
                    ),
                  ),
                  Positioned(
                    bottom: -120,
                    left: -100,
                    child: _BackdropCircle(
                      size: 220,
                      color: AppColors.brandBlue.withValues(alpha: 0.08),
                    ),
                  ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final keyboard = MediaQuery.of(
                          context,
                        ).viewInsets.bottom;
                        final isKeyboardOpen = keyboard > 0;
                        return AnimatedPadding(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            16 + keyboard,
                          ),
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - keyboard,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isKeyboardOpen)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 8,
                                        ),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Image.asset(
                                            'assets/images/logo2.png',
                                            width: 220,
                                            height: 64,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: isKeyboardOpen ? 4 : 6),
                                    Text(
                                      tr(context, uz: 'Kirish', ru: 'Вход'),
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: isKeyboardOpen ? 2 : 6),
                                    SizedBox(height: isKeyboardOpen ? 10 : 24),
                                    _buildFormCard(context),
                                    const SizedBox(height: 10),
                                    if (!isKeyboardOpen)
                                      Align(
                                        alignment: Alignment.center,
                                        child: TextButton(
                                          onPressed: _skip,
                                          child: Text(
                                            tr(
                                              context,
                                              uz: 'Keyinroq',
                                              ru: 'Позже',
                                            ),
                                            style: TextStyle(
                                              color: textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final cardBg = Colors.white;
    final shadowColor = Colors.black.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 22,
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
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
                _PhoneNumberFormatter(maxDigits: 9),
              ],
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context: context,
                label: tr(context, uz: 'Telefon raqam', ru: 'Телефон'),
                hint: '-- --- -- --',
                icon: Icons.phone_iphone,
                prefixText: '+998 ',
              ),
              cursorColor: AppColors.brandBlue,
              validator: (value) {
                final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                if (digits.isEmpty) {
                  return tr(
                    context,
                    uz: 'Telefon raqam kiriting.',
                    ru: 'Введите номер телефона.',
                  );
                }
                if (digits.length < 9) {
                  return tr(
                    context,
                    uz: "Telefon raqam 9 ta raqamdan iborat bo'lsin.",
                    ru: 'Номер телефона должен содержать 9 цифр.',
                  );
                }
                return null;
              },
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(
                context: context,
                label: tr(context, uz: 'Parol', ru: 'Пароль'),
                hint: tr(
                  context,
                  uz: 'Parolingizni kiriting',
                  ru: 'Введите пароль',
                ),
                icon: Icons.key_rounded,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return tr(
                    context,
                    uz: 'Parol kiriting.',
                    ru: 'Введите пароль.',
                  );
                }
                return null;
              },
              cursorColor: AppColors.brandBlue,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  tr(
                    context,
                    uz: 'Parolni unutdingizmi?',
                    ru: 'Забыли пароль?',
                  ),
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        tr(context, uz: 'Kirish', ru: 'Вход'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
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
    final scheme = Theme.of(context).colorScheme;
    final borderColor = AppColors.authBorder;
    final fillColor = Colors.white;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.75)),
      floatingLabelStyle: const TextStyle(color: AppColors.brandBlue),
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 16,
        color: scheme.onSurface.withValues(alpha: 0.5),
      ),
      prefixText: prefixText,
      prefixStyle: TextStyle(
        fontSize: 16,
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: AppColors.brandBlue),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.4),
      ),
      focusColor: AppColors.brandBlue,
      hoverColor: AppColors.brandBlue,
      prefixIconColor: AppColors.brandBlue,
      suffixIconColor: AppColors.brandBlue,
      iconColor: AppColors.brandBlue,
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.4),
      ),
    );
  }
}

class _BackdropCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackdropCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  final int maxDigits;
  static const List<int> _groups = [2, 3, 2, 2];

  const _PhoneNumberFormatter({required this.maxDigits});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digitsOnly.length > maxDigits
        ? digitsOnly.substring(0, maxDigits)
        : digitsOnly;
    final formatted = _formatGroups(limited);
    final digitsBeforeCursor = _countDigits(
      newValue.text.substring(0, newValue.selection.end),
    );
    final selectionIndex = _selectionIndex(formatted, digitsBeforeCursor);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: TextRange.empty,
    );
  }

  String _formatGroups(String digits) {
    final buffer = StringBuffer();
    var index = 0;
    for (final size in _groups) {
      if (index >= digits.length) break;
      final end = (index + size).clamp(0, digits.length);
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(digits.substring(index, end));
      index = end;
    }
    if (index < digits.length) {
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(digits.substring(index));
    }
    return buffer.toString();
  }

  int _countDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '').length;
  }

  int _selectionIndex(String formatted, int digitsBeforeCursor) {
    if (digitsBeforeCursor <= 0) return 0;
    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitsSeen++;
        if (digitsSeen == digitsBeforeCursor) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }
}
