import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:kick_start/provider/campaign_factory.dart';
import 'package:kick_start/screen/create_campaign.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';

import 'detail.dart';

class HomePage extends StatefulWidget {
  static const route = "/";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignFactoryProvider>();
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(CreateCampaignScreen.route);
          },
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: campaignProvider.campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = campaignProvider.campaigns[index];
                    return ListTile(
                      title: Text(campaign.toString()),
                      subtitle: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            CampaignShow.route,
                            arguments: campaign,
                          );
                        },
                        child: const Text(
                          "View campaign",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      shape: const Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
