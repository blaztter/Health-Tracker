import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(HealthOverviewApp());
}

class HealthOverviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      navigatorObservers: [RouteObserver<ModalRoute<void>>()],
    );
  }
}
