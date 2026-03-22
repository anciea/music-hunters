// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [Database] instance that opens (or creates) the local
/// SQLite database on first access.
///
/// Kept alive for the lifetime of the app so database connection overhead is
/// paid only once.

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

/// Provides a singleton [Database] instance that opens (or creates) the local
/// SQLite database on first access.
///
/// Kept alive for the lifetime of the app so database connection overhead is
/// paid only once.

final class DatabaseProvider
    extends
        $FunctionalProvider<AsyncValue<Database>, Database, FutureOr<Database>>
    with $FutureModifier<Database>, $FutureProvider<Database> {
  /// Provides a singleton [Database] instance that opens (or creates) the local
  /// SQLite database on first access.
  ///
  /// Kept alive for the lifetime of the app so database connection overhead is
  /// paid only once.
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $FutureProviderElement<Database> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Database> create(Ref ref) {
    return database(ref);
  }
}

String _$databaseHash() => r'8363dec5016dc9340b3715013e43ac65db579d03';
