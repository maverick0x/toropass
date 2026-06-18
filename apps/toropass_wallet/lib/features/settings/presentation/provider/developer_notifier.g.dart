// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'developer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeveloperNotifier)
final developerProvider = DeveloperNotifierProvider._();

final class DeveloperNotifierProvider
    extends $NotifierProvider<DeveloperNotifier, DeveloperStateModel> {
  DeveloperNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'developerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$developerNotifierHash();

  @$internal
  @override
  DeveloperNotifier create() => DeveloperNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeveloperStateModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeveloperStateModel>(value),
    );
  }
}

String _$developerNotifierHash() => r'e651302bb0087e2855efdd59a65a9084c67c2cea';

abstract class _$DeveloperNotifier extends $Notifier<DeveloperStateModel> {
  DeveloperStateModel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DeveloperStateModel, DeveloperStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeveloperStateModel, DeveloperStateModel>,
              DeveloperStateModel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
