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

String _$kycNotifierHash() => r'df43636df2e71202089cee452c1ddb417172867c';

abstract class _$KycNotifier extends $Notifier<KycStateModel> {
  KycStateModel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<KycStateModel, KycStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KycStateModel, KycStateModel>,
              KycStateModel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
