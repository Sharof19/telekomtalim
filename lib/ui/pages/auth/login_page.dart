import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/auth/complete_hrm_login_use_case.dart';
import 'package:uztelecom/application/use_cases/auth/request_login_use_case.dart';
import 'package:uztelecom/application/use_cases/auth/start_hrm_login_use_case.dart';
import 'package:uztelecom/core/config/app_assets.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/pages/auth/hrm_login_page.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_backdrop.dart';
import 'package:uztelecom/ui/pages/auth/widgets/auth_page_theme.dart';
import 'package:uztelecom/ui/pages/auth/widgets/login_intro_section.dart';
import 'package:uztelecom/ui/pages/auth/widgets/login_form_card.dart';
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
  late final RequestLoginUseCase _requestLogin;
  late final StartHrmLoginUseCase _startHrmLogin;
  late final CompleteHrmLoginUseCase _completeHrmLogin;
  bool _autoValidate = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isHrmLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLogin = context.read<RequestLoginUseCase>();
    _startHrmLogin = context.read<StartHrmLoginUseCase>();
    _completeHrmLogin = context.read<CompleteHrmLoginUseCase>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
        const ResizeImage(AssetImage(AppAssets.uztelecomLoginLogo), width: 660),
        context,
      );
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
      await _requestLogin(login: login, password: password);
      if (!mounted) return;
      AppNavigator.replaceWithOtp(context, login: login);
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

  Future<void> _submitHrmLogin() async {
    if (_isHrmLoading) return;

    setState(() {
      _isHrmLoading = true;
    });

    try {
      final hrmRequest = await _startHrmLogin();
      if (!mounted) return;
      final result = await AppNavigator.pushPage<HrmLoginResult>(
        context,
        builder: (_) => HrmLoginPage(
          authorizeUri: hrmRequest.authorizeUri,
          redirectUri: hrmRequest.redirectUri,
        ),
      );
      if (!mounted || result == null) return;
      if (hrmRequest.state != null && result.state != hrmRequest.state) {
        throw const FormatException('HRM state mos kelmadi.');
      }
      final profile = await _completeHrmLogin(
        code: result.code,
        redirectUri: hrmRequest.redirectUri,
        state: result.state ?? hrmRequest.state ?? '',
      );
      if (!mounted) return;
      if (profile?.passwordCreated == false) {
        AppNavigator.replaceWithCreatePassword(context);
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
        setState(() => _isHrmLoading = false);
      }
    }
  }

  String _normalizeLogin(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
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
          return Scaffold(
            backgroundColor: AppColors.white,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  const AuthBackdrop(),
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
                                    LoginIntroSection(
                                      isKeyboardOpen: isKeyboardOpen,
                                      title: tr(context, TrKey.kirish),
                                      titleColor: textPrimary,
                                    ),
                                    LoginFormCard(
                                      formKey: _formKey,
                                      phoneController: _phoneController,
                                      passwordController: _passwordController,
                                      autoValidate: _autoValidate,
                                      obscurePassword: _obscurePassword,
                                      isLoading: _isLoading,
                                      isHrmLoading: _isHrmLoading,
                                      onSubmit: _submit,
                                      onHrmLogin: _submitHrmLogin,
                                      onForgotPassword: () {
                                        AppNavigator.pushForgotPassword(
                                          context,
                                        );
                                      },
                                      onTogglePasswordVisibility: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
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
}
