import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoUtils {
  VideoUtils._();

  // Cache manager to handle caching of video files.
  final _cacheManager = DefaultCacheManager();

  // Singleton instance of VideoUtils.
  static final VideoUtils instance = VideoUtils._();

  // Method to create a BetterPlayerController from a URL.
  // If cacheFile is true, it attempts to cache the video file.
  Future<BetterPlayerController> videoControllerFromUrl({
    required String url,
    bool? cacheFile = false,
    BetterPlayerConfiguration? betterPlayerConfig,
  }) async {
    BetterPlayerDataSource dataSource;

    try {
      File? cachedVideo;

      // If caching is enabled, try to get the cached file.
      if (cacheFile ?? false) {
        cachedVideo = await _cacheManager.getSingleFile(url);
      }

      // If a cached video file is found, create a BetterPlayerDataSource from it.
      if (cachedVideo != null) {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          cachedVideo.path,
        );
      } else {
        // If no cached file is found, create a BetterPlayerDataSource from the network URL.
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
          cacheConfiguration: cacheFile != null
              ? const BetterPlayerCacheConfiguration(useCache: true)
              : null,
        );
      }

      return BetterPlayerController(
        betterPlayerConfig ?? const BetterPlayerConfiguration(),
        betterPlayerDataSource: dataSource,
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // Method to create a BetterPlayerController from a local file.
  BetterPlayerController videoControllerFromFile({
    required File file,
    BetterPlayerConfiguration? betterPlayerConfig,
  }) {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      file.path,
    );

    return BetterPlayerController(
      betterPlayerConfig ?? const BetterPlayerConfiguration(),
      betterPlayerDataSource: dataSource,
    );
  }
}
