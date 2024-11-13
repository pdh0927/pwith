import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:sizer/sizer.dart';

// 플로깅 종료 시 보여주는 화면
class FinishScreen extends StatefulWidget {
  final int steps; // 총 걸음 수
  final Duration elapsedTime; // 경과 시간
  final double totalDistance; // 이동 거리
  final String challengeDescription; // 챌린지 설명
  final int collectedItems; // 수집된 아이템 수
  final int challengeGoal; // 챌린지 목표 아이템 수
  final DateTime startTime; // 플로깅 시작 시각

  const FinishScreen({
    super.key,
    required this.steps,
    required this.elapsedTime,
    required this.totalDistance,
    required this.challengeDescription,
    required this.collectedItems,
    required this.challengeGoal,
    required this.startTime,
  });

  @override
  State<FinishScreen> createState() => _FinishScreenState();
}

class _FinishScreenState extends State<FinishScreen> {
  File? localImageFile; // 로컬 이미지 파일
  String imageUrl = ''; // Firebase에 저장된 이미지의 URL
  final TextEditingController _titleController =
      TextEditingController(); // 제목 입력 컨트롤러

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // 폴라로이드
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 248, 240, 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 사진 영역
                    _PhotoSection(
                      localImageFile: localImageFile,
                      onCapture: captureAndCropImage,
                      startTime: widget.startTime,
                    ),

                    const SizedBox(height: 10),

                    // 제목 입력 필드
                    _TitleSection(controller: _titleController),

                    Divider(color: Colors.grey[300], thickness: 1, height: 10),
                    const SizedBox(height: 10),

                    // 플로깅 데이터 (걸음 수, 거리, 시간)
                    _PloggingDataSection(
                      steps: widget.steps,
                      totalDistance: widget.totalDistance,
                      elapsedTime: widget.elapsedTime,
                    ),

                    const SizedBox(height: 10),
                    Divider(color: Colors.grey[300], thickness: 1, height: 10),
                    const SizedBox(height: 10),

                    // 챌린지 정보
                    _ChallengeSection(
                      challengeDescription: widget.challengeDescription,
                      collectedItems: widget.collectedItems,
                      challengeGoal: widget.challengeGoal,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 저장 버튼
            _SaveButton(onSave: savePloggingDataToFirebase),
          ],
        ),
      ),
    );
  }

  // 사진을 촬영하고 크롭하는 함수
  Future<void> captureAndCropImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 40,
    );

    // 크롭 후 이미지 설정 및 Firebase에 업로드
    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 0.7),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '1:1로 자르기',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      // 이미지가 잘렸다면 로컬 파일로 저장하고 Firebase에 업로드
      if (croppedImage != null) {
        setState(() {
          localImageFile = File(croppedImage.path);
        });

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('plogging/result/${DateTime.now().toIso8601String()}');
        final uploadTask = storageRef.putFile(localImageFile!);

        uploadTask.then((taskSnapshot) async {
          imageUrl = await taskSnapshot.ref.getDownloadURL();
        }).catchError((e) {
          _showErrorDialog("이미지 업로드 실패: $e");
        });
      }
    }
  }

  // Firebase에 플로깅 데이터 저장
  Future<void> savePloggingDataToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("로그인된 사용자가 없습니다.");
    }

    // 데이터 준비
    final ploggingData = {
      'uid': user.uid,
      'title': _titleController.text,
      'steps': widget.steps,
      'elapsedTime': widget.elapsedTime.inSeconds,
      'totalDistance': widget.totalDistance,
      'challengeDescription': widget.challengeDescription,
      'collectedItems': widget.collectedItems,
      'challengeGoal': widget.challengeGoal,
      'imageUrl': imageUrl,
      'endTime': DateTime.now(),
      'startTime': widget.startTime.toIso8601String(), // 시작 시각 추가
    };

    await FirebaseFirestore.instance
        .collection('plogging-result')
        .add(ploggingData);
  }

  // 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// 사진 업로드 및 표시 섹션
class _PhotoSection extends StatelessWidget {
  final File? localImageFile;
  final VoidCallback onCapture;
  final DateTime startTime; // 플로깅 시작 시간 추가

  const _PhotoSection({
    this.localImageFile,
    required this.onCapture,
    required this.startTime,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.43, // 1.43:1 비율 (가로 대비 세로 0.7 비율)
      child: InkWell(
        onTap: localImageFile != null ? null : onCapture,
        child: Stack(
          children: [
            // 이미지 또는 카메라 아이콘 표시
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              child: localImageFile != null
                  ? Image.file(
                      localImageFile!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey[500],
                      ),
                    ),
            ),
            // 우 하단에 시작 날짜 및 시간 표시
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                _formatDateTime(startTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      color: Colors.black,
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 시작 시간을 "년.월.일 시:분" 형식으로 변환하는 함수
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}

// 제목 입력 섹션
class _TitleSection extends StatelessWidget {
  final TextEditingController controller;

  const _TitleSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 10,
      cursorHeight: 18,
      decoration: const InputDecoration(
        hintText: "제목을 입력하세요",
        border: InputBorder.none,
        counterText: "",
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: BLACK_COLOR,
      ),
    );
  }
}

// 플로깅 데이터 (걸음 수, 거리, 시간) 표시 섹션
class _PloggingDataSection extends StatelessWidget {
  final int steps;
  final double totalDistance;
  final Duration elapsedTime;

  const _PloggingDataSection({
    required this.steps,
    required this.totalDistance,
    required this.elapsedTime,
  });

  // 시간을 형식에 맞게 변환
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _infoColumn("걸음 수", steps.toString(), PhosphorIconsFill.footprints),
        _infoColumn(
          "거리",
          "${totalDistance.toStringAsFixed(2)} km",
          PhosphorIconsFill.mapPin,
        ),
        _infoColumn("시간", _formatTime(elapsedTime), PhosphorIconsFill.clock),
      ],
    );
  }

  // 데이터 표시 아이콘 및 텍스트
  Widget _infoColumn(String label, String value, IconData iconData) {
    return SizedBox(
      width: (100.w - 64) / 3,
      child: Column(
        children: [
          Icon(iconData, size: 24, color: PRIMARY_COLOR),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// 챌린지 진행 상황 섹션
class _ChallengeSection extends StatelessWidget {
  final String challengeDescription;
  final int collectedItems;
  final int challengeGoal;

  const _ChallengeSection({
    required this.challengeDescription,
    required this.collectedItems,
    required this.challengeGoal,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (collectedItems / challengeGoal).clamp(0, 1);

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsFill.trophy,
              color: Colors.orangeAccent,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              "오늘의 챌린지",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PRIMARY_COLOR,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          challengeDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 챌린지 진행 바
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 12,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  height: 12,
                  width: 160 * progress,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // 챌린지 진행 숫자 표시
            Text(
              "$collectedItems / $challengeGoal",
              style: TextStyle(
                fontSize: 14,
                color: progress >= 1 ? Colors.green : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 저장 버튼 섹션
class _SaveButton extends StatelessWidget {
  final Future<void> Function() onSave;

  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onSave().then((_) {
          Navigator.of(context).pop();
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('데이터 저장에 실패했습니다'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "저장하고 닫기",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
