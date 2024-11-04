import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pwith/common/const/text_style.dart';
import 'package:sizer/sizer.dart';

// 플로깅 중 일 때 내용
class PlayContent extends StatelessWidget {
  final int collectedItems; // 현재 수집된 아이템 수
  final int challengeGoal; // 챌린지 목표 아이템 수
  final double totalDistance; // 총 이동 거리
  final int steps; // 총 걸음 수
  final Duration elapsedTime; // 경과 시간
  final VoidCallback onPause; // 일시정지 동작 콜백
  final Future<bool> Function() onPickImage; // 이미지 선택 기능 콜백

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
    double challengeProgress =
        (collectedItems / challengeGoal) * 100; // 챌린지 진행률 계산

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoRow(challengeProgress), // 상단 정보 표시 위젯
            _buildDistanceAndTrashInfo(context), // 중앙 거리 및 챌린지 정보 표시 위젯
            _buildControlButtons(), // 하단 제어 버튼
          ],
        ),
      ),
    );
  }

  // 상단(걸음수 및 시간) 정보를 표시하는 위젯
  Widget _buildInfoRow(double challengeProgress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _infoColumn('걸음수', PhosphorIconsFill.footprints, '$steps'), // 걸음수 정보
        _infoColumn('시간', PhosphorIconsFill.clock,
            _formatTime(elapsedTime)), // 경과 시간 정보
      ],
    );
  }

  // 개별 정보(아이콘 + 값) 열 구성
  Widget _infoColumn(String label, IconData iconData, String value) {
    return Container(
      width: (100.w - 32) / 2,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Colors.white), // 아이콘
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
          Text(label, style: plogging_text_style), // 라벨 텍스트
        ],
      ),
    );
  }

  // 중앙에 총 거리 및 챌린지 정보를 표시하는 위젯
  Widget _buildDistanceAndTrashInfo(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              totalDistance.toStringAsFixed(2), // 총 거리
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
        _buildChallengeInfo(context), // 챌린지 정보 버튼
      ],
    );
  }

  // 챌린지 정보 버튼과 팝업 구현
  Widget _buildChallengeInfo(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            int updatedCollectedItems =
                collectedItems; // 팝업에서 실시간으로 업데이트될 아이템 수

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    "Today's 챌린지",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '플라스틱 20개 줍기',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$updatedCollectedItems / $challengeGoal', // 현재 진행 상태
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (await onPickImage()) {
                            setState(() {
                              updatedCollectedItems++; // 아이템 수 업데이트
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 5,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: Colors.green,
          ),
          SizedBox(width: 10),
          Text(
            '챌린지',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // 하단 제어 버튼 (일시정지 버튼)
  Widget _buildControlButtons() {
    return IconButton(
      icon: const Icon(PhosphorIconsFill.pause, size: 50, color: Colors.white),
      onPressed: onPause,
    );
  }

  // 시간 형식 변환 함수
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours); // 시간 추출
    String minutes = twoDigits(duration.inMinutes.remainder(60)); // 분 추출
    String seconds = twoDigits(duration.inSeconds.remainder(60)); // 초 추출

    return '$hours:$minutes:$seconds'; // HH:MM:SS 형식 반환
  }
}
