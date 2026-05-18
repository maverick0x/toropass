// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthStateModel> {
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStateModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStateModel>(value),
    );
  }
}

String _$authNotifierHash() => r'42c9dde153a5b5c2c32605298b78cb491e50e59d';

abstract class _$AuthNotifier extends $Notifier<AuthStateModel> {
  AuthStateModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthStateModel, AuthStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStateModel, AuthStateModel>,
              AuthStateModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
