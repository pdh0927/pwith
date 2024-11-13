import 'package:flutter/material.dart';

// 커스텀 타이틀
class CustomTitle extends StatelessWidget {
  final String firstText;
  final Color firstColor;
  final String secondText;
  final Color secondColor;

  const CustomTitle({
    super.key,
    required this.firstText,
    required this.firstColor,
    required this.secondText,
    required this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: firstText,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: firstColor,
            ),
          ),
          TextSpan(
            text: ' $secondText',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: secondColor,
            ),
          ),
        ],
      ),
    );
  }
}
