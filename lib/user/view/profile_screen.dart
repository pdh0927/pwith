import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('내 프로필'),
        const Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.person),
            ),
            Text('홍길동'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('당신은 20000km의 거리를 정화했습니다.'),
            Container(
              height: 150,
              width: 250,
              decoration: BoxDecoration(color: Colors.green[300]),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Text('162개 쓰레기'), Text('10회 플로깅 횟수')],
              ),
            )
          ],
        ),
        Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(Icons.collections),
                  Text('내 플로깅 모아보기'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(Icons.send),
                  Text('문의하기'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
