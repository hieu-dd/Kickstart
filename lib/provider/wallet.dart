import 'package:web3dart/web3dart.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:bip39/bip39.dart' as bip39;

class CustomWallet {
  static Future<Credentials> getCredentials(int indexAccount) async {
    var mnemonic =
        'afford cash ivory layer jeans monitor certain cargo grace cherry reopen task';

    String seed = bip39.mnemonicToSeedHex(mnemonic);
    Chain chain = Chain.seed(seed);
    ExtendedPrivateKey key =
        chain.forPath("m/44'/60'/0'/0/$indexAccount") as ExtendedPrivateKey;
    return EthPrivateKey.fromHex(key.privateKeyHex()); //web3dart
  }
}
