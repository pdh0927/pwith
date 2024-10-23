import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pwith/common/const/text_style.dart';
import 'package:sizer/sizer.dart';

class PlayContent extends StatelessWidget {
  final int collectedItems;
  final int challengeGoal;
  final double totalDistance;
  final int steps;
  final Duration elapsedTime;
  final VoidCallback onPause;
  final Future<void> Function() onPickImage;

  const PlayContent({
    super.key,
    required this.collectedItems,
    required this.challengeGoal,
    required this.totalDistance,
    required this.steps,
    required this.elapsedTime,
    required this.onPause,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    double challengeProgress = (collectedItems / challengeGoal) * 100;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoRow(challengeProgress),
            _buildDistanceAndTrashInfo(),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  // 상단(완료 %, 걸음수, 시간)
  Widget _buildInfoRow(double challengeProgress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoColumn('챌린지', PhosphorIconsFill.target,
            '${challengeProgress.toStringAsFixed(1)}%'),
        _infoColumn('걸음수', PhosphorIconsFill.footprints, '$steps'),
        _infoColumn('시간', PhosphorIconsFill.clock, _formatTime(elapsedTime)),
      ],
    );
  }

  Widget _infoColumn(String label, IconData iconData, String value) {
    return Container(
      width: (100.w - 32) / 3,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: plogging_text_style),
        ],
      ),
    );
  }

  // 가운데(km, 챌린지)
  Widget _buildDistanceAndTrashInfo() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              totalDistance.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              '킬로미터',
              style: plogging_text_style.copyWith(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildChallengeInfo(),
      ],
    );
  }

  Widget _buildChallengeInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Today's 챌린지",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '플라스틱 20개 줍기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$collectedItems / $challengeGoal',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {}, // 필요한 동작 연결
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.camera_alt, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return IconButton(
      icon: const Icon(PhosphorIconsFill.pause, size: 50, color: Colors.white),
      onPressed: onPause,
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds % 60)}';
  }
}
