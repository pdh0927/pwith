import 'package:flutter/material.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:pwith/user/view/my_plogging_screen.dart';

// 메뉴 버튼 위젯
class MenuButtonsWidget extends StatelessWidget {
  final VoidCallback logout;

  const MenuButtonsWidget({super.key, required this.logout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMenuButton(
          icon: Icons.collections,
          label: '내 플로깅 모아보기',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyPloggingScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          icon: Icons.send,
          label: '문의하기',
          onPressed: () {
            // 문의하기 기능
          },
        ),
        const SizedBox(height: 16),
        _buildLogoutButton(
          icon: Icons.logout,
          label: '로그아웃',
          onPressed: logout,
        ),
      ],
    );
  }

  // 일반 메뉴 버튼
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24), // 아이콘 크기
          const SizedBox(width: 16), // 아이콘과 텍스트 사이 간격
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃 버튼
  Widget _buildLogoutButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24), // 아이콘 크기
          const SizedBox(width: 16), // 아이콘과 텍스트 사이 간격
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
