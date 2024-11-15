import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/user/component/menu_button_widget.dart';
import 'package:pwith/user/component/plogging_data_widget.dart';
import 'package:pwith/user/component/user_info_widget.dart';
import 'package:pwith/user/view/login_screen.dart';

// 내 프로필
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser; // 현재 로그인된 사용자 정보
  final TextEditingController _nicknameController = TextEditingController();
  String? nickname; // 유저 닉네임
  int? level; // 유저 레벨
  String? imageUrl; // 프로필 이미지 URL
  int ploggingCount = 0; // 플로깅 횟수
  double totalDistance = 0.0; // 총 정화 거리
  int collectedItems = 0; // 총 쓰레기 수거 개수

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 유저 데이터 로드
  }

  // Firestore에서 유저 및 플로깅 데이터 로드
  Future<void> _loadUserData() async {
    if (user != null) {
      // 유저 정보 불러오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          nickname = userDoc['nickname'];
          level = userDoc['ploggingLevel'];
          imageUrl = userDoc['image'];
          _nicknameController.text = nickname ?? '';
        });
      }

      // 플로깅 데이터 불러오기
      final ploggingResultSnapshot = await FirebaseFirestore.instance
          .collection('plogging-result')
          .where('uid', isEqualTo: user!.uid)
          .get();

      int count = 0;
      double distance = 0.0;
      int items = 0;

      for (var doc in ploggingResultSnapshot.docs) {
        count++;
        distance += doc['totalDistance'] ?? 0.0;
        items += doc['collectedItems'] as int;
      }

      setState(() {
        ploggingCount = count;
        totalDistance = distance;
        collectedItems = items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 로그인되지 않은 경우
    if (user == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    '로그인하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DefaultLayout(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // 유저 정보 표시
                UserInfoWidget(
                  imageUrl: imageUrl,
                  nickname: nickname,
                  level: level,
                  onNicknameUpdate: _updateNickname,
                  onPickImage: _pickImage,
                  nicknameController: _nicknameController,
                ),

                const SizedBox(height: 20),

                // 플로깅 데이터 표시
                PloggingDataWidget(
                  totalDistance: totalDistance,
                  ploggingCount: ploggingCount,
                  collectedItems: collectedItems,
                ),

                const SizedBox(height: 20),

                // 메뉴 버튼
                MenuButtonsWidget(logout: () => logout(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Firestore에 닉네임 업데이트
  Future<void> _updateNickname() async {
    if (user != null && _nicknameController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'nickname': _nicknameController.text,
      });
      setState(() {
        nickname = _nicknameController.text;
      });
    }
  }

  // 프로필 이미지 선택 및 업로드
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && user != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');

      await storageRef.putFile(File(pickedFile.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'image': downloadUrl,
      });

      setState(() {
        imageUrl = downloadUrl;
      });
    }
  }

  // 로그아웃 처리
  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      print('로그아웃 성공');
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }
}
