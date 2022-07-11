import 'package:flutter/material.dart';
import 'package:kick_start/campaign_factory.dart';
import 'package:provider/provider.dart';

class CreateCampaignScreen extends StatefulWidget {
  static const route = "/create-campaign";

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _minimumController = TextEditingController();
  String error = "";

  @override
  Widget build(BuildContext context) {
    final campaignFactory = context.watch<CampaignFactory>();
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create new Campaign",
                style: theme.textTheme.headline5,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _minimumController,
                decoration: const InputDecoration(
                  label: Text("Minimum contribution"),
                  suffix: Text("Wei"),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!campaignFactory.loading) {
                    try {
                      campaignFactory
                          .createCampaign(int.parse(_minimumController.text));
                    } catch (e) {
                      setState(() {
                        error = e.toString();
                      });
                    }
                  }
                },
                child: campaignFactory.loading
                    ? const SizedBox(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        width: 20,
                        height: 20)
                    : Text(error.isNotEmpty ? error : "Create campaign"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
