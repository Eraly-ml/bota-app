import 'dart:async';
import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/coupon.dart';
import '../models/friend.dart';
import '../models/challenge.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../services/supabase_service.dart';
import '../data/locale_strings.dart';

class GameProvider extends ChangeNotifier {
  ChildProfile _profile = ChildProfile();
  bool _isRussian = true;
  bool _onboardingComplete = false;
  bool _parentModeActive = false;
  bool _isLoaded = false;
  bool _isTtsEnabled = true;
  final String _parentPin = '1234';
  DateTime? _sessionStart;
  bool _screenTimeLimitReached = false;
  Timer? _minuteTicker;

  ChildProfile get profile => _profile;
  bool get isRussian => _isRussian;
  bool get onboardingComplete => _onboardingComplete;
  bool get parentModeActive => _parentModeActive;
  bool get screenTimeLimitReached => _screenTimeLimitReached;
  bool get isLoaded => _isLoaded;
  bool get isTtsEnabled => _isTtsEnabled;

  String t(String kz, String ru) => _isRussian ? ru : kz;

  GameProvider() {
    _loadProfile();
    _sessionStart = DateTime.now();
    _minuteTicker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _tickMinute(),
    );
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    _minuteTicker = null;
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _isTtsEnabled = prefs.getBool('isTtsEnabled') ?? true;
    final profileJson = prefs.getString('child_profile');
    if (profileJson != null) {
      try {
        final data = json.decode(profileJson) as Map<String, dynamic>;
        final rawScores = data['gameBestScores'];
        final scores = <String, int>{};
        if (rawScores is Map) {
          rawScores.forEach((k, v) {
            if (v is int) {
              scores[k.toString()] = v;
            } else if (v is num) {
              scores[k.toString()] = v.toInt();
            }
          });
        }
        final rawCoupons = data['purchasedCoupons'];
        final coupons = <Coupon>[];
        if (rawCoupons is List) {
          for (final c in rawCoupons) {
            if (c is Map<String, dynamic>) {
              coupons.add(Coupon.fromJson(c));
            } else if (c is Map) {
              coupons.add(Coupon.fromJson(Map<String, dynamic>.from(c)));
            }
          }
        }
        final rawDailyMinutes = data['dailyMinutes'];
        final dailyMinutes = <String, int>{};
        if (rawDailyMinutes is Map) {
          rawDailyMinutes.forEach((k, v) {
            if (v is int) {
              dailyMinutes[k.toString()] = v;
            } else if (v is num) {
              dailyMinutes[k.toString()] = v.toInt();
            }
          });
        }
        final rawFriends = data['friends'];
        final friends = <Friend>[];
        if (rawFriends is List) {
          for (final f in rawFriends) {
            if (f is Map<String, dynamic>) {
              friends.add(Friend.fromJson(f));
            } else if (f is Map) {
              friends.add(Friend.fromJson(Map<String, dynamic>.from(f)));
            }
          }
        }
        final rawChallenges = data['challenges'];
        final challenges = <Challenge>[];
        if (rawChallenges is List) {
          for (final c in rawChallenges) {
            if (c is Map<String, dynamic>) {
              challenges.add(Challenge.fromJson(c));
            } else if (c is Map) {
              challenges.add(Challenge.fromJson(Map<String, dynamic>.from(c)));
            }
          }
        }
        _profile = ChildProfile(
          name: data['name'] ?? '',
          age: data['age'] ?? 7,
          botakoins: data['botakoins'] ?? 0,
          totalGamesPlayed: data['totalGamesPlayed'] ?? 0,
          totalCorrectAnswers: data['totalCorrectAnswers'] ?? 0,
          gameBestScores: scores,
          achievements: List<String>.from(data['achievements'] ?? []),
          unlockedLocations: List<String>.from(data['unlockedLocations'] ?? ['almaty']),
          dailyMinutesUsed: data['dailyMinutesUsed'] ?? 0,
          screenTimeLimit: data['screenTimeLimit'] ?? 30,
          avatarIndex: data['avatarIndex'] ?? 0,
          referralCode: data['referralCode'] ?? '',
          friendsInvited: data['friendsInvited'] ?? 0,
          dailyQuestCompleted: data['dailyQuestCompleted'] ?? false,
          lastDailyQuestDate: data['lastDailyQuestDate'],
          purchasedCoupons: coupons,
          couponsRedeemed: data['couponsRedeemed'] ?? 0,
          mathProblemsSolved: data['mathProblemsSolved'] ?? 0,
          quizQuestionsAnswered: data['quizQuestionsAnswered'] ?? 0,
          memoryPairsFound: data['memoryPairsFound'] ?? 0,
          yurtsBuilt: data['yurtsBuilt'] ?? 0,
          dailyMinutes: dailyMinutes,
          currentStreak: data['currentStreak'] ?? 1,
          lastActiveDate: data['lastActiveDate'],
          soundMuted: data['soundMuted'] == true,
          friends: friends,
          challenges: challenges,
        );
        _onboardingComplete = data['onboardingComplete'] ?? false;
        _isRussian = data['isRussian'] ?? true;
      } catch (e) {
        debugPrint('Error loading profile: $e');
        _profile = ChildProfile();
      }
    }
    LocaleStrings.setLanguage(_isRussian ? 'ru' : 'kk');
    _checkDailyQuestReset();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': _profile.name,
      'age': _profile.age,
      'botakoins': _profile.botakoins,
      'totalGamesPlayed': _profile.totalGamesPlayed,
      'totalCorrectAnswers': _profile.totalCorrectAnswers,
      'gameBestScores': _profile.gameBestScores,
      'achievements': _profile.achievements,
      'unlockedLocations': _profile.unlockedLocations,
      'dailyMinutesUsed': _profile.dailyMinutesUsed,
      'screenTimeLimit': _profile.screenTimeLimit,
      'onboardingComplete': _onboardingComplete,
      'isRussian': _isRussian,
      'avatarIndex': _profile.avatarIndex,
      'referralCode': _profile.referralCode,
      'friendsInvited': _profile.friendsInvited,
      'dailyQuestCompleted': _profile.dailyQuestCompleted,
      'lastDailyQuestDate': _profile.lastDailyQuestDate,
      'purchasedCoupons': _profile.purchasedCoupons.map((c) => c.toJson()).toList(),
      'couponsRedeemed': _profile.couponsRedeemed,
      'mathProblemsSolved': _profile.mathProblemsSolved,
      'quizQuestionsAnswered': _profile.quizQuestionsAnswered,
      'memoryPairsFound': _profile.memoryPairsFound,
      'yurtsBuilt': _profile.yurtsBuilt,
      'dailyMinutes': _profile.dailyMinutes,
      'currentStreak': _profile.currentStreak,
      'lastActiveDate': _profile.lastActiveDate,
      'soundMuted': _profile.soundMuted,
      'friends': _profile.friends.map((f) => f.toJson()).toList(),
      'challenges': _profile.challenges.map((c) => c.toJson()).toList(),
    };
    await prefs.setString('child_profile', json.encode(data));
    _syncToCloud();
  }

  Future<void> _syncToCloud() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = DateTime.now().microsecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    await SupabaseService.syncProfile(
      deviceId: deviceId,
      profileData: {
        'name': _profile.name,
        'age': _profile.age,
        'botakoins': _profile.botakoins,
        'total_games_played': _profile.totalGamesPlayed,
        'total_correct_answers': _profile.totalCorrectAnswers,
        'achievements': _profile.achievements,
        'unlocked_locations': _profile.unlockedLocations,
        'screen_time_limit': _profile.screenTimeLimit,
        'daily_minutes_used': _profile.dailyMinutesUsed,
      },
    );
  }

  void toggleLanguage() {
    _isRussian = !_isRussian;
    LocaleStrings.setLanguage(_isRussian ? 'ru' : 'kk');
    _saveProfile();
    notifyListeners();
  }

  Future<void> toggleTts() async {
    _isTtsEnabled = !_isTtsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTtsEnabled', _isTtsEnabled);
    notifyListeners();
  }

  String _generateReferralCode(String name) {
    final rng = Random();
    final cleaned = name.toUpperCase().replaceAll(' ', '');
    final prefix = cleaned.substring(0, cleaned.length.clamp(0, 4));
    return '$prefix${rng.nextInt(9000) + 1000}';
  }

  void completeOnboarding(String name, int age, int avatarIndex) {
    _profile.name = name;
    _profile.age = age;
    _profile.avatarIndex = avatarIndex;
    _profile.referralCode = _generateReferralCode(name);
    _onboardingComplete = true;
    _profile.unlockedLocations = ['almaty', 'astana'];
    _addAchievement('first_step');
    _saveProfile();
    notifyListeners();
  }

  void setAvatar(int index) {
    _profile.avatarIndex = index;
    _saveProfile();
    notifyListeners();
  }

  void inviteFriend() {
    _profile.friendsInvited++;
    addBotakoins(15);
  }

  void redeemReferralCode(String code) {
    if (code.isNotEmpty) {
      addBotakoins(15);
    }
  }

  // ─── Friend system ───

  Friend? addFriend(String name, int avatarIndex, int botakoins,
      int totalGamesPlayed, int level, String referralCode) {
    if (name.trim().isEmpty) return null;
    final id = 'f-${DateTime.now().millisecondsSinceEpoch}-${_randomCode(4)}';
    final friend = Friend(
      id: id,
      name: name.trim(),
      avatarIndex: avatarIndex,
      botakoins: botakoins,
      totalGamesPlayed: totalGamesPlayed,
      level: level,
      referralCode: referralCode,
      addedAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
    _profile.friends.add(friend);
    _saveProfile();
    notifyListeners();
    return friend;
  }

  void removeFriend(String friendId) {
    _profile.friends.removeWhere((f) => f.id == friendId);
    _profile.challenges.removeWhere((c) =>
        c.toPlayerId == friendId || c.fromPlayerId == friendId);
    _saveProfile();
    notifyListeners();
  }

  void updateFriendStats(String friendId,
      {int? botakoins, int? totalGamesPlayed, int? level}) {
    final friend = _profile.friends.firstWhere(
      (f) => f.id == friendId,
      orElse: () => Friend(id: '', name: '', addedAt: DateTime.now()),
    );
    if (friend.id.isEmpty) return;
    if (botakoins != null) friend.botakoins = botakoins;
    if (totalGamesPlayed != null) friend.totalGamesPlayed = totalGamesPlayed;
    if (level != null) friend.level = level;
    friend.lastActive = DateTime.now();
    _saveProfile();
    notifyListeners();
  }

  // ─── Challenge system ───

  Challenge? createChallenge(String gameId, int fromScore, int fromCorrect,
      {String? toPlayerId}) {
    final id =
        'ch-${DateTime.now().millisecondsSinceEpoch}-${_randomCode(4)}';
    final challenge = Challenge(
      id: id,
      gameId: gameId,
      fromPlayerId: 'me',
      fromPlayerName: _profile.name.isNotEmpty ? _profile.name : 'Player',
      fromScore: fromScore,
      fromCorrect: fromCorrect,
      toPlayerId: toPlayerId,
      createdAt: DateTime.now(),
    );
    _profile.challenges.add(challenge);
    _saveProfile();
    notifyListeners();
    return challenge;
  }

  void acceptChallenge(String challengeId, String playerId) {
    final challenge = _profile.challenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => Challenge(
          id: '', gameId: '', fromPlayerId: '', fromPlayerName: '', fromScore: 0, fromCorrect: 0, createdAt: DateTime.now()),
    );
    if (challenge.id.isEmpty) return;
    challenge.status = 'accepted';
    challenge.toPlayerId = playerId;
    _saveProfile();
    notifyListeners();
  }

  void resolveChallenge(String challengeId, int toScore, int toCorrect) {
    final challenge = _profile.challenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => Challenge(
          id: '', gameId: '', fromPlayerId: '', fromPlayerName: '', fromScore: 0, fromCorrect: 0, createdAt: DateTime.now()),
    );
    if (challenge.id.isEmpty) return;
    challenge.toScore = toScore;
    challenge.toCorrect = toCorrect;
    challenge.status = 'completed';
    challenge.completedAt = DateTime.now();
    if (toScore > challenge.fromScore) {
      addBotakoins(10);
    }
    _saveProfile();
    notifyListeners();
  }

  void declineChallenge(String challengeId) {
    final challenge = _profile.challenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => Challenge(
          id: '', gameId: '', fromPlayerId: '', fromPlayerName: '', fromScore: 0, fromCorrect: 0, createdAt: DateTime.now()),
    );
    if (challenge.id.isEmpty) return;
    challenge.status = 'declined';
    _saveProfile();
    notifyListeners();
  }

  void deleteChallenge(String challengeId) {
    _profile.challenges.removeWhere((c) => c.id == challengeId);
    _saveProfile();
    notifyListeners();
  }

  List<Challenge> getActiveChallenges() {
    return _profile.challenges
        .where((c) => c.status == 'pending' || c.status == 'accepted')
        .toList();
  }

  List<Challenge> getCompletedChallenges() {
    return _profile.challenges
        .where((c) => c.status == 'completed')
        .toList();
  }

  Challenge? findActiveChallengeForGame(String gameId) {
    try {
      return _profile.challenges.firstWhere(
        (c) => c.gameId == gameId && c.status == 'accepted',
      );
    } catch (_) {
      return null;
    }
  }

  void completeDailyQuest() {
    if (!_profile.dailyQuestCompleted) {
      _profile.dailyQuestCompleted = true;
      final now = DateTime.now();
      _profile.lastDailyQuestDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      addBotakoins(30);
      _saveProfile();
      notifyListeners();
    }
  }

  void _checkDailyQuestReset() {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_profile.lastDailyQuestDate != today) {
      _profile.dailyQuestCompleted = false;
    }
  }

  void addBotakoins(int amount) {
    _profile.botakoins += amount;
    _checkBotakoinAchievements();
    _saveProfile();
    notifyListeners();
  }

  bool spendBotakoins(int amount) {
    if (_profile.botakoins >= amount) {
      _profile.botakoins -= amount;
      _saveProfile();
      notifyListeners();
      return true;
    }
    return false;
  }

  static const _couponAlphabet =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // ambiguity-free
  String _randomCode(int length) {
    final rng = Random();
    final buf = StringBuffer();
    for (var i = 0; i < length; i++) {
      buf.write(_couponAlphabet[rng.nextInt(_couponAlphabet.length)]);
    }
    return buf.toString();
  }

  /// Buy an in-store prize coupon. Decrements botakoins, mints a unique
  /// `BS-BOTA-<cost>-<5char>` redemption code, appends the coupon to the
  /// profile, persists, and returns the new [Coupon]. Returns `null` when
  /// the user lacks sufficient botakoins.
  Coupon? buyPrize(String prizeId, int cost) {
    if (_profile.botakoins < cost) return null;
    _profile.botakoins -= cost;
    final code = 'BS-BOTA-$cost-${_randomCode(5)}';
    final id = 'c-${DateTime.now().millisecondsSinceEpoch}-${_randomCode(5)}';
    final coupon = Coupon(
      id: id,
      prizeId: prizeId,
      code: code,
      purchasedAt: DateTime.now(),
    );
    _profile.purchasedCoupons.add(coupon);
    _profile.couponsRedeemed += 1;
    _saveProfile();
    notifyListeners();
    return coupon;
  }

  void completeGame(String gameId, int score, int correctAnswers) {
    _profile.totalGamesPlayed++;
    _profile.totalCorrectAnswers += correctAnswers;

    final best = _profile.gameBestScores[gameId] ?? 0;
    if (score > best) {
      _profile.gameBestScores[gameId] = score;
    }

    int earned = 2 + (correctAnswers.clamp(0, 8));
    if (score > best && best > 0) {
      earned += 2;
    }
    addBotakoins(earned);

    if (gameId == 'math') _profile.mathProblemsSolved += correctAnswers;
    if (gameId == 'quiz') _profile.quizQuestionsAnswered += correctAnswers;
    if (gameId == 'memory') _profile.memoryPairsFound += correctAnswers;
    if (gameId == 'yurt') _profile.yurtsBuilt += 1;
    _recordSessionDay();

    _checkGameAchievements(gameId);
    _checkLevelUnlocks();
    _saveProfile();
    notifyListeners();
  }

  String _isoToday([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Update streak. Mirrors `playerStore.incrementStreak` from the React app:
  /// - same-day visit: no-op
  /// - yesterday's streak still alive: +1
  /// - otherwise: reset to 1
  void _recordSessionDay() {
    final today = _isoToday();
    final yesterday = _isoToday(DateTime.now().subtract(const Duration(days: 1)));
    if (_profile.lastActiveDate == today) return;
    if (_profile.lastActiveDate == yesterday) {
      _profile.currentStreak += 1;
    } else {
      _profile.currentStreak = 1;
    }
    _profile.lastActiveDate = today;
  }

  /// Minute-resolution screen-time accumulator. Persists daily totals and
  /// trips the screen-time gate when [ChildProfile.screenTimeLimit] is reached.
  void _tickMinute() {
    final today = _isoToday();
    final current = _profile.dailyMinutes[today] ?? 0;
    _profile.dailyMinutes[today] = current + 1;
    _profile.dailyMinutesUsed = _profile.dailyMinutes[today]!;
    if (_profile.dailyMinutesUsed >= _profile.screenTimeLimit) {
      _screenTimeLimitReached = true;
    }
    _saveProfile();
    notifyListeners();
  }

  /// Convenience for Yurt Builder / future games that need to flag a badge
  /// without a full `completeGame` flow.
  void unlockBadge(String id) {
    if (_profile.achievements.contains(id)) return;
    _profile.achievements.add(id);
    _saveProfile();
    notifyListeners();
  }

  void setSoundMuted(bool muted) {
    if (_profile.soundMuted == muted) return;
    _profile.soundMuted = muted;
    _saveProfile();
    notifyListeners();
  }

  void toggleSoundMuted() => setSoundMuted(!_profile.soundMuted);

  void _checkBotakoinAchievements() {
    if (_profile.botakoins >= 50) _addAchievement('collector_50');
    if (_profile.botakoins >= 100) _addAchievement('collector_100');
    if (_profile.botakoins >= 500) _addAchievement('collector_500');
  }

  void _checkGameAchievements(String gameId) {
    if (_profile.totalGamesPlayed >= 1) _addAchievement('first_game');
    if (_profile.totalGamesPlayed >= 5) _addAchievement('games_5');
    if (_profile.totalGamesPlayed >= 10) _addAchievement('games_10');
    if (_profile.totalGamesPlayed >= 25) _addAchievement('games_25');
    if (gameId == 'yurt' && _profile.yurtsBuilt >= 1) {
      _addAchievement('yurt_master');
    }
  }

  void _checkLevelUnlocks() {
    if (_profile.level >= 2) {
      if (!_profile.unlockedLocations.contains('turkestan')) {
        _profile.unlockedLocations.add('turkestan');
        _profile.unlockedLocations.add('steppe');
      }
    }
    if (_profile.level >= 3) {
      if (!_profile.unlockedLocations.contains('charyn')) {
        _profile.unlockedLocations.add('charyn');
      }
    }
  }

  void _addAchievement(String id) {
    if (!_profile.achievements.contains(id)) {
      _profile.achievements.add(id);
    }
  }

  bool verifyParentPin(String pin) {
    return pin == _parentPin;
  }

  void enterParentMode() {
    _parentModeActive = true;
    notifyListeners();
  }

  void exitParentMode() {
    _parentModeActive = false;
    notifyListeners();
  }

  void setScreenTimeLimit(int minutes) {
    _profile.screenTimeLimit = minutes;
    _saveProfile();
    notifyListeners();
  }

  int get sessionMinutes {
    if (_sessionStart == null) return 0;
    return DateTime.now().difference(_sessionStart!).inMinutes;
  }

  void checkScreenTime() {
    if (sessionMinutes >= _profile.screenTimeLimit) {
      _screenTimeLimitReached = true;
      notifyListeners();
    }
  }

  void resetScreenTime() {
    _sessionStart = DateTime.now();
    _screenTimeLimitReached = false;
    _profile.dailyMinutesUsed = 0;
    _saveProfile();
    notifyListeners();
  }

  void resetProgress() {
    _profile = ChildProfile();
    _onboardingComplete = false;
    _saveProfile();
    notifyListeners();
  }

  static const Map<String, Map<String, String>> achievementDefs = {
    'first_step': {
      'nameKz': 'Бірінші қадам',
      'nameRu': 'Первый шаг',
      'icon': '👣',
      'descKz': 'Саяхатты бастадың!',
      'descRu': 'Начал путешествие!',
    },
    'first_game': {
      'nameKz': 'Бірінші ойын',
      'nameRu': 'Первая игра',
      'icon': '🎮',
      'descKz': 'Бірінші ойынды өттің!',
      'descRu': 'Прошёл первую игру!',
    },
    'games_5': {
      'nameKz': '5 ойын',
      'nameRu': '5 игр',
      'icon': '⭐',
      'descKz': '5 ойын ойнадың!',
      'descRu': 'Сыграл 5 игр!',
    },
    'games_10': {
      'nameKz': '10 ойын',
      'nameRu': '10 игр',
      'icon': '🌟',
      'descKz': '10 ойын ойнадың!',
      'descRu': 'Сыграл 10 игр!',
    },
    'games_25': {
      'nameKz': '25 ойын',
      'nameRu': '25 игр',
      'icon': '🏆',
      'descKz': '25 ойын ойнадың!',
      'descRu': 'Сыграл 25 игр!',
    },
    'collector_50': {
      'nameKz': '50 ботакоин',
      'nameRu': '50 ботакоинов',
      'icon': '🪙',
      'descKz': '50 ботакоин жинадың!',
      'descRu': 'Собрал 50 ботакоинов!',
    },
    'collector_100': {
      'nameKz': '100 ботакоин',
      'nameRu': '100 ботакоинов',
      'icon': '💰',
      'descKz': '100 ботакоин жинадың!',
      'descRu': 'Собрал 100 ботакоинов!',
    },
    'collector_500': {
      'nameKz': '500 ботакоин',
      'nameRu': '500 ботакоинов',
      'icon': '👑',
      'descKz': '500 ботакоин жинадың!',
      'descRu': 'Собрал 500 ботакоинов!',
    },
    'yurt_master': {
      'nameKz': 'Юрта шебері',
      'nameRu': 'Мастер юрты',
      'icon': '🏕️',
      'descKz': 'Бірінші юртаны құрастырдың!',
      'descRu': 'Построил первую юрту!',
    },
  };
}
