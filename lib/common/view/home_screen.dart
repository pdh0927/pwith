import 'package:flutter/material.dart';
import 'package:pwith/common/layout/default_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('홈'),
            const SizedBox(height: 30),
            const Text('플로깅 공유'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.green,
                  ),
                  child: const Text('플로깅 결과 사진1'),
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.green,
                  ),
                  child: const Text('플로깅 결과 사진2'),
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.green,
                  ),
                  child: const Text('플로깅 결과 사진3'),
                )
              ],
            ),
            const SizedBox(height: 30),
            const Text('우리들의 기록'),
            Container(
              height: 130,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text('정화한 거리 100km    주운 쓰레기 1만개'),
            ),
            const SizedBox(height: 30),
            const Text('챌린지'),
            Container(
              height: 130,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text('챌린지1    챌린지2'),
            ),
          ],
        ),
      ),
    );
  }
}
