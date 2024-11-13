import 'package:flutter/material.dart';
import 'package:pwith/common/component/recent_plogging.dart';
import 'package:pwith/common/component/total_data.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/plogging/shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            RecentPlogging(),
            SizedBox(height: 20),
            TotalData(),
            ElevatedButton(
                onPressed: () async {
                  await removePloggingData();
                },
                child: Text('지우기'))
          ],
        ),
      ),
    );
  }
}
