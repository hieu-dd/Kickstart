import 'package:kick_start/create_campaign.dart';
import 'package:kick_start/detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'campaign_factory.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CampaignFactory(),
      child: MaterialApp(
        title: 'KickStart',
        theme: ThemeData.dark(),
        routes: {
          HomePage.route: (_) => HomePage(),
          "/detail": (_) => Detail(),
          CreateCampaignScreen.route: (_) => CreateCampaignScreen()
        },
      ),
    );
  }
}
