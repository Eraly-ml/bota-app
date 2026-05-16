import 'coupon.dart';
import 'friend.dart';
import 'challenge.dart';

class ChildProfile {
  String name;
  int age;
  int botakoins;
  int totalGamesPlayed;
  int totalCorrectAnswers;
  Map<String, int> gameBestScores;
  List<String> achievements;
  List<String> unlockedLocations;
  DateTime? lastPlayDate;
  int dailyMinutesUsed;
  int screenTimeLimit;
  int avatarIndex;
  String referralCode;
  int friendsInvited;
  bool dailyQuestCompleted;
  String? lastDailyQuestDate;
  List<Coupon> purchasedCoupons;
  int couponsRedeemed;
  int mathProblemsSolved;
  int quizQuestionsAnswered;
  int memoryPairsFound;
  int yurtsBuilt;
  Map<String, int> dailyMinutes;
  int currentStreak;
  String? lastActiveDate;
  bool soundMuted;
  List<Friend> friends;
  List<Challenge> challenges;

  ChildProfile({
    this.name = '',
    this.age = 7,
    this.botakoins = 0,
    this.totalGamesPlayed = 0,
    this.totalCorrectAnswers = 0,
    Map<String, int>? gameBestScores,
    List<String>? achievements,
    List<String>? unlockedLocations,
    this.lastPlayDate,
    this.dailyMinutesUsed = 0,
    this.screenTimeLimit = 30,
    this.avatarIndex = 0,
    this.referralCode = '',
    this.friendsInvited = 0,
    this.dailyQuestCompleted = false,
    this.lastDailyQuestDate,
    List<Coupon>? purchasedCoupons,
    this.couponsRedeemed = 0,
    this.mathProblemsSolved = 0,
    this.quizQuestionsAnswered = 0,
    this.memoryPairsFound = 0,
    this.yurtsBuilt = 0,
    Map<String, int>? dailyMinutes,
    this.currentStreak = 1,
    this.lastActiveDate,
    this.soundMuted = false,
    List<Friend>? friends,
    List<Challenge>? challenges,
  })  : gameBestScores = gameBestScores ?? {},
        achievements = achievements ?? [],
        unlockedLocations = unlockedLocations ?? ['almaty'],
        purchasedCoupons = purchasedCoupons ?? [],
        dailyMinutes = dailyMinutes ?? {},
        friends = friends ?? [],
        challenges = challenges ?? [];

  int get level {
    if (totalGamesPlayed < 3) return 1;
    if (totalGamesPlayed < 8) return 2;
    if (totalGamesPlayed < 15) return 3;
    if (totalGamesPlayed < 25) return 4;
    return 5;
  }

  String get levelTitle {
    switch (level) {
      case 1:
        return 'Жас Зерттеуші';
      case 2:
        return 'Білгір Бала';
      case 3:
        return 'Батыл Саяхатшы';
      case 4:
        return 'Дана Жігіт';
      case 5:
        return 'Ұлы Зерттеуші';
      default:
        return 'Жас Зерттеуші';
    }
  }

  double get progressToNextLevel {
    final thresholds = [0, 3, 8, 15, 25, 50];
    final currentThreshold = thresholds[level - 1];
    final nextThreshold = thresholds[level < 5 ? level : 4];
    if (nextThreshold == currentThreshold) return 1.0;
    return (totalGamesPlayed - currentThreshold) /
        (nextThreshold - currentThreshold);
  }
}
