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

String _$tokenNotifierHash() => r'14ed8ec55ef528128e09d1174939b471aafc4653';

abstract class _$TokenNotifier extends $AsyncNotifier<TokenStateModel> {
  FutureOr<TokenStateModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TokenStateModel>, TokenStateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TokenStateModel>, TokenStateModel>,
              AsyncValue<TokenStateModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
