/// An async score challenge between the local player and a friend.
///
/// Challenges are stored locally and resolved when the challenged
/// friend completes the same game. In offline mode both players
/// can pass the same device back and forth (hot-seat style).
class Challenge {
  final String id;
  final String gameId; // 'quiz', 'math', 'memory', etc.
  final String fromPlayerId;
  final String fromPlayerName;
  final int fromScore;
  final int fromCorrect;
  String? toPlayerId; // null = open challenge
  String status; // 'pending', 'accepted', 'completed', 'declined'
  int? toScore;
  int? toCorrect;
  final DateTime createdAt;
  DateTime? completedAt;

  Challenge({
    required this.id,
    required this.gameId,
    required this.fromPlayerId,
    required this.fromPlayerName,
    required this.fromScore,
    required this.fromCorrect,
    this.toPlayerId,
    this.status = 'pending',
    this.toScore,
    this.toCorrect,
    required this.createdAt,
    this.completedAt,
  });

  /// true when the local player (toPlayer) beat the challenger.
  bool? get localWon {
    if (status != 'completed' || toScore == null) return null;
    return toScore! > fromScore;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameId': gameId,
    'fromPlayerId': fromPlayerId,
    'fromPlayerName': fromPlayerName,
    'fromScore': fromScore,
    'fromCorrect': fromCorrect,
    'toPlayerId': toPlayerId,
    'status': status,
    'toScore': toScore,
    'toCorrect': toCorrect,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'] ?? '',
    gameId: json['gameId'] ?? '',
    fromPlayerId: json['fromPlayerId'] ?? '',
    fromPlayerName: json['fromPlayerName'] ?? '',
    fromScore: json['fromScore'] ?? 0,
    fromCorrect: json['fromCorrect'] ?? 0,
    toPlayerId: json['toPlayerId'],
    status: json['status'] ?? 'pending',
    toScore: json['toScore'],
    toCorrect: json['toCorrect'],
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    completedAt: json['completedAt'] != null
        ? DateTime.tryParse(json['completedAt'])
        : null,
  );
}
