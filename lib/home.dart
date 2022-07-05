import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Client httpClient;

  late Web3Client ethClient;

  final String blockchainUrl =
      "https://rinkeby.infura.io/v3/4e577288c5b24f17a04beab17cf9c959";

  var campaigns;

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(blockchainUrl, httpClient);
    getCampaigns();
    super.initState();
  }

  Future<DeployedContract> getContract() async {
    dynamic factoryString = await rootBundle
        .loadString("contracts/build/contracts/CampaignFactory.json");
    dynamic factory = jsonDecode(factoryString);
    dynamic abi = factory["abi"];
    String contractAddress = "0x09e083de8e4f766d7727ba74812cda6addc00dfe";
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abi), factory["contractName"].toString()),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> callFunction(String name) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient
        .call(contract: contract, function: function, params: []);
    return result;
  }

  Future<void> getCampaigns() async {
    dynamic result = await callFunction("getCampaigns");
    campaigns = result.toString();

    setState(() {});
  }

  snackBar({String? label}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label!),
            CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
        duration: Duration(days: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> createCampaign() async {
    snackBar(label: "Create Campaign");
    //obtain private key for write operation
    Credentials key = EthPrivateKey.fromHex(
        "b2e11f7499b795e4bc1579269096020d8dc757fe8493cd7b9e9b700c703db080");

    //obtain our contract from abi in json file
    final contract = await getContract();

    // extract function from json file
    final function = contract.function("createCampaign");

    //send transaction using the our private key, function and contract
    await ethClient.sendTransaction(
        key,
        Transaction.callContract(
            contract: contract, function: function, parameters: [BigInt.from(0)]),
        chainId: 4);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    snackBar(label: "creating ....");
    //set a 20 seconds delay to allow the transaction to be verified before trying to retrieve the balance
    Future.delayed(const Duration(seconds: 20), () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBar(label: "Done");
      getCampaigns();

      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text(campaigns??""),
              TextButton(
                  onPressed: () {
                    getCampaigns();
                  },
                  child: const Text("Get campaign")),
              TextButton(
                  onPressed: () {
                    createCampaign();
                  },
                  child: const Text("Create campaign")),
            ],
          ),
        ),
      ),
    );
  }
}
