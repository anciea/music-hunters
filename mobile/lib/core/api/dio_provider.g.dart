// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a configured [Dio] singleton with:
/// - Base URL from [AppConfig.apiBaseUrl]
/// - X-API-Key header injected on every request

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Provides a configured [Dio] singleton with:
/// - Base URL from [AppConfig.apiBaseUrl]
/// - X-API-Key header injected on every request

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provides a configured [Dio] singleton with:
  /// - Base URL from [AppConfig.apiBaseUrl]
  /// - X-API-Key header injected on every request
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'3d3d44682a6141d218f4d07eb4955957f9ca522d';
