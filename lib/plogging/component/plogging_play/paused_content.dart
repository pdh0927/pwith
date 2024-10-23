import 'package:flutter/material.dart';

class PausedContent extends StatelessWidget {
  const PausedContent({
    super.key,
    required this.resumeTimer,
    required this.onEnd,
  });

  final VoidCallback resumeTimer;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '쉬는 중입니다',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: resumeTimer,
            child: const Text('Resume'),
          ),
          ElevatedButton(
            onPressed: onEnd, // 종료 버튼
            child: const Text('플로깅 종료'),
          ),
        ],
      ),
    );
  }
}
