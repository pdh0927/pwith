// 플로깅 상태를 관리하는 enum
enum PloggingState { playing, paused }

class PloggingPlayModel {
  final int steps; // 걸음 수
  final PloggingState ploggingState; // 진행 중인지 여부
  final int collectedItems; // 수집한 쓰레기 개수
  final int challengeGoal; // 챌린지 목표 개수
  final double totalDistance; // 총 이동 거리 (km)
  final DateTime startTime; // 플로깅 시작 시간
  final Duration pausedDuration; // 일시 정지된 시간 총합
  final DateTime? endTime; // 종료 시간
  final String challengeDescription; // 챌린지 설명

  const PloggingPlayModel({
    required this.steps,
    required this.ploggingState,
    required this.collectedItems,
    required this.challengeGoal,
    required this.totalDistance,
    required this.startTime,
    required this.pausedDuration,
    required this.challengeDescription,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'ploggingState':
          ploggingState == PloggingState.playing ? 'playing' : 'paused',
      'collectedItems': collectedItems,
      'challengeGoal': challengeGoal,
      'totalDistance': totalDistance,
      'startTime': startTime.toIso8601String(),
      'pausedDuration': pausedDuration.inSeconds,
      'endTime': endTime?.toIso8601String(),
      'challengeDescription': challengeDescription,
    };
  }

  factory PloggingPlayModel.fromJson(Map<String, dynamic> json) {
    return PloggingPlayModel(
      steps: json['steps'],
      ploggingState: json['ploggingState'] == 'playing'
          ? PloggingState.playing
          : PloggingState.paused,
      collectedItems: json['collectedItems'],
      challengeGoal: json['challengeGoal'],
      totalDistance: json['totalDistance'].toDouble(),
      startTime: DateTime.parse(json['startTime']),
      pausedDuration: Duration(seconds: json['pausedDuration']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      challengeDescription: json['challengeDescription'] ?? 'No description',
    );
  }
}
