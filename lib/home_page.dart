import 'package:flutter/material.dart';
import 'shared/common_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      child: Center(
        child: Text('Home Page'),
      ),
    );
  }
}