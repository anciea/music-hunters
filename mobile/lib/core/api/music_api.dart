import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/search_response.dart';
import 'dio_provider.dart';

part 'music_api.g.dart';

/// Type-safe Retrofit API client for the MusicDL backend.
/// Generated implementation is in music_api.g.dart.
@RestApi()
abstract class MusicApi {
  factory MusicApi(Dio dio, {String? baseUrl}) = _MusicApi;

  @GET('/search')
  Future<SearchResponse> searchTracks(@Query('q') String query);
}

/// Riverpod provider exposing the [MusicApi] singleton.
@riverpod
MusicApi musicApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MusicApi(dio);
}
