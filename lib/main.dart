import 'package:first_flutter_dapp/detail.dart';
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
        title: 'Note Taking DApp',
        theme: ThemeData.dark(),
        routes: {
          "/": (_) => HomePage(),
          "/detail": (_) => Detail(),
        },
      ),
    );
  }
}
