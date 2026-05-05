import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HrmLoginResult {
  const HrmLoginResult({required this.code, this.state});

  final String code;
  final String? state;
}

class HrmLoginPage extends StatefulWidget {
  const HrmLoginPage({
    super.key,
    required this.authorizeUri,
    required this.redirectUri,
  });

  final Uri authorizeUri;
  final String redirectUri;

  @override
  State<HrmLoginPage> createState() => _HrmLoginPageState();
}

class _HrmLoginPageState extends State<HrmLoginPage> {
  static const double _webViewTopCrop = 200;

  late final WebViewController _controller;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigation,
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(widget.authorizeUri);
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (!request.url.startsWith(widget.redirectUri)) {
      return NavigationDecision.navigate;
    }

    final uri = Uri.parse(request.url);
    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      Navigator.of(
        context,
      ).pop(HrmLoginResult(code: code, state: uri.queryParameters['state']));
    } else {
      Navigator.of(context).pop();
    }
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -_webViewTopCrop,
            bottom: 0,
            child: WebViewWidget(controller: _controller),
          ),
          Positioned(
            left: 4,
            top: MediaQuery.paddingOf(context).top + 2,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              color: AppColors.black,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              style: IconButton.styleFrom(
                backgroundColor: bg.withValues(alpha: 0.86),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.brandBlue),
            ),
        ],
      ),
    );
  }
}
