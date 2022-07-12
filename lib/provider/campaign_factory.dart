import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kick_start/provider/wallet.dart';
import 'package:web3dart/web3dart.dart';

import 'eth.dart';

class CampaignFactoryProvider with ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;

  List<dynamic> _campaigns = [];

  List<dynamic> get campaigns {
    if (_campaigns.isEmpty) {
      syncCampaigns();
    }
    return _campaigns;
  }

  Future<DeployedContract> getContract() async {
    dynamic factoryString = await rootBundle
        .loadString("contracts/build/contracts/CampaignFactory.json");
    dynamic factory = jsonDecode(factoryString);
    dynamic abi = factory["abi"];
    String contractAddress = "0xe43ff80f81d2b01de888701d025814d95074fad0";
    final contract = DeployedContract(
        ContractAbi.fromJson(
            jsonEncode(abi), factory["contractName"].toString()),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> callFunction(String name) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ETH.ethClient
        .call(contract: contract, function: function, params: []);
    return result;
  }

  Future<void> syncCampaigns() async {
    dynamic result = await callFunction("getCampaigns");
    _campaigns = result[0];
    if (_campaigns.isNotEmpty) {
      notifyListeners();
    }
  }

  Future<void> createCampaign(int minimum) async {
    _loading = true;
    notifyListeners();
    //obtain our contract from abi in json file
    final contract = await getContract();

    // extract function from json file
    final function = contract.function("createCampaign");

    //send transaction using the our private key, function and contract
    final credentials = await CustomWallet.getCredentials(0);
    await ETH.ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [BigInt.from(minimum)]),
      chainId: 4,
    );

    _loading = false;
    notifyListeners();
  }
}
