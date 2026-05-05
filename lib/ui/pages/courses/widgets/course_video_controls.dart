import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class CourseVideoControls extends StatelessWidget {
  const CourseVideoControls({
    super.key,
    required this.controller,
    this.onFullscreen,
  });

  final VideoPlayerController controller;
  final VoidCallback? onFullscreen;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final duration = value.duration;
        final position = value.position;
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
