import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_video_controls.dart';

class CourseVideoFullscreenPage extends StatefulWidget {
  const CourseVideoFullscreenPage({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  State<CourseVideoFullscreenPage> createState() =>
      _CourseVideoFullscreenPageState();
}

class _CourseVideoFullscreenPageState extends State<CourseVideoFullscreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.isInitialized
                    ? controller.value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(controller),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 8,
              child: CourseVideoControls(
                controller: controller,
                onFullscreen: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
