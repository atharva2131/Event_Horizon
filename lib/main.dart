// lib/main.dart
import 'package:eventhorizon/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(EventHorizonApp());

class EventHorizonApp extends StatelessWidget {
  const EventHorizonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventHorizon - Sign In',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),  // Launch the SplashScreen initially
    );
  }
}
