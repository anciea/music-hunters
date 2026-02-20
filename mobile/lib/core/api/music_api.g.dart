// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_api.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _MusicApi implements MusicApi {
  _MusicApi(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<SearchResponse> searchTracks(String query) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'q': query};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<SearchResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/search',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SearchResponse _value;
    try {
      _value = SearchResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider exposing the [MusicApi] singleton.

@ProviderFor(musicApi)
final musicApiProvider = MusicApiProvider._();

/// Riverpod provider exposing the [MusicApi] singleton.

final class MusicApiProvider
    extends $FunctionalProvider<MusicApi, MusicApi, MusicApi>
    with $Provider<MusicApi> {
  /// Riverpod provider exposing the [MusicApi] singleton.
  MusicApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicApiHash();

  @$internal
  @override
  $ProviderElement<MusicApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MusicApi create(Ref ref) {
    return musicApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicApi>(value),
    );
  }
}

String _$musicApiHash() => r'34808476277063f2d69201b706dc121b99b934bb';
