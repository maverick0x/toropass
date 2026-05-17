// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TokenNotifier)
final tokenProvider = TokenNotifierProvider._();

final class TokenNotifierProvider
    extends $AsyncNotifierProvider<TokenNotifier, TokenStateModel> {
  TokenNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenNotifierHash();

  @$internal
  @override
  TokenNotifier create() => TokenNotifier();
}

String _$tokenNotifierHash() => r'25be3c29f46f9c45cb63c5e39c3216c528b3de60';

abstract class _$TokenNotifier extends $AsyncNotifier<TokenStateModel> {
  FutureOr<TokenStateModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TokenStateModel>, TokenStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TokenStateModel>, TokenStateModel>,
              AsyncValue<TokenStateModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
