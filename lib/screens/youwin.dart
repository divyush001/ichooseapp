import 'package:flutter/material.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({super.key});

  @override
  State<WinScreen> createState() {
    return _WinScreenState();
  }
}

class _WinScreenState extends State<WinScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('You Win'),
    );
  }
}
