import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/media/build_authorized_video_headers_use_case.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_video_controls.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_video_fullscreen_page.dart';
import 'package:uztelecom/ui/widgets/authorized_network_image.dart';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _controller;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(CourseInfoMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final oldController = _controller;
    _controller = null;
    _videoError = null;
    oldController?.dispose();

    final videoUrl = widget.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    setState(() {});
    try {
      final headers = await context
          .read<BuildAuthorizedVideoHeadersUseCase>()();
      if (!mounted) return;
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: headers,
        viewType: VideoViewType.platformView,
      );
      controller.addListener(() {
        final error = controller.value.errorDescription;
        if (error != null && error.isNotEmpty && mounted) {
          if (_videoError != error) setState(() => _videoError = error);
        }
      });
      _controller = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _videoError = appFailureMessage(e));
    }
  }

  Future<void> _openFullscreen() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await AppNavigator.pushPage<void>(
      context,
      builder: (_) => CourseVideoFullscreenPage(controller: controller),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
              alignment: Alignment.center,
              children: [
                if (_videoError != null)
                  Center(
                    child: Text(
                      tr(context, TrKey.videoYuklanmadi),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (controller != null && controller.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  )
                else
                  Center(
                    child: CircularProgressIndicator(color: widget.loaderColor),
                  ),
                if (controller != null && controller.value.isInitialized)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: CourseVideoControls(
                      controller: controller,
                      onFullscreen: _openFullscreen,
                    ),
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
