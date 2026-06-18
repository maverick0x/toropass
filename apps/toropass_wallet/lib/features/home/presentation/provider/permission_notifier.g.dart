// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PermissionNotifier)
final permissionProvider = PermissionNotifierProvider._();

final class PermissionNotifierProvider
    extends $NotifierProvider<PermissionNotifier, PermissionStateModel> {
  PermissionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionNotifierHash();

  @$internal
  @override
  PermissionNotifier create() => PermissionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionStateModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionStateModel>(value),
    );
  }
}

String _$permissionNotifierHash() =>
    r'9b37ff695a27411851f405c0b12742812756e005';

abstract class _$PermissionNotifier extends $Notifier<PermissionStateModel> {
  PermissionStateModel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PermissionStateModel, PermissionStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PermissionStateModel, PermissionStateModel>,
              PermissionStateModel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
