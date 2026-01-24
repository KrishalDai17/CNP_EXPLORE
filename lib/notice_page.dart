import 'package:flutter/material.dart';
import 'shared/common_layout.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      child: Center(
        child: Text('Notice Page'),
      ),
    );
  }
}