import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uztelecom/application/use_cases/media/build_authorized_video_headers_use_case.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/widgets/authorized_network_image.dart';

class CourseInfoMediaSection extends StatefulWidget {
  const CourseInfoMediaSection({
    super.key,
    required this.videoUrl,
    required this.photoUrl,
    required this.loaderColor,
  });

  final String? videoUrl;
  final String? photoUrl;
  final Color loaderColor;

  @override
  State<CourseInfoMediaSection> createState() => _CourseInfoMediaSectionState();
}

class _CourseInfoMediaSectionState extends State<CourseInfoMediaSection> {
  WebViewController? _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initWebVideo();
  }

  @override
  void didUpdateWidget(CourseInfoMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initWebVideo();
    }
  }

  Future<void> _initWebVideo() async {
    final videoUrl = widget.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      setState(() {
        _controller = null;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final headers = await context.read<BuildAuthorizedVideoHeadersUseCase>()();
    if (!mounted) return;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    await controller.loadRequest(Uri.parse(videoUrl), headers: headers);
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: AppColors.black,
            child: Stack(
              children: [
                if (controller != null) WebViewWidget(controller: controller),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(color: widget.loaderColor),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final photoUrl = widget.photoUrl;
    if (photoUrl == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: AuthorizedNetworkImage(url: photoUrl, fit: BoxFit.cover),
      ),
    );
  }
}
