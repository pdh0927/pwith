import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pwith/common/component/custom_title.dart';
import 'package:pwith/common/component/plogging_profile.dart';
import 'package:pwith/common/const/colors.dart';

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
              return Padding(
                padding: EdgeInsets.only(right: 12, left: index == 0 ? 12 : 0),
                child: PloggingProfile(ploggingData: data),
              );
            },
          ),
        );
      },
    );
  }
}
