import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// 플로깅 준비 화면
class ReadyContent extends StatelessWidget {
  const ReadyContent({
    super.key,
    required this.startPlogging,
  });

  final VoidCallback startPlogging;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // 시작 버튼
          InkWell(
            onTap: startPlogging,
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
    );
  }
}
