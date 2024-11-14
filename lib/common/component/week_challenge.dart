import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pwith/common/component/custom_title.dart';
import 'package:pwith/common/const/colors.dart';

class WeekChallenge extends StatelessWidget {
  const WeekChallenge({super.key});

  // 챌린지 2개 불러오기
  Future<List<Map<String, dynamic>>> fetchChallenges() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('week_challenge')
        .orderBy('createdAt', descending: true)
        .limit(2)
        .get();

    // 최신 2개의 챌린지 데이터를 Map 형식으로 변환하여 반환
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // 챌린지 진행률 계산
  Future<double> calculateProgress(Map<String, dynamic> challenge) async {
    final createdAt = (challenge['createdAt'] as Timestamp).toDate();
    final goal = challenge['goal'];
    final type = challenge['type'];

    if (type == 'distance') {
      // 'distance' 타입인 경우 총 진행한 거리 계산
      final ploggingSnapshot = await FirebaseFirestore.instance
          .collection('plogging-result')
          .where('startTime', isGreaterThanOrEqualTo: createdAt)
          .get();

      // 플로깅 데이터들의 totalDistance의 합 계산
      double totalDistance = ploggingSnapshot.docs
          .fold(0.0, (sum, doc) => sum + doc['totalDistance']);

      // 목표(goal)에 대한 진행률 계산
      return (totalDistance / goal) * 100;
    } else if (type == 'number') {
      // 'number' 타입인 경우 플로깅 횟수 계산
      final ploggingSnapshot = await FirebaseFirestore.instance
          .collection('plogging-result')
          .where('startTime', isGreaterThanOrEqualTo: createdAt)
          .get();

      int count = ploggingSnapshot.docs.length;

      // 목표(goal)에 대한 진행률 계산
      return (count / goal) * 100;
    }

    // 알 수 없는 type의 경우 0% 반환
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text('No challenges available.'));
        }

        final challenges = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              const CustomTitle(
                firstText: '이번주',
                firstColor: BLACK_COLOR,
                secondText: '챌린지',
                secondColor: PRIMARY_COLOR,
              ),
              const SizedBox(height: 8),
              // 최신 2개의 챌린지 데이터 표시
              Column(
                children: challenges.map((challenge) {
                  return FutureBuilder<double>(
                    future: calculateProgress(challenge),
                    builder: (context, progressSnapshot) {
                      if (progressSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final progress = progressSnapshot.data ?? 0.0;
                      final challengeText = challenge['content'] ?? '챌린지';

                      return _challengeRow(progress, challengeText);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _challengeRow(double progress, String challengeText) {
    return Container(
      width: double.infinity,
      height: 88,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 8.0), // 챌린지 항목 간의 간격
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 원형 진행 바
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: progress / 100, // 진행률을 0.0~1.0으로 설정
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(PRIMARY_COLOR),
                ),
              ),
              // 진행률 텍스트
              Text(
                '${progress.toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // 챌린지 텍스트
          Expanded(
            child: Text(
              challengeText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
