import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kick_start/provider/wallet.dart';
import 'package:web3dart/web3dart.dart';

import 'eth.dart';

class CampaignProvider with ChangeNotifier {
  static CampaignProvider Instance = CampaignProvider();

  String _contractAddress = "";
  DeployedContract? _contract;
  List<dynamic> _summary = [];
  bool _loading = false;
  List<dynamic> _requests = [];

  List<dynamic> get requests {
    if (_requests.isEmpty) {
      getRequests();
    }
    return _requests;
  }

  bool get loading => _loading;

  List<dynamic> get summary => _summary;

  void setContractAddress(String add) {
    _contract = null;
    _contractAddress = add;
    _summary = [];
    _loading = false;
    _requests = [];
    notifyListeners();
  }

  Future<DeployedContract> getContract() async {
    if (_contract == null) {
      dynamic factoryString = await rootBundle
          .loadString("contracts/build/contracts/Campaign.json");
      dynamic factory = jsonDecode(factoryString);
      dynamic abi = factory["abi"];
      _contract = DeployedContract(
          ContractAbi.fromJson(
              jsonEncode(abi), factory["contractName"].toString()),
          EthereumAddress.fromHex(_contractAddress));
    }
    return _contract!;
  }

  Future<List<dynamic>> callFunction(
      {required String name, List<dynamic> params = const []}) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ETH.ethClient
        .call(contract: contract, function: function, params: params);
    return result;
  }

  Future<void> getSummary() async {
    _loading = true;
    notifyListeners();
    dynamic result = await callFunction(name: "getSummary");
    _summary = result;
    _loading = false;
    notifyListeners();
  }

  Future<void> contribute(BigInt wei) async {
    _loading = true;
    notifyListeners();
    //obtain our contract from abi in json file
    final contract = await getContract();

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
    await getSummary();
  }

  Future<void> getRequests() async {
    _loading = true;
    _requests = [];
    notifyListeners();
    final BigInt requestCount = _summary[2];
    for (var i = 0; i < requestCount.toInt(); i++) {
      dynamic result = await callFunction(name: "requests", params: [BigInt.from(i)]);
      _requests.add(result);
    }
    notifyListeners();
  }
}
