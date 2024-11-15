import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pwith/common/component/plogging_profile.dart';
import 'package:pwith/common/layout/default_layout.dart';

// 내 플로깅 모아보기
class MyPloggingScreen extends StatelessWidget {
  const MyPloggingScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchMyPloggingData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final uid = user.uid;

    // Firestore에서 현재 로그인된 사용자의 데이터만 불러오기
    final snapshot = await FirebaseFirestore.instance
        .collection('plogging-result')
        .where('uid', isEqualTo: uid)
        .orderBy('endTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '내 플로깅 모아보기',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMyPloggingData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('플로깅 데이터가 없습니다.'));
          }

          final ploggingData = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: ploggingData.length,
            itemBuilder: (context, index) {
              final data = ploggingData[index];
              return PloggingProfile(ploggingData: data);
            },
          );
        },
      ),
    );
  }
}
