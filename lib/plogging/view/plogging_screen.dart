import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/plogging/view/plogging_play_screen.dart';

class PloggingScreen extends StatefulWidget {
  const PloggingScreen({super.key});

  @override
  State<PloggingScreen> createState() => _PloggingScreenState();
}

class _PloggingScreenState extends State<PloggingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: PRIMARY_COLOR,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // 시작 버튼
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PloggingPlayScreen(),
                  ),
                );
              },
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100)),
                child: const Icon(
                  PhosphorIconsFill.play,
                  size: 80,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              '오늘도 힘차게 달려보세요!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
