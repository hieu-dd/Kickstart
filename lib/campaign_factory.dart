import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class CampaignFactory with ChangeNotifier {
  Client httpClient = Client();

  final String blockchainUrl =
      "https://rinkeby.infura.io/v3/4e577288c5b24f17a04beab17cf9c959";

  Web3Client? ethClient;

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
    String contractAddress = "0x09e083de8e4f766d7727ba74812cda6addc00dfe";
    final contract = DeployedContract(
        ContractAbi.fromJson(
            jsonEncode(abi), factory["contractName"].toString()),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> callFunction(String name) async {
    ethClient = ethClient ?? Web3Client(blockchainUrl, httpClient);
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient!
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
    final accs = await requestAccounts();
    if (accs.isNotEmpty) {
      //obtain private key for write operation
      // Credentials key = EthPrivateKey.fromHex(accs.first);
      Credentials key = EthPrivateKey.fromHex(
          "b2e11f7499b795e4bc1579269096020d8dc757fe8493cd7b9e9b700c703db080");
      print(accs);

      //obtain our contract from abi in json file
      final contract = await getContract();

      // extract function from json file
      final function = contract.function("createCampaign");

      //send transaction using the our private key, function and contract
      await ethClient!.sendTransaction(
          key,
          Transaction.callContract(
              contract: contract,
              function: function,
              parameters: [BigInt.from(minimum)]),
          chainId: 4);
      await syncCampaigns();
      _loading = false;
      notifyListeners();
    } else {
      _loading = false;
      notifyListeners();
      throw Exception("Need accounts");
    }
  }

  Future<List<String>> requestAccounts() async {
    return ["b2e11f7499b795e4bc1579269096020d8dc757fe8493cd7b9e9b700c703db080"];
  }
}
