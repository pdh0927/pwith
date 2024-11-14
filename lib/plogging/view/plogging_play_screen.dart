import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer/pedometer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:pwith/common/const/text_style.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/plogging/view/finish_screen.dart';
import 'package:pwith/plogging/component/plogging_play/paused_content.dart';
import 'package:pwith/plogging/model/plogging_model.dart';
import 'package:pwith/plogging/shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

// 플로깅 중 일 때 내용
class PloggingPlayScreen extends StatefulWidget {
  const PloggingPlayScreen({
    super.key,
  });

  @override
  State<PloggingPlayScreen> createState() => _PloggingPlayScreenState();
}

class _PloggingPlayScreenState extends State<PloggingPlayScreen> {
  PloggingState ploggingState = PloggingState.playing;

  int steps = 0; // 총 걸음 수
  int initialSteps = 0;
  double totalDistance = 0.0; // 총 이동 거리
  Position? _lastPosition;
  DateTime? startTime;
  DateTime? pauseStartTime;
  Duration pausedDuration = Duration.zero;
  Timer? timer;
  int challengeGoal = 20; // 챌린지 목표 아이템 수
  String challengeDescription = '플라스틱 20개 줍기';
  int collectedItems = 0; // 현재 수집된 아이템 수
  StreamSubscription<Position>? positionStreamSubscription;
  StreamSubscription<StepCount>? pedometerSubscription;
  String? imageUrl;

  Duration get elapsedTime {
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
    _startPlogging();
  }

  // 챌린지 목표와 설명을 Firebase에서 가져오기
  Future<void> _initializeChallenge() async {
    challengeGoal = await _fetchChallengeGoal();
    challengeDescription = await _fetchChallengeDescription();
    setState(() {});
  }

  Future<int> _fetchChallengeGoal() async => 20;
  Future<String> _fetchChallengeDescription() async => '플라스틱 20개 줍기';

  Future<void> _requestPermissionsAndStartTracking() async {
    if (await _requestLocationPermission()) {
      _startLocationTracking();
      _initializePedometer();
    } else {
      print('필수 권한이 부여되지 않았습니다.');
    }
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
        ploggingState = savedData.ploggingState;
      });
      if (ploggingState == PloggingState.playing) {
        _startTimer();
        _startLocationTracking();
      }
    }
  }

  // 위치 추적을 시작하고 스트림을 구독합니다.
  void _startLocationTracking() {
    const double minDistanceChange = 5.0; // 최소 이동 거리 (미터)

    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 여전히 10으로 설정하여 너무 잦은 업데이트 방지
      ),
    ).listen((Position position) {
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance >= minDistanceChange) {
          // 최소 이동 거리 조건
          if (mounted) {
            setState(() {
              totalDistance += distance / 1000;
            });
          }
        }
      }
      _lastPosition = position;
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

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void _startPlogging() {
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

  @override
  void dispose() {
    // 구독 및 타이머 모두 해제
    positionStreamSubscription?.cancel();
    pedometerSubscription?.cancel();
    timer?.cancel();
    savePloggingData(
      PloggingPlayModel(
        steps: steps,
        ploggingState: ploggingState,
        collectedItems: collectedItems,
        challengeGoal: challengeGoal,
        challengeDescription: challengeDescription,
        totalDistance: totalDistance,
        startTime: startTime ?? DateTime.now(),
        pausedDuration: pausedDuration,
      ),
    );
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    double challengeProgress =
        (collectedItems / challengeGoal) * 100; // 챌린지 진행률 계산

    return DefaultLayout(
      backgroundColor: PRIMARY_COLOR,
      child: ploggingState == PloggingState.playing
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoRow(challengeProgress), // 상단 정보 표시 위젯
                    _buildDistanceAndTrashInfo(context), // 중앙 거리 및 챌린지 정보 표시 위젯
                    _buildControlButtons(), // 하단 제어 버튼
                  ],
                ),
              ),
            )
          : PausedContent(
              resumeTimer: _resumeTimer,
              onEnd: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinishScreen(
                      steps: steps,
                      elapsedTime: elapsedTime,
                      totalDistance: totalDistance,
                      challengeDescription: challengeDescription,
                      collectedItems: collectedItems,
                      challengeGoal: challengeGoal,
                      startTime: startTime!,
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 상단(걸음수 및 시간) 정보를 표시하는 위젯
  Widget _buildInfoRow(double challengeProgress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _infoColumn('걸음수', PhosphorIconsFill.footprints, '$steps'), // 걸음수 정보
        _infoColumn('시간', PhosphorIconsFill.clock,
            _formatTime(elapsedTime)), // 경과 시간 정보
      ],
    );
  }

  // 개별 정보(아이콘 + 값) 열 구성
  Widget _infoColumn(String label, IconData iconData, String value) {
    return Container(
      width: (100.w - 32) / 2,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Colors.white), // 아이콘
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: plogging_text_style), // 라벨 텍스트
        ],
      ),
    );
  }

  // 중앙에 총 거리 및 챌린지 정보를 표시하는 위젯
  Widget _buildDistanceAndTrashInfo(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              totalDistance.toStringAsFixed(2), // 총 거리
              style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              '킬로미터',
              style: plogging_text_style.copyWith(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildChallengeInfo(context), // 챌린지 정보 버튼
      ],
    );
  }

  // 챌린지 정보 버튼과 팝업 구현
  Widget _buildChallengeInfo(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            int updatedCollectedItems =
                collectedItems; // 팝업에서 실시간으로 업데이트될 아이템 수

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    "Today's 챌린지",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        challengeDescription, // 챌린지 설명 표시
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$updatedCollectedItems / $challengeGoal', // 현재 진행 상태
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (await _pickImage()) {
                            setState(() {
                              updatedCollectedItems++; // 아이템 수 업데이트
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 5,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: Colors.green,
          ),
          SizedBox(width: 10),
          Text(
            '챌린지',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // 하단 제어 버튼 (일시정지 버튼)
  Widget _buildControlButtons() {
    return IconButton(
      icon: const Icon(PhosphorIconsFill.pause, size: 50, color: Colors.white),
      onPressed: _pauseTimer,
    );
  }

  // 시간 형식 변환 함수
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours); // 시간 추출
    String minutes = twoDigits(duration.inMinutes.remainder(60)); // 분 추출
    String seconds = twoDigits(duration.inSeconds.remainder(60)); // 초 추출

    return '$hours:$minutes:$seconds'; // HH:MM:SS 형식 반환
  }
}
