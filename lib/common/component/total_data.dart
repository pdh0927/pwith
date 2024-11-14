import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pwith/common/component/custom_title.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:sizer/sizer.dart';

class TotalData extends StatelessWidget {
  const TotalData({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          CustomTitle(
            firstText: '우리함께',
            firstColor: BLACK_COLOR,
            secondText: '플로깅',
            secondColor: PRIMARY_COLOR,
          ),
          SizedBox(height: 8),
          _DataSection()
        ],
      ),
    );
  }
}

class _DataSection extends StatelessWidget {
  const _DataSection();

  Future<Map<String, dynamic>> fetchTotalData() async {
    // Firestore에서 'total-data' 컬렉션의 첫 번째 문서를 가져오기
    final snapshot = await FirebaseFirestore.instance
        .collection('total-data')
        .limit(1) // 첫 번째 문서만 가져옴
        .get();

    // 문서가 존재하면 해당 필드 값을 Map으로 반환
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    } else {
      // 문서가 없으면 기본값 반환
      return {'distance': 0, 'trash': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchTotalData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available.'));
        }

        final data = snapshot.data!;
        final distance = (data['distance'] ?? 0).round();
        final trash = data['trash'] ?? 0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PRIMARY_COLOR.withOpacity(0.9),
                PRIMARY_COLOR.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoColumn(
                'assets/images/trash.png',
                '총 수집한 쓰레기수',
                '$trash 개',
              ),
              _infoColumn(
                'assets/images/shoes.png',
                '총 정화한 거리수',
                '$distance km',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoColumn(String imagePath, String label, String content) {
    return Container(
      width: (100.w - 64) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
