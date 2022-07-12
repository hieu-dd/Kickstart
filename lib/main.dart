import 'package:kick_start/provider/campaign_provider.dart';
import 'package:kick_start/screen/create_campaign.dart';
import 'package:kick_start/screen/detail.dart';
import 'package:flutter/material.dart';
import 'package:kick_start/screen/view_requests.dart';
import 'package:provider/provider.dart';
import 'provider/campaign_factory.dart';
import 'screen/home.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CampaignFactoryProvider()),
        ChangeNotifierProvider(create: (_) => CampaignProvider.Instance),
      ],
      child: MaterialApp(
        title: 'KickStart',
        theme: ThemeData.dark(),
        routes: {
          HomePage.route: (_) => HomePage(),
          CampaignShow.route: (_) => CampaignShow(),
          CreateCampaignScreen.route: (_) => CreateCampaignScreen(),
          ViewRequests.route: (_) => ViewRequests()
        },
      ),
    );
  }
}
