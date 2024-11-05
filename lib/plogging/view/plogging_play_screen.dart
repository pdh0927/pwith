import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer/pedometer.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/plogging/component/plogging_play/finish_content.dart';
import 'package:pwith/plogging/component/plogging_play/paused_content.dart';
import 'package:pwith/plogging/component/plogging_play/play_content.dart';
import 'package:pwith/plogging/component/plogging_play/ready_content.dart';
import 'package:pwith/plogging/model/plogging_model.dart';
import 'package:pwith/plogging/shared_preferences/shared_preferences.dart';

// 플로깅 상태를 관리하는 enum
enum PloggingState { ready, playing, paused, finished }

class PloggingPlayScreen extends StatefulWidget {
  const PloggingPlayScreen({super.key});

  @override
  State<PloggingPlayScreen> createState() => _PloggingPlayScreenState();
}

class _PloggingPlayScreenState extends State<PloggingPlayScreen> {
  PloggingState ploggingState = PloggingState.ready; // 초기 상태: ready
  int steps = 0;
  int initialSteps = 0;
  double totalDistance = 0.0;
  Position? _lastPosition;
  DateTime? startTime;
  DateTime? pauseStartTime;
  Duration pausedDuration = Duration.zero;
  Timer? timer;
  int challengeGoal = 20;
  String challengeDescription = '플라스틱 20개 줍기';
  int collectedItems = 0;
  StreamSubscription<StepCount>? pedometerSubscription;
  String? imageUrl;

  Duration get _elapsedTime {
    if (startTime == null) return Duration.zero;
    final now = DateTime.now();
    final totalElapsed = now.difference(startTime!);
    return totalElapsed - pausedDuration;
  }

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndStartTracking();
    _loadAndResumePlogging();
    _initializeChallenge();
  }

  // 챌린지 목표와 설명을 Firebase에서 가져오기
  Future<void> _initializeChallenge() async {
    challengeGoal = await fetchChallengeGoal();
    challengeDescription = await fetchChallengeDescription();
    setState(() {});
  }

  Future<int> fetchChallengeGoal() async => 20;
  Future<String> fetchChallengeDescription() async => '플라스틱 20개 줍기';

  Future<void> _requestPermissionsAndStartTracking() async {
    if (await _requestLocationPermission()) {
      _startLocationTracking();
      _initializePedometer();
    } else {
      print('필수 권한이 부여되지 않았습니다.');
    }
  }

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
        collectedItems = savedData.collectedItems;
        challengeGoal = savedData.challengeGoal;
        challengeDescription = savedData.challengeDescription;
        totalDistance = savedData.totalDistance;
        startTime = savedData.startTime;
        ploggingState = savedData.isPlaying
            ? PloggingState.playing
            : savedData.isPaused
                ? PloggingState.paused
                : PloggingState.ready;
      });
      if (ploggingState == PloggingState.playing) {
        _startTimer();
        _startLocationTracking();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor:
          ploggingState == PloggingState.paused ? Colors.white : PRIMARY_COLOR,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (ploggingState) {
      case PloggingState.ready:
        return ReadyContent(startPlogging: startPlogging);
      case PloggingState.playing:
        return PlayContent(
          collectedItems: collectedItems,
          challengeGoal: challengeGoal,
          challengeDescription: challengeDescription,
          totalDistance: totalDistance,
          steps: steps,
          elapsedTime: _elapsedTime,
          onPause: _pauseTimer,
          onPickImage: _pickImage,
        );
      case PloggingState.paused:
        return PausedContent(
          resumeTimer: _resumeTimer,
          onEnd: _endPlogging,
        );
      case PloggingState.finished:
        return FinishContent(
          imageUrl: imageUrl,
          steps: steps,
          elapsedTime: _elapsedTime,
          totalDistance: totalDistance,
          challengeDescription: challengeDescription,
          collectedItems: collectedItems,
          challengeGoal: challengeGoal,
          onCaptureImage: _captureImage,
          onClose: _resetToReadyState, // 닫기 버튼 시 ready 상태로 복귀
        );
    }
  }

  void _captureImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('plogging/result/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(File(pickedImage.path));
      imageUrl = await (await uploadTask).ref.getDownloadURL();
      setState(() {});
    }
  }

  void startPlogging() {
    setState(() {
      ploggingState = PloggingState.playing;
      startTime ??= DateTime.now();
      _startTimer();
    });
  }

  void _pauseTimer() {
    setState(() {
      pauseStartTime = DateTime.now();
      ploggingState = PloggingState.paused;
      timer?.cancel();
    });
  }

  void _resumeTimer() {
    setState(() {
      pausedDuration += DateTime.now().difference(pauseStartTime!);
      pauseStartTime = null;
      ploggingState = PloggingState.playing;
      _startTimer();
    });
  }

  Future<void> _endPlogging() async {
    setState(() {
      ploggingState = PloggingState.finished;
    });

    timer?.cancel(); // 타이머 중지
    pedometerSubscription?.cancel(); // 위치 추적 중지
  }

  void _resetToReadyState() {
    setState(() {
      ploggingState = PloggingState.ready;
      _resetPlogging(); // 플로깅 데이터를 초기화
    });
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _initializePedometer() {
    pedometerSubscription = Pedometer.stepCountStream.listen((event) {
      if (initialSteps == 0) initialSteps = event.steps;
      setState(() {
        steps = event.steps - initialSteps;
      });
    }, onError: (error) {
      _showErrorDialog('걸음 수 추적에 실패했습니다.');
    });
  }

  void _startLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          totalDistance += distance / 1000;
        });
      }
      _lastPosition = position;
    });
  }

  Future<bool> _pickImage() async {
    try {
      setState(() {
        collectedItems += 1;
      });
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      return image != null;
    } catch (e) {
      _showErrorDialog('사진 촬영에 실패했습니다.');
      return false;
    }
  }

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

  void _resetPlogging() {
    setState(() {
      steps = 0;
      totalDistance = 0.0;
      startTime = null;
      pauseStartTime = null;
      pausedDuration = Duration.zero;
      collectedItems = 0;
      challengeDescription = '플라스틱 20개 줍기';
      challengeGoal = 20;
    });
  }

  @override
  void dispose() {
    savePloggingData(
      PloggingPlayModel(
        steps: steps,
        isPaused: ploggingState == PloggingState.paused,
        isPlaying: ploggingState == PloggingState.playing,
        collectedItems: collectedItems,
        challengeGoal: challengeGoal,
        challengeDescription: challengeDescription,
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
