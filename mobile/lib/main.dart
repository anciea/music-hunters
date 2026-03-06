import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'app.dart';
import 'core/audio/audio_handler.dart';
import 'core/providers/player_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure audio session for music playback BEFORE AudioService.init.
  // This ensures audio focus is claimed correctly when playback starts.
  // (RESEARCH.md Pitfall 7: must be before AudioService.init)
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // Create the AudioPlayer and wrap it in the handler that bridges
  // just_audio to audio_service for OS notification + background playback.
  final player = AudioPlayer();
  final audioHandler = await AudioService.init(
    builder: () => MusicDlAudioHandler(player),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.musicdl.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      // androidStopForegroundOnPause: false keeps the foreground service alive
      // when playback is paused, preventing Android from killing the process.
      // Note: androidNotificationOngoing is intentionally omitted because the
      // assertion in AudioServiceConfig forbids ongoing=true with stopOnPause=false.
      androidStopForegroundOnPause: false,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Supply the pre-created handler instance to all providers that
        // depend on audioHandlerProvider.
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const MusicDlApp(),
    ),
  );
}
