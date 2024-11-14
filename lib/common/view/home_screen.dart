import 'package:flutter/material.dart';
import 'package:pwith/common/component/recent_plogging.dart';
import 'package:pwith/common/component/total_data.dart';
import 'package:pwith/common/component/week_challenge.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/plogging/shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const RecentPlogging(),
              const SizedBox(height: 20),
              const TotalData(),
              const SizedBox(height: 20),
              const WeekChallenge(),
              ElevatedButton(
                  onPressed: () async {
                    await removePloggingData();
                  },
                  child: Text('지우기'))
            ],
          ),
        ),
      ),
    );
  }
}
