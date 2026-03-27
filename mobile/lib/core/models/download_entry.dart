import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_entry.freezed.dart';

/// Represents the download state of a single track.
enum DownloadStatus { notDownloaded, downloading, downloaded }

/// Immutable snapshot of a track's download state, progress, and local path.
@freezed
abstract class DownloadEntry with _$DownloadEntry {
  const factory DownloadEntry({
    required DownloadStatus status,
    @Default(0.0) double progress,
    String? localPath,
    @Default(0) int fileSize,
  }) = _DownloadEntry;
}
