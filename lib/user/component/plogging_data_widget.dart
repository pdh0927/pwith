import 'package:flutter/material.dart';
import 'package:pwith/common/const/colors.dart';

// 플로깅 데이터 위젯
class PloggingDataWidget extends StatelessWidget {
  final double totalDistance;
  final int ploggingCount;
  final int collectedItems;

  const PloggingDataWidget({
    super.key,
    required this.totalDistance,
    required this.ploggingCount,
    required this.collectedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '당신은 총 ${totalDistance.toStringAsFixed(1)} km의 거리를 정화했습니다.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Card(
          color: PRIMARY_COLOR.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('$ploggingCount회',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('플로깅 횟수'),
                  ],
                ),
                Column(
                  children: [
                    Text('$collectedItems 개',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('총 쓰레기 수거량'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
