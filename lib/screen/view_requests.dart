import 'package:flutter/material.dart';
import 'package:kick_start/provider/campaign_provider.dart';
import 'package:provider/provider.dart';

class ViewRequests extends StatelessWidget {
  static const route = "/view_requests";

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final requests = campaignProvider.requests;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Requests"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: requests.length + 1,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? _title()
                          : _itemRequest(
                              requests[index - 1],
                              index % 2 == 0
                                  ? Colors.transparent
                                  : Colors.black26);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Row(
      children: const [
        Flexible(
          child: Text(
            "Description",
          ),
          flex: 3,
          fit: FlexFit.tight,
        ),
        Flexible(
          child: Text("Value"),
          fit: FlexFit.tight,
          flex: 1,
        ),
        Flexible(
          child: Text("Recipient"),
          fit: FlexFit.tight,
          flex: 1,
        ),
        Flexible(
          child: Text("Complete"),
          fit: FlexFit.tight,
          flex: 1,
        ),
        Flexible(
          child: Text("ApprovalCount"),
          fit: FlexFit.tight,
          flex: 1,
        ),
      ],
    );
  }

  Widget _itemRequest(dynamic request, Color color) {
    return Container(
      color: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              request[0].toString(),
            ),
            flex: 3,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: Text(
              request[1].toString(),
            ),
            fit: FlexFit.tight,
            flex: 1,
          ),
          Flexible(
            child: Text(
              request[2].toString(),
            ),
            fit: FlexFit.tight,
            flex: 1,
          ),
          Flexible(
            child: Text(
              request[3].toString(),
            ),
            fit: FlexFit.tight,
            flex: 1,
          ),
          Flexible(
            child: Text(
              request[4].toString(),
            ),
            fit: FlexFit.tight,
            flex: 1,
          ),
        ],
      ),
    );
  }
}
