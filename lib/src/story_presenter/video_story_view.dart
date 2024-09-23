import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import '../../flutter_story_presenter.dart';

/// A widget that displays a video story view, supporting different video sources
/// (network, file, asset) and optional thumbnail and error widgets.
class VideoStoryView extends StatefulWidget {
  /// The story item containing video data and configuration.
  final StoryItem storyItem;

  /// Callback function to notify when the video is loaded.
  final OnVideoLoad? onVideoLoad;

  /// In case of single video story
  final bool? looping;

  /// Creates a [VideoStoryView] widget.
  const VideoStoryView(
      {required this.storyItem, this.onVideoLoad, this.looping, super.key});

  @override
  State<VideoStoryView> createState() => _VideoStoryViewState();
}

class _VideoStoryViewState extends State<VideoStoryView> {
  BetterPlayerController? _betterPlayerController;
  bool hasError = false;

  @override
  void initState() {
    _initializeBetterPlayer();
    super.initState();
  }

  /// Initializes the BetterPlayer controller based on the source of the video.
  Future<void> _initializeBetterPlayer() async {
    try {
      final storyItem = widget.storyItem;
      BetterPlayerDataSource? dataSource;

      if (storyItem.storyItemSource.isNetwork) {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          storyItem.url!,
          cacheConfiguration: storyItem.videoConfig?.cacheVideo != null
              ? const BetterPlayerCacheConfiguration(useCache: true)
              : null,
        );
      } else if (storyItem.storyItemSource.isFile) {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          storyItem.url!,
        );
      }

      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          looping: widget.looping ?? false,
          fit: storyItem.videoConfig?.fit ?? BoxFit.cover,
          autoPlay: true,
          autoDispose: true,
          aspectRatio: storyItem.videoConfig?.useVideoAspectRatio ?? false
              ? null
              : 16 / 9, // Example aspect ratio, adjust as needed
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false, // Hide controls by default
          ),
        ),
        betterPlayerDataSource: dataSource,
      );

      widget.onVideoLoad?.call(_betterPlayerController!);
      _betterPlayerController!.setVolume(storyItem.isMuteByDefault ? 0 : 1);
    } catch (e) {
      hasError = true;
      debugPrint('$e');
    }
    setState(() {});
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: (widget.storyItem.videoConfig?.fit == BoxFit.cover)
          ? Alignment.topCenter
          : Alignment.center,
      fit: (widget.storyItem.videoConfig?.fit == BoxFit.cover)
          ? StackFit.expand
          : StackFit.loose,
      children: [
        if (widget.storyItem.thumbnail != null) ...{
          widget.storyItem.thumbnail!,
        },
        if (widget.storyItem.errorWidget != null && hasError) ...{
          widget.storyItem.errorWidget!,
        },
        if (_betterPlayerController != null) ...{
          AspectRatio(
            aspectRatio: _betterPlayerController!
                    .betterPlayerConfiguration.aspectRatio ??
                _betterPlayerController!
                    .videoPlayerController!.value.aspectRatio,
            child: BetterPlayer(controller: _betterPlayerController!),
          ),
        }
      ],
    );
  }
}
