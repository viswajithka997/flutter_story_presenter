import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/story_item.dart';
import '../story_presenter/story_view.dart';
import '../utils/story_utils.dart';
import '../utils/video_utils.dart';

class VideoStoryView extends StatefulWidget {
  final StoryItem storyItem;
  final OnVideoLoad? onVideoLoad;
  final bool? looping;

  const VideoStoryView({
    required this.storyItem,
    this.onVideoLoad,
    this.looping,
    super.key,
  });

  @override
  State<VideoStoryView> createState() => _VideoStoryViewState();
}

class _VideoStoryViewState extends State<VideoStoryView> {
  VideoPlayerController? videoPlayerController;
  bool hasError = false;

  @override
  void initState() {
    _initialiseVideoPlayer();
    super.initState();
  }

  Future<void> _initialiseVideoPlayer() async {
    try {
      final storyItem = widget.storyItem;
      if (storyItem.storyItemSource.isNetwork) {
        videoPlayerController =
            await VideoUtils.instance.videoControllerFromUrl(
          url: storyItem.url!,
          cacheFile: storyItem.videoConfig?.cacheVideo,
          videoPlayerOptions: storyItem.videoConfig?.videoPlayerOptions,
        );
      } else if (storyItem.storyItemSource.isFile) {
        videoPlayerController = VideoUtils.instance.videoControllerFromFile(
          file: File(storyItem.url!),
          videoPlayerOptions: storyItem.videoConfig?.videoPlayerOptions,
        );
      } else {
        videoPlayerController = VideoUtils.instance.videoControllerFromAsset(
          assetPath: storyItem.url!,
          videoPlayerOptions: storyItem.videoConfig?.videoPlayerOptions,
        );
      }

      await videoPlayerController?.initialize();
      widget.onVideoLoad?.call(videoPlayerController!);
      await videoPlayerController?.play();
      await videoPlayerController?.setLooping(widget.looping ?? false);
      await videoPlayerController?.setVolume(storyItem.isMuteByDefault ? 0 : 1);
    } catch (e) {
      hasError = true;
      debugPrint('$e');
    }
    setState(() {});
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.storyItem.thumbnail != null) widget.storyItem.thumbnail!,
        if (hasError && widget.storyItem.errorWidget != null)
          widget.storyItem.errorWidget!,
        if (videoPlayerController != null)
          AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(videoPlayerController!),
          ),
      ],
    );
  }
}
