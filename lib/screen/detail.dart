import 'package:flutter/material.dart';
import 'package:kick_start/provider/campaign_provider.dart';
import 'package:kick_start/screen/view_requests.dart';
import 'package:provider/provider.dart';

class CampaignShow extends StatefulWidget {
  static const route = "/campaign_show";

  @override
  State<CampaignShow> createState() => _CampaignShowState();
}

class _CampaignShowState extends State<CampaignShow> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final campaignProvider =
          Provider.of<CampaignProvider>(context, listen: false);
      campaignProvider.getSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _amountController = TextEditingController();
    final campaignProvider = context.watch<CampaignProvider>();
    final summary = campaignProvider.summary;
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: campaignProvider.loading && summary.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Campaign show",
                        style: theme.textTheme.headline5,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: infoItem(
                              context,
                              summary[4],
                              "Address of manager",
                              "The manager create this campaign and can create request withdraw money",
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: infoItem(
                              context,
                              summary[0].toString() + " wei",
                              "Minimum contribute",
                              "You must contribute at least this much wei to become a approver ",
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(ViewRequests.route);
                              },
                              child: infoItem(
                                context,
                                summary[2],
                                "Number of request ",
                                "A request tries to withdraw money from the contract",
                              ),
                            ),
                          ),
                          Flexible(
                              fit: FlexFit.tight,
                              child: infoItem(
                                context,
                                summary[3],
                                "Number of approvers",
                                "Number of people who has donated for this contract",
                              ))
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: infoItem(
                              context,
                              summary[1],
                              "Contract balance",
                              "This balance is how much money has left to spend",
                            ),
                          ),
                          const Flexible(fit: FlexFit.tight, child: SizedBox())
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          label: Text("Amount to contribute"),
                          suffix: Text("Ether"),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          campaignProvider.contribute(
                            BigInt.from(
                              int.parse(_amountController.text),
                            ),
                          );
                        },
                        child: const Text("Contribute"),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget infoItem(
    BuildContext context,
    dynamic value,
    String label,
    String description,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: textTheme.subtitle1,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: textTheme.caption,
              ),
              Text(description, style: textTheme.bodyText2)
            ],
          ),
        ),
      ),
    );
  }
}
