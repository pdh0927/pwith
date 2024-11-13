import 'package:flutter/material.dart';
import 'package:pwith/common/component/recent_plogging.dart';
import 'package:pwith/common/layout/default_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultLayout(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            RecentPlogging(),
          ],
        ),
      ),
    );
  }
}
