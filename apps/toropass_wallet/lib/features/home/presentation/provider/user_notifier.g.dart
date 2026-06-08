// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserNotifier)
final userProvider = UserNotifierProvider._();

final class UserNotifierProvider
    extends $NotifierProvider<UserNotifier, UserStateModel> {
  UserNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userNotifierHash();

  @$internal
  @override
  UserNotifier create() => UserNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStateModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStateModel>(value),
    );
  }
}

String _$userNotifierHash() => r'57466d779d2b1df8d1cbd1faedbe9d340f4ed43b';

abstract class _$UserNotifier extends $Notifier<UserStateModel> {
  UserStateModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserStateModel, UserStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserStateModel, UserStateModel>,
              UserStateModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
