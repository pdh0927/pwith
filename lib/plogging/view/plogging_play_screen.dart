import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer/pedometer.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/plogging/component/plogging_play/paused_content.dart';
import 'package:pwith/plogging/component/plogging_play/play_content.dart';
import 'package:pwith/plogging/component/plogging_play/ready_content.dart';
import 'package:pwith/plogging/model/plogging_model.dart';
import 'package:pwith/plogging/shared_preferences/shared_preferences.dart';

// 플로깅 화면
class PloggingPlayScreen extends StatefulWidget {
  const PloggingPlayScreen({super.key});

  @override
  State<PloggingPlayScreen> createState() => _PloggingPlayScreenState();
}

class _PloggingPlayScreenState extends State<PloggingPlayScreen> {
  bool isPlaying = false; // 플로깅 진행 여부
  bool isPaused = false; // 일시정지 상태 여부
  int steps = 0; // 현재 걸음 수
  int initialSteps = 0; // 초기 걸음 수
  double totalDistance = 0.0; // 이동 거리 (km)
  Position? _lastPosition; // 마지막 위치 정보 저장

  DateTime? startTime; // 플로깅 시작 시각
  DateTime? pauseStartTime; // 일시정지 시작 시각
  Duration pausedDuration = Duration.zero; // 총 일시정지 시간
  Timer? timer;
  int challengeGoal = 20; // 챌린지 목표 수집 개수
  int collectedItems = 0; // 현재 수집한 쓰레기 개수
  StreamSubscription<StepCount>? pedometerSubscription;

  XFile? _pickedImage; // 종료 시 촬영한 이미지 파일

  // 플로깅 시작 이후 경과 시간 계산
  Duration get _elapsedTime {
    if (startTime == null) return Duration.zero;

    final now = DateTime.now();
    final totalElapsed = now.difference(startTime!);

    return totalElapsed - pausedDuration; // 일시정지 시간 제외한 경과 시간
  }

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndStartTracking(); // 위치 및 걸음 추적 권한 요청 및 시작
    _loadAndResumePlogging(); // 저장된 데이터 로드 및 재개
  }

  /// 위치 및 걸음 권한 요청 및 추적 시작
  Future<void> _requestPermissionsAndStartTracking() async {
    bool locationGranted = await _requestLocationPermission();

    if (locationGranted) {
      _startLocationTracking();
      _initializePedometer();
    } else {
      print('필수 권한이 부여되지 않았습니다.');
    }
  }

  // 위치 권한 요청 함수
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// 저장된 플로깅 데이터 불러오기 및 재개
  Future<void> _loadAndResumePlogging() async {
    final savedData = await loadPloggingData();

    if (savedData != null) {
      setState(() {
        steps = savedData.steps;
        pausedDuration = savedData.pausedDuration;
        isPaused = savedData.isPaused;
        isPlaying = savedData.isPlaying;
        collectedItems = savedData.collectedItems;
        challengeGoal = savedData.challengeGoal;
        totalDistance = savedData.totalDistance;
        startTime = savedData.startTime;
      });

      if (isPlaying) {
        _startTimer(); // 타이머 재개
        _startLocationTracking(); // 위치 추적 재개
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: isPaused ? Colors.white : PRIMARY_COLOR,
      child: isPaused
          ? PausedContent(
              resumeTimer: _resumeTimer,
              onEnd: _endPlogging,
            )
          : isPlaying
              ? PlayContent(
                  collectedItems: collectedItems,
                  challengeGoal: challengeGoal,
                  totalDistance: totalDistance,
                  steps: steps,
                  elapsedTime: _elapsedTime,
                  onPause: _pauseTimer,
                  onPickImage: _pickImage,
                )
              : ReadyContent(startPlogging: startPlogging),
    );
  }

  // 플로깅 시작 설정
  void startPlogging() {
    setState(() {
      isPlaying = true;
      startTime ??= DateTime.now();
      _startTimer();
    });
  }

  // 일시정지 상태에서 플로깅 재개
  void _resumeTimer() {
    if (pauseStartTime != null) {
      setState(() {
        pausedDuration +=
            DateTime.now().difference(pauseStartTime!); // 일시정지 시간 누적
        pauseStartTime = null;
        isPaused = false;
        _startTimer(); // 타이머 재개
      });
    }
  }

  // 타이머 시작
  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  // 타이머 일시정지
  void _pauseTimer() {
    if (pauseStartTime == null) {
      setState(() {
        pauseStartTime = DateTime.now(); // 일시정지 시작 시간 기록
        isPaused = true;
        timer?.cancel();
      });
    }
  }

  // 플로깅 종료 및 데이터 저장
  Future<void> _endPlogging() async {
    final endTime = DateTime.now();

    // 현재 로그인된 사용자 UID 가져오기
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('로그인된 사용자가 없습니다.');

      return;
    }

    final uid = user.uid;

    // 종료 이미지 촬영
    final picker = ImagePicker();
    _pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (_pickedImage == null) {
      _showErrorDialog('사진 촬영에 실패했습니다.');

      return;
    }

    // Firebase Storage에 이미지 업로드
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('plogging/result/${DateTime.now().toIso8601String()}');
    final uploadTask = storageRef.putFile(File(_pickedImage!.path));
    final imageUrl = await (await uploadTask).ref.getDownloadURL();

    // Firestore에 플로깅 데이터 저장
    await FirebaseFirestore.instance.collection('ploggings').add({
      'uid': uid,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'steps': steps,
      'totalDistance': totalDistance,
      'collectedItems': collectedItems,
      'imageUrl': imageUrl,
    });

    _resetPlogging(); // 플로깅 데이터 초기화
  }

  // 플로깅 데이터 초기화
  void _resetPlogging() {
    setState(() {
      isPlaying = false;
      isPaused = false;
      steps = 0;
      totalDistance = 0.0;
      startTime = null;
      pauseStartTime = null;
      pausedDuration = Duration.zero;
      collectedItems = 0;
    });
  }

  // 만보기 초기화 및 걸음 수 업데이트
  void _initializePedometer() {
    pedometerSubscription = Pedometer.stepCountStream.listen((event) {
      if (initialSteps == 0) {
        initialSteps = event.steps;
      }
      if (mounted) {
        setState(() {
          steps = event.steps - initialSteps;
        });
      }
    }, onError: (error) {
      _showErrorDialog('걸음 수 추적에 실패했습니다.');
    });
  }

  // 위치 추적 및 거리 계산
  void _startLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (_lastPosition != null) {
        final double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          totalDistance += distance / 1000; // m -> km 변환
        });
      }
      _lastPosition = position;
    });
  }

  // 카메라 사진 촬영 및 수집 아이템 추가
  Future<bool> _pickImage() async {
    try {
      setState(() {
        collectedItems += 1;
      });
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        print('사진 촬영 성공');

        return true; // 재활용품 인식 성공 시

        // 촬영 실패 시 로직
      }
      return false;
    } catch (e) {
      print('사진 촬영 오류: $e');
      _showErrorDialog('사진 촬영에 실패했습니다.');

      return false;
    }
  }

  // 오류 메시지 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    savePloggingData(
      PloggingPlayModel(
        steps: steps,
        isPaused: isPaused,
        isPlaying: isPlaying,
        collectedItems: collectedItems,
        challengeGoal: challengeGoal,
        totalDistance: totalDistance,
        startTime: startTime ?? DateTime.now(),
        pausedDuration: pausedDuration,
      ),
    );
    timer?.cancel();
    pedometerSubscription?.cancel();
    super.dispose();
  }
}
