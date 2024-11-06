import 'package:flutter/material.dart';
import 'package:pwith/common/const/colors.dart';

// 플로깅 정지 화면 내용
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
    return Container(
      color: Colors.white.withOpacity(0.9), // 약간의 투명도를 가진 배경
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.nature_people,
              size: 60,
              color: PRIMARY_COLOR,
            ),

            const SizedBox(height: 10),

            const Text(
              '플로깅 일시 정지',
              style: TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '잠시 휴식을 취하세요!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 30),

            // 재개하기 버튼
            SizedBox(
              width: 150,
              child: ElevatedButton.icon(
                onPressed: resumeTimer,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text('재개하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 종료하기 버튼
            SizedBox(
              width: 150,
              child: OutlinedButton.icon(
                onPressed: onEnd,
                icon: const Icon(Icons.stop, color: Colors.red),
                label: const Text('플로깅 종료'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
