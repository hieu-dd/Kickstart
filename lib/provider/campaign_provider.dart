import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kick_start/provider/wallet.dart';
import 'package:web3dart/web3dart.dart';

import 'eth.dart';

class CampaignProvider with ChangeNotifier {
  DeployedContract? _contract;
  List<dynamic> _summary = [];
  bool _loading = false;

  bool get loading => _loading;

  List<dynamic> get summary => _summary;

  Future<DeployedContract> getContract(String contractAddress) async {
    if (_contract == null) {
      dynamic factoryString = await rootBundle
          .loadString("contracts/build/contracts/Campaign.json");
      dynamic factory = jsonDecode(factoryString);
      dynamic abi = factory["abi"];
      _contract = DeployedContract(
          ContractAbi.fromJson(
              jsonEncode(abi), factory["contractName"].toString()),
          EthereumAddress.fromHex(contractAddress));
    }
    return _contract!;
  }

  Future<List<dynamic>> callFunction(
      String contractAddress, String name) async {
    final contract = await getContract(contractAddress);
    final function = contract.function(name);
    final result = await ETH.ethClient
        .call(contract: contract, function: function, params: []);
    return result;
  }

  Future<void> getSummary(String contractAddress) async {
    _loading = true;
    notifyListeners();
    dynamic result = await callFunction(contractAddress, "getSummary");
    _summary = result;
    _loading = false;
    notifyListeners();
  }

  Future<void> contribute(String contractAddress, BigInt wei) async {
    _loading = true;
    notifyListeners();
    //obtain our contract from abi in json file
    final contract = await getContract(contractAddress);

    // extract function from json file
    final function = contract.function("contribute");

    //send transaction using the our private key, function and contract
    final credentials = await CustomWallet.getCredentials(0);
    await ETH.ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract,
          function: function,
          value: EtherAmount.inWei(wei),
          parameters: []),
      chainId: 4,
    );
    sleep(const Duration(seconds: 1));
    await getSummary(contractAddress);
  }
}
