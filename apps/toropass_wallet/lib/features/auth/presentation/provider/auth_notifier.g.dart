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

String _$authNotifierHash() => r'90bf18c026482d6a589e051e67ce057d1d94c5e4';

abstract class _$AuthNotifier extends $Notifier<AuthStateModel> {
  AuthStateModel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthStateModel, AuthStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStateModel, AuthStateModel>,
              AuthStateModel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
