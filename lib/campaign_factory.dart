import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class CampaignFactory with ChangeNotifier {
  String campaigns = "";
  bool isLoading = false;

  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";

  final String _privateKey =
      "0e7bfcff063b1b1f3de2b70b3a7c16a0464d1e38c0ac2c3ced5b390e0cf3d3b1";

  Web3Client? _client;
  String? _abiCode;

  Credentials? _credentials;
  EthereumAddress? _contractAddress;
  EthereumAddress? _ownAddress;
  DeployedContract? _contract;

  ContractFunction? _createCampaign;
  ContractFunction? _getCampaigns;

  CampaignFactory() {
    init();
  }

  Future<void> init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {;
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile =
    await rootBundle.loadString("contracts/build/contracts/CampaignFactory.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);

    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    _credentials = await _client!.credentialsFromPrivateKey(_privateKey);
    _ownAddress = await _credentials!.extractAddress();
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, "CampaignFactory"), _contractAddress!);
    _createCampaign = _contract!.function("createCampaign");
    _getCampaigns = _contract!.function("getCampaigns");
    await getCampaigns();
  }

  getCampaigns() async {
    try {
      isLoading = true;
      notifyListeners();
      campaigns = await _client!.call(
          contract: _contract!,
          function: _getCampaigns!,
          params: []).toString();
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  createCampaign() async {
    try {
      isLoading = true;
      notifyListeners();
      await _client!.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _contract!,
          function: _createCampaign!,
          parameters: [100],
        ),
      );
    } catch (e) {
      print(e);
    } finally {
      await getCampaigns();
    }
  }
}
