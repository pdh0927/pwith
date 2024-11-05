import 'package:flutter/material.dart';
import 'package:pwith/common/const/colors.dart';

class FinishContent extends StatelessWidget {
  final String? imageUrl; // 촬영한 이미지 URL
  final int steps; // 걸음 수
  final Duration elapsedTime; // 경과 시간
  final double totalDistance; // 이동 거리
  final String challengeDescription; // 챌린지 설명
  final int collectedItems; // 수집된 아이템 수
  final int challengeGoal; // 챌린지 목표 수
  final VoidCallback onCaptureImage; // 사진 촬영 콜백
  final VoidCallback onClose; // 사진 촬영 콜백

  const FinishContent({
    super.key,
    required this.imageUrl,
    required this.steps,
    required this.elapsedTime,
    required this.totalDistance,
    required this.challengeDescription,
    required this.collectedItems,
    required this.challengeGoal,
    required this.onCaptureImage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 폴라로이드 스타일의 사진과 정보 카드
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 사진 영역
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  IconButton(
                    icon:
                        Icon(Icons.camera_alt, size: 40, color: PRIMARY_COLOR),
                    onPressed: onCaptureImage,
                  ),
                const SizedBox(height: 12),
                // 텍스트 정보 영역
                Text(
                  "Plogging Summary",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: PRIMARY_COLOR,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow("걸음 수", "$steps 걸음"),
                _buildInfoRow("경과 시간", _formatTime(elapsedTime)),
                _buildInfoRow(
                    "이동 거리", "${totalDistance.toStringAsFixed(2)} km"),
                _buildInfoRow(
                  "챌린지",
                  "$challengeDescription ($collectedItems / $challengeGoal)",
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onClose,
                  child: const Text(
                    "닫기",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 시간 형식 변환 함수
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // 개별 정보 행을 생성하는 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
