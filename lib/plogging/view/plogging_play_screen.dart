import 'package:flutter/material.dart';

class PloggingPlayScreen extends StatefulWidget {
  const PloggingPlayScreen({super.key});

  @override
  State<PloggingPlayScreen> createState() => _PloggingPlayScreenState();
}

class _PloggingPlayScreenState extends State<PloggingPlayScreen> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) {
      return Center(
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                isPlaying = true;
              });
            },
            child: Icon(
              Icons.play_arrow,
              size: 50,
            )),
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.green),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('총 쓰레기수'),
                  Text('걸음수'),
                  Text('진행한 시간'),
                ],
              ),
            ),
            Column(
              children: [
                const Text('1.05 킬로미터'),
                Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('병 2개'),
                          Text('플라스틱 42개'),
                          Text('꽁초 214개'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('일반쓰레기 4개'),
                          Text('철 21개'),
                          Text('비닐 20개'),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Icon(Icons.photo),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Icon(Icons.pause_circle),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Icon(Icons.camera),
                )
              ],
            )
          ]);
    }
  }
}
