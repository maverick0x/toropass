import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/wallet_entity.dart';

class ProfileEntity extends Equatable {
  final String? id;
  final bool? kycVerified;
  final String? kycAnchorHash;
  final WalletEntity? wallet;

  const ProfileEntity({
    this.id,
    this.kycVerified,
    this.kycAnchorHash,
    this.wallet,
  });

  @override
  List<Object?> get props => [id, kycVerified, kycAnchorHash, wallet];
}
