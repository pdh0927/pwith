import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pwith/common/component/custom_title.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:sizer/sizer.dart';

// 최근 플로깅
class RecentPlogging extends StatelessWidget {
  const RecentPlogging({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomTitle(
            firstText: '너도나도',
            firstColor: BLACK_COLOR,
            secondText: '플로깅',
            secondColor: PRIMARY_COLOR,
          ),
        ),
        SizedBox(height: 8),
        // 최신 플로깅 결과 가로 스크롤 갤러리
        _HorizontalScrollGallery(),
      ],
    );
  }
}

// 최신 플로깅 결과 가로 스크롤 갤러리
class _HorizontalScrollGallery extends StatelessWidget {
  const _HorizontalScrollGallery();

  Future<List<Map<String, dynamic>>> fetchPloggingData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('plogging-result')
        .orderBy('endTime', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchPloggingData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No plogging data available.'));
        }

        final ploggingData = snapshot.data!;
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ploggingData.length,
            itemBuilder: (context, index) {
              final data = ploggingData[index];
              return GestureDetector(
                onTap: () => _showPloggingPopup(context, data),
                child: Container(
                  margin: EdgeInsets.only(right: 12, left: index == 0 ? 12 : 0),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: data['imageUrl'] != null && data['imageUrl'] != ''
                          ? NetworkImage(data['imageUrl'])
                          : const AssetImage('assets/images/main_icon.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 플로깅 디테일 팝업 보기
  void _showPloggingPopup(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 248, 240, 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 폴라로이드 스타일의 이미지와 텍스트
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1 / 0.7, // 1:0.7 비율
                        child:
                            data['imageUrl'] != null && data['imageUrl'] != ''
                                ? Image.network(
                                    data['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: 70.w, // 넓이를 70.w로 설정
                                  )
                                : Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                    width: 70.w, // 넓이를 70.w로 설정
                                  ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 제목
                    Text(
                      data['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Divider(color: Colors.grey[300], thickness: 1, height: 10),
                    const SizedBox(height: 10),

                    // 플로깅 데이터 (걸음 수, 거리, 시간)
                    _PloggingDataSection(
                      steps: data['steps'] ?? 0,
                      totalDistance: data['totalDistance']?.toDouble() ?? 0.0,
                      elapsedTime: Duration(seconds: data['elapsedTime'] ?? 0),
                    ),

                    const SizedBox(height: 10),
                    Divider(color: Colors.grey[300], thickness: 1, height: 10),
                    const SizedBox(height: 10),

                    // 챌린지 정보
                    _ChallengeSection(
                      challengeDescription:
                          data['challengeDescription'] ?? 'N/A',
                      collectedItems: data['collectedItems'] ?? 0,
                      challengeGoal: data['challengeGoal'] ?? 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 플로깅 데이터 컴포넌트
class _PloggingDataSection extends StatelessWidget {
  final int steps;
  final double totalDistance;
  final Duration elapsedTime;

  const _PloggingDataSection({
    required this.steps,
    required this.totalDistance,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _infoColumn("걸음 수", steps.toString(), Icons.directions_walk),
        _infoColumn("거리", "${totalDistance.toStringAsFixed(2)} km", Icons.map),
        _infoColumn("시간", _formatTime(elapsedTime), Icons.timer),
      ],
    );
  }

  Widget _infoColumn(String label, String value, IconData iconData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, size: 20, color: PRIMARY_COLOR),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }
}

// 챌린지 컴포넌트
class _ChallengeSection extends StatelessWidget {
  final String challengeDescription;
  final int collectedItems;
  final int challengeGoal;

  const _ChallengeSection({
    required this.challengeDescription,
    required this.collectedItems,
    required this.challengeGoal,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (collectedItems / challengeGoal).clamp(0, 1);

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.orangeAccent,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              "오늘의 챌린지",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PRIMARY_COLOR,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          challengeDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 12,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  height: 12,
                  width: 160 * progress,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              "$collectedItems / $challengeGoal",
              style: TextStyle(
                fontSize: 14,
                color: progress >= 1 ? Colors.green : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
