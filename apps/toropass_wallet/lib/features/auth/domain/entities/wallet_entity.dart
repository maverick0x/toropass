import 'package:equatable/equatable.dart';

import '../../../../core/network/token/token_entity.dart';

class WalletEntity extends Equatable {
  final String? address;
  final String? username;
  final String? tnsName;
  final String? network;
  final TokenEntity? tokens;

  const WalletEntity({
    this.address,
    this.tnsName,
    this.username,
    this.network,
    this.tokens,
  });

  @override
  List<Object?> get props => [address, tnsName, username, network, tokens];
}
