// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KycNotifier)
final kycProvider = KycNotifierProvider._();

final class KycNotifierProvider
    extends $NotifierProvider<KycNotifier, KycStateModel> {
  KycNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycNotifierHash();

  @$internal
  @override
  KycNotifier create() => KycNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycStateModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycStateModel>(value),
    );
  }
}

String _$kycNotifierHash() => r'0cd459e3af4455426a313b69ec70f81f29e68e6f';

abstract class _$KycNotifier extends $Notifier<KycStateModel> {
  KycStateModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KycStateModel, KycStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KycStateModel, KycStateModel>,
              KycStateModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
