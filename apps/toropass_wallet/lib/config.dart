// Testing Password Verification for existing wallets
// ignore_for_file: avoid_print

import 'package:dotenv/dotenv.dart';
import 'package:toronet/toronet.dart';

void main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final address = env['WALLET_ADDRESS'];
  final password = env['WALLET_PASSWORD'];

  if (address == null || address.isEmpty) {
    throw Exception('Missing WALLET_ADDRESS in .env');
  }

  if (password == null || password.isEmpty) {
    throw Exception('Missing WALLET_PASSWORD in .env');
  }

  final sdk = ToronetSDK(network: Network.mainnet);

  try {
    final isValid = await sdk.walletService.verifyWalletPassword(
      address: address,
      password: password,
    );

    print('[SDK] Password verification result for address $address: $isValid');
  } catch (e, t) {
    print('[SDK] Error verifying wallet password: $e');
    print('[SDK] Stack trace:\n$t');
  }
}
