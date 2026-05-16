/// A friend connection stored locally in the child's profile.
///
/// Since the app is offline-first, friends are added by referral code
/// and their stats are snapshots that can be refreshed when both
/// players are on the same device or via shared codes.
class Friend {
  final String id;
  String name;
  int avatarIndex;
  int botakoins;
  int totalGamesPlayed;
  int level;
  String referralCode;
  DateTime addedAt;
  DateTime? lastActive;

  Friend({
    required this.id,
    required this.name,
    this.avatarIndex = 0,
    this.botakoins = 0,
    this.totalGamesPlayed = 0,
    this.level = 1,
    this.referralCode = '',
    required this.addedAt,
    this.lastActive,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarIndex': avatarIndex,
    'botakoins': botakoins,
    'totalGamesPlayed': totalGamesPlayed,
    'level': level,
    'referralCode': referralCode,
    'addedAt': addedAt.toIso8601String(),
    'lastActive': lastActive?.toIso8601String(),
  };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    avatarIndex: json['avatarIndex'] ?? 0,
    botakoins: json['botakoins'] ?? 0,
    totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
    level: json['level'] ?? 1,
    referralCode: json['referralCode'] ?? '',
    addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
    lastActive: json['lastActive'] != null
        ? DateTime.tryParse(json['lastActive'])
        : null,
  );
}
