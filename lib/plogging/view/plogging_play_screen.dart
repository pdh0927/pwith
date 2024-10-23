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

class PloggingPlayScreen extends StatefulWidget {
  const PloggingPlayScreen({super.key});

  @override
  State<PloggingPlayScreen> createState() => _PloggingPlayScreenState();
}

class _PloggingPlayScreenState extends State<PloggingPlayScreen> {
  bool isPlaying = false;
  bool isPaused = false;
  int steps = 0; // 현재 걸음 수
  int initialSteps = 0; // 초기 걸음 수 저장
  double totalDistance = 0.0; // 이동 거리 (km)
  Position? _lastPosition; // 이전 위치 저장

  DateTime? startTime; // 플로깅 시작 시각
  DateTime? pauseStartTime; // 일시정지 시작 시각
  Duration pausedDuration = Duration.zero; // 누적된 일시 정지 시각
  Timer? timer;
  int challengeGoal = 20; // 목표 수집 개수
  int collectedItems = 0; // 수집한 쓰레기 개수
  StreamSubscription<StepCount>? pedometerSubscription;

  // 종료 이미지 파일 변수
  XFile? _pickedImage;

  Duration get _elapsedTime {
    if (startTime == null) return Duration.zero;
    final now = DateTime.now();
    final totalElapsed = now.difference(startTime!);

    return totalElapsed - pausedDuration;
  }

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndStartTracking(); // 권한 요청 및 추적 시작
    _loadAndResumePlogging();
  }

  // 필수 권한 요청 및 GPS 시작
  Future<void> _requestPermissionsAndStartTracking() async {
    bool locationGranted = await _requestLocationPermission();
    if (locationGranted) {
      _startLocationTracking();
      _initializePedometer(); // 만보기 시작
    } else {
      print('필수 권한이 부여되지 않았습니다.');
    }
  }

  // 위치 권한 요청 및 확인
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

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
        _startTimer(); // 진행 중이었다면 타이머 재개
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

  // 플로깅 시작
  void startPlogging() {
    setState(() {
      isPlaying = true;
      startTime ??= DateTime.now();
      _startTimer();
    });
  }

  // 플로깅 재개
  void _resumeTimer() {
    if (pauseStartTime != null) {
      setState(() {
        // 누적 일시 정지 시간 업데이트
        pausedDuration += DateTime.now().difference(pauseStartTime!);
        pauseStartTime = null; // 일시 정지 시간 초기화
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

  // 타이머 멈춤
  void _pauseTimer() {
    if (pauseStartTime == null) {
      setState(() {
        pauseStartTime = DateTime.now(); // 일시 정지 시작 시간 기록
        isPaused = true;
        timer?.cancel(); // 타이머 중단
      });
    }
  }

  // 종료 버튼 로직
  Future<void> _endPlogging() async {
    final endTime = DateTime.now();

    // 1. 현재 로그인된 사용자의 UID 가져오기
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('로그인된 사용자가 없습니다.');
      return;
    }
    final uid = user.uid;

    // 2. 사진 촬영
    final picker = ImagePicker();
    _pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (_pickedImage == null) {
      _showErrorDialog('사진 촬영에 실패했습니다.');
      return;
    }

    // 3. Firebase Storage에 이미지 업로드
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('plogging/result/${DateTime.now().toIso8601String()}');
    final uploadTask = storageRef.putFile(File(_pickedImage!.path));
    final imageUrl = await (await uploadTask).ref.getDownloadURL();

    // 4. Firestore에 데이터 저장
    await FirebaseFirestore.instance.collection('ploggings').add({
      'uid': uid, // 사용자 UID 저장
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'steps': steps,
      'totalDistance': totalDistance,
      'collectedItems': collectedItems,
      'imageUrl': imageUrl,
    });

    // 5. 플로깅 초기화 및 화면 종료
    _resetPlogging();
  }

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

  // GPS 위치 추적 시작
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

  /// **카메라 사진 촬영**
  Future<void> _pickImage() async {
    try {
      setState(() {
        collectedItems += 1;
      });
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        print('사진 촬영 성공');
      }
    } catch (e) {
      print('사진 촬영 오류: $e');
      _showErrorDialog('사진 촬영에 실패했습니다.');
    }
  }

  /// 에러 다이얼로그 표시
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
