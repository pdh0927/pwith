import 'package:flutter/material.dart';

class ReadyContent extends StatelessWidget {
  const ReadyContent({
    super.key,
    required this.startPlogging,
  });

  final VoidCallback startPlogging;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: startPlogging,
        child: const Icon(Icons.play_arrow, size: 50),
      ),
    );
  }
}
