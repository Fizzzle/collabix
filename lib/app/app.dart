import 'package:collabix/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';

/// Entry point of the application
class App extends StatelessWidget {
  /// Constructor
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
