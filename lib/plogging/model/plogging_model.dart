class PloggingPlayModel {
  final int steps; // 걸음 수
  final Duration elapsedTime; // 경과 시간
  final bool isPaused; // 일시 정지 여부
  final bool isPlaying; // 진행 중인지 여부
  final int collectedItems; // 수집한 쓰레기 개수
  final int challengeGoal; // 챌린지 목표 개수
  final double totalDistance; // 총 이동 거리 (km)
  final DateTime startTime; // 플로깅 시작 시간
  final DateTime? endTime; // 종료 시간

  const PloggingPlayModel({
    required this.steps,
    required this.elapsedTime,
    required this.isPaused,
    required this.isPlaying,
    required this.collectedItems,
    required this.challengeGoal,
    required this.totalDistance,
    required this.startTime,
    this.endTime,
  });

  // **JSON으로 변환하기 위한 함수**
  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'elapsedTime': elapsedTime.inSeconds,
      'isPaused': isPaused,
      'isPlaying': isPlaying,
      'collectedItems': collectedItems,
      'challengeGoal': challengeGoal,
      'totalDistance': totalDistance,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  // **JSON에서 모델로 변환하는 함수**
  factory PloggingPlayModel.fromJson(Map<String, dynamic> json) {
    return PloggingPlayModel(
      steps: json['steps'],
      elapsedTime: Duration(seconds: json['elapsedTime']),
      isPaused: json['isPaused'],
      isPlaying: json['isPlaying'],
      collectedItems: json['collectedItems'],
      challengeGoal: json['challengeGoal'],
      totalDistance: json['totalDistance'].toDouble(),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  // **copyWith 메서드 추가**
  PloggingPlayModel copyWith({
    int? steps,
    Duration? elapsedTime,
    bool? isPaused,
    bool? isPlaying,
    int? collectedItems,
    int? challengeGoal,
    double? totalDistance,
    DateTime? startTime,
    DateTime? endTime,
    List<Map<String, double>>? locationHistory,
  }) {
    return PloggingPlayModel(
      steps: steps ?? this.steps,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isPaused: isPaused ?? this.isPaused,
      isPlaying: isPlaying ?? this.isPlaying,
      collectedItems: collectedItems ?? this.collectedItems,
      challengeGoal: challengeGoal ?? this.challengeGoal,
      totalDistance: totalDistance ?? this.totalDistance,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
