import 'package:flutter/material.dart';
import 'package:pwith/common/layout/default_layout.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 버튼을 눌렀을 때의 동작을 여기에 정의하세요
          print('플로팅 액션 버튼 클릭됨');
        },
        child: const Icon(Icons.add), // 플러스 아이콘을 추가 (기본 아이콘)
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 100,
              width: 150,
              color: Colors.green,
              child: const Text('대구 플로깅 모디자'),
            ),
            Container(
              alignment: Alignment.center,
              height: 100,
              width: 150,
              color: Colors.green,
              child: const Text('영대 정문 집합'),
            ),
            Container(
              alignment: Alignment.center,
              height: 100,
              width: 150,
              color: Colors.green,
              child: const Text('대구 플로깅 모집합니다.'),
            )
          ],
        ),
      ),
    );
  }
}
