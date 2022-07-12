import 'dart:core';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ETH {
  static String blockchainUrl =
      "https://rinkeby.infura.io/v3/4e577288c5b24f17a04beab17cf9c959";
  static Client httpClient = Client();
  static Web3Client ethClient = Web3Client(blockchainUrl, httpClient);
}
