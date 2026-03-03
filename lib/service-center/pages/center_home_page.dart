import 'package:flutter/material.dart';

class CenterHomePage extends StatelessWidget {
  const CenterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Service Center Dashboard",
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}