import 'package:flutter/material.dart';

// 사용자 정보 위젯
class UserInfoWidget extends StatelessWidget {
  final String? imageUrl;
  final String? nickname;
  final int? level;
  final VoidCallback onNicknameUpdate;
  final VoidCallback onPickImage;
  final TextEditingController nicknameController;

  const UserInfoWidget({
    super.key,
    required this.imageUrl,
    required this.nickname,
    required this.level,
    required this.onNicknameUpdate,
    required this.onPickImage,
    required this.nicknameController,
  });

  String getLevelTitle() {
    switch (level) {
      case 1:
        return '플린이';
      case 2:
        return '플른';
      case 3:
        return '플러너';
      case 4:
        return '플문가';
      default:
        return '플린이';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: onPickImage,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 45, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // 닉네임 및 수정 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                nickname ?? '닉네임 없음',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("닉네임 수정"),
                      content: TextField(
                        controller: nicknameController,
                        decoration: const InputDecoration(
                          labelText: '새 닉네임',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("취소"),
                        ),
                        TextButton(
                          onPressed: () async {
                            onNicknameUpdate();
                            Navigator.of(context).pop();
                          },
                          child: const Text("저장"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // 레벨 (별 아이콘과 텍스트)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 별 아이콘을 레벨에 따라 표시
              ...List.generate(
                level ?? 1,
                (index) => const Icon(
                  Icons.star,
                  color: Colors.orangeAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              // 레벨 타이틀 텍스트
              Text(
                getLevelTitle(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
