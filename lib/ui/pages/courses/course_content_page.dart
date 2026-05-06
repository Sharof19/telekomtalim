import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/media/build_authorized_video_headers_use_case.dart';
import 'package:uztelecom/core/config/app_config.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContentWebviewPage extends StatefulWidget {
  final String url;
  final String title;
  final String? fallbackVideoUrl;

  const ContentWebviewPage({
    super.key,
    required this.url,
    required this.title,
    this.fallbackVideoUrl,
  });

  @override
  State<ContentWebviewPage> createState() => _ContentWebviewPageState();
}

class _ContentWebviewPageState extends State<ContentWebviewPage> {
  late final BuildAuthorizedVideoHeadersUseCase _buildVideoHeaders;
  late final WebViewController _controller;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  String? _videoError;
  late final String _normalizedUrl;

  @override
  void initState() {
    super.initState();
    _buildVideoHeaders = context.read<BuildAuthorizedVideoHeadersUseCase>();
    _normalizedUrl = _normalizeUrl(widget.url);
    if (_looksLikeVideo(_normalizedUrl)) {
      _isVideo = true;
      _initVideo(_normalizedUrl);
      return;
    }
    final bg = AppColors.transparent;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_looksLikeVideo(request.url)) {
              _openVideoPlayer(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {});
            }
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
    _loadWebContent();
  }

  Future<void> _loadWebContent() async {
    final headers = await _buildVideoHeaders();
    await _controller.loadRequest(Uri.parse(_normalizedUrl), headers: headers);
  }

  String _normalizeUrl(String url) {
    return AppConfig.absoluteUrl(url) ?? url;
  }

  bool _looksLikeVideo(String value) {
    final lower = value.toLowerCase();
    return lower.contains('.mp4') ||
        lower.contains('.m3u8') ||
        lower.contains('.webm') ||
        lower.contains('.mov') ||
        lower.contains('.mkv');
  }

  Future<void> _initVideo(String url) async {
    try {
      final headers = await _buildVideoHeaders();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: headers,
        viewType: VideoViewType.platformView,
      );
      controller.addListener(() {
        final error = controller.value.errorDescription;
        if (error != null && error.isNotEmpty && mounted) {
          if (_videoError != error) {
            setState(() => _videoError = error);
          }
        }
      });
      _videoController = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _videoError = appFailureMessage(e));
    }
  }

  Future<void> _openFullscreen() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    await AppNavigator.pushPage<void>(
      context,
      builder: (_) => _VideoFullscreenPage(controller: controller),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openVideoPlayer(String url) async {
    final normalized = _normalizeUrl(url);
    if (!mounted) return;
    await AppNavigator.pushPage<void>(
      context,
      builder: (_) => _ContentVideoPage(url: normalized, title: widget.title),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    if (!_isVideo) {
      _controller.setBackgroundColor(bg);
    }
    return Scaffold(
      backgroundColor: bg,
      body: _isVideo ? _buildVideoBody(context) : _buildWebBody(),
    );
  }

  Widget _buildWebBody() {
    return WebViewWidget(controller: _controller);
  }

  Widget _buildVideoBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = _videoController;
    if (controller == null) {
      return Center(child: CircularProgressIndicator(color: scheme.primary));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: controller.value.isInitialized
                  ? controller.value.aspectRatio
                  : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_videoError != null)
                    Center(
                      child: Text(
                        'Video yuklanmadi.',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (controller.value.isInitialized)
                    VideoPlayer(controller)
                  else
                    const Center(child: CircularProgressIndicator()),
                  if (controller.value.isInitialized)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: _VideoControls(
                        controller: controller,
                        onFullscreen: _openFullscreen,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onFullscreen;

  const _VideoControls({required this.controller, this.onFullscreen});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        final position = value.position;
        final duration = value.duration;
        final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;
        final posMs = position.inMilliseconds.clamp(0, maxMs);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.brandBlue,
                  size: 20,
                ),
                onPressed: () {
                  if (value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(position),
                style: const TextStyle(
                  color: AppColors.brandBlue,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: posMs.toDouble(),
                    min: 0,
                    max: maxMs.toDouble(),
                    onChanged: (v) {
                      controller.seekTo(Duration(milliseconds: v.toInt()));
                    },
                    activeColor: AppColors.brandBlue,
                    inactiveColor: AppColors.courseVideoAccentFaint,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(duration),
                style: const TextStyle(
                  color: AppColors.courseVideoAccentMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.volume_up, color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 6),
              if (onFullscreen != null)
                InkWell(
                  onTap: onFullscreen,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.fullscreen,
                      color: AppColors.brandBlue,
                      size: 26,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _VideoFullscreenPage extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoFullscreenPage({required this.controller});

  @override
  State<_VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<_VideoFullscreenPage> {
  @override
  Widget build(BuildContext context) {
    final bg = AppColors.black;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.isInitialized
                    ? widget.controller.value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(widget.controller),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: _VideoControls(
                controller: widget.controller,
                onFullscreen: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentVideoPage extends StatefulWidget {
  final String url;
  final String title;

  const _ContentVideoPage({required this.url, required this.title});

  @override
  State<_ContentVideoPage> createState() => _ContentVideoPageState();
}

class _ContentVideoPageState extends State<_ContentVideoPage> {
  late final BuildAuthorizedVideoHeadersUseCase _buildVideoHeaders;
  VideoPlayerController? _controller;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _buildVideoHeaders = context.read<BuildAuthorizedVideoHeadersUseCase>();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final headers = await _buildVideoHeaders();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: headers,
        viewType: VideoViewType.platformView,
      );
      controller.addListener(() {
        final error = controller.value.errorDescription;
        if (error != null && error.isNotEmpty && mounted) {
          if (_videoError != error) {
            setState(() => _videoError = error);
          }
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
      builder: (_) => _VideoFullscreenPage(controller: controller),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final controller = _controller;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: controller?.value.isInitialized == true
                ? controller!.value.aspectRatio
                : 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_videoError != null)
                  const Center(
                    child: Text(
                      'Video yuklanmadi.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (controller?.value.isInitialized == true)
                  VideoPlayer(controller!)
                else
                  Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                if (controller?.value.isInitialized == true)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: _VideoControls(
                      controller: controller!,
                      onFullscreen: _openFullscreen,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
