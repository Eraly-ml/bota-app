import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../models/map_location.dart';
import '../widgets/game_widgets.dart';
import '../widgets/avatar_widget.dart';
import 'game_memory_screen.dart';
import 'game_words_screen.dart';
import 'game_math_screen.dart';
import 'game_puzzle_screen.dart';
import 'game_quiz_screen.dart';
import 'game_quest_screen.dart';
import 'game_catch_screen.dart';
import 'game_yurt_screen.dart';
import 'parent_screen.dart';
import 'daily_reward_screen.dart';
import 'ai_chat_screen.dart';
import 'learn_screen.dart';
import 'daily_quest_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  String? _selectedLocationId;
  late ScrollController _scrollCtrl;

  double _fabX = -1;
  double _fabY = -1;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _pulseCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _glowCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  static const _gameInfo = {
    'memory': {'icon': Icons.grid_view_rounded, 'nameKz': 'Жадты жаттықтыр', 'nameRu': 'Тренируй память'},
    'words': {'icon': Icons.abc_rounded, 'nameKz': 'Қазақ сөздері', 'nameRu': 'Казахские слова'},
    'math': {'icon': Icons.calculate_rounded, 'nameKz': 'Бота санайды', 'nameRu': 'Считай с Ботой'},
    'puzzle': {'icon': Icons.extension_rounded, 'nameKz': 'Баян Сулу Пазл', 'nameRu': 'Пазл Баян Сулу'},
    'quiz': {'icon': Icons.quiz_rounded, 'nameKz': 'Викторина', 'nameRu': 'Викторина'},
    'quest': {'icon': Icons.auto_stories_rounded, 'nameKz': 'Мини-квест', 'nameRu': 'Мини-квест'},
    'catch': {'icon': Icons.catching_pokemon_rounded, 'nameKz': 'Кәмпитті ұста', 'nameRu': 'Поймай конфету'},
    'yurt': {'icon': Icons.cottage_rounded, 'nameKz': 'Юрта құрастыру', 'nameRu': 'Сборка юрты'},
  };

  void _openGame(String gameId, String locationName) {
    Widget screen;
    switch (gameId) {
      case 'memory': screen = GameMemoryScreen(locationName: locationName); break;
      case 'words': screen = GameWordsScreen(locationName: locationName); break;
      case 'math': screen = GameMathScreen(locationName: locationName); break;
      case 'puzzle': screen = GamePuzzleScreen(locationName: locationName); break;
      case 'quiz': screen = GameQuizScreen(locationName: locationName); break;
      case 'quest': screen = GameQuestScreen(locationName: locationName); break;
      case 'catch': screen = GameCatchScreen(locationName: locationName); break;
      case 'yurt': screen = GameYurtScreen(locationName: locationName); break;
      default: screen = GameMemoryScreen(locationName: locationName);
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _openLearnThenQuiz(String locationName) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LearnScreen(locationName: locationName),
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _openAiChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AiChatScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    final locations = MapLocation.allLocations;

    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    if (_fabX < 0) {
      _fabX = screenW - 72;
      _fabY = screenH - MediaQuery.of(context).padding.bottom - 170;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [

            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 80,
                  bottom: 110,
                ),
                child: _buildPath(locations, p),
              ),
            ),

            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(child: _topBar(p)),
            ),

            if (_selectedLocationId != null) _locationPanel(p),

            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(child: _bottomNav(p)),
            ),

            Positioned(
              left: _fabX,
              top: _fabY,
              child: _buildDraggableAiFab(screenW, screenH),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableAiFab(double screenW, double screenH) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _fabX = (_fabX + details.delta.dx).clamp(0.0, screenW - 64);
          _fabY = (_fabY + details.delta.dy).clamp(0.0, screenH - 64);
        });
      },
      onTap: _openAiChat,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: _pulseAnim.value,
          child: child,
        ),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/cumbot/face.png', width: 40, height: 40, fit: BoxFit.cover),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPath(List<MapLocation> locations, GameProvider p) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.white.withValues(alpha: 0.15)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                p.t('Қазақстан жолы', 'Путь по Казахстану'),
                style: TextStyle(
                  color: AppColors.textOnDarkSecondary.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ),
            ],
          ),
        ),

        ...List.generate(locations.length, (index) {
          final loc = locations[index];
          final isUnlocked = p.profile.unlockedLocations.contains(loc.id);
          final isSelected = _selectedLocationId == loc.id;
          final isCompleted = isUnlocked && (p.profile.gameBestScores[loc.gameIds.first] ?? 0) > 0;
          final isCurrent = isUnlocked && !isCompleted;

          final offsetX = (index % 3 == 0) ? 0.0 : (index % 3 == 1) ? 60.0 : -60.0;

          return Column(
            children: [

              if (index > 0) _buildConnector(
                offsetFrom: (((index - 1) % 3 == 0) ? 0.0 : ((index - 1) % 3 == 1) ? 60.0 : -60.0),
                offsetTo: offsetX,
                isUnlocked: isUnlocked,
                prevColor: locations[index - 1].color,
              ),

              Transform.translate(
                offset: Offset(offsetX, 0),
                child: _buildNode(loc, p, isUnlocked, isSelected, isCompleted, isCurrent),
              ),
            ],
          );
        }),

        const SizedBox(height: 30),
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '...',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.2),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnector({
    required double offsetFrom,
    required double offsetTo,
    required bool isUnlocked,
    required Color prevColor,
  }) {
    return SizedBox(
      height: 50,
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, 50),
        painter: _PathPainter(
          fromX: MediaQuery.of(context).size.width / 2 + offsetFrom,
          toX: MediaQuery.of(context).size.width / 2 + offsetTo,
          color: isUnlocked ? prevColor.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.08),
          isUnlocked: isUnlocked,
        ),
      ),
    );
  }

  Widget _buildNode(MapLocation loc, GameProvider p, bool isUnlocked, bool isSelected, bool isCompleted, bool isCurrent) {
    final nodeSize = isSelected ? 72.0 : 64.0;
    Color bgColor;

    if (isCompleted) {
      bgColor = const Color(0xFF58CC02);
    } else if (isCurrent) {
      bgColor = loc.color;
    } else {
      bgColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          setState(() {
            _selectedLocationId = _selectedLocationId == loc.id ? null : loc.id;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('${p.isRussian ? loc.nameRu : loc.nameKz} - Lv.${loc.requiredLevel}'),
              ],
            ),
            backgroundColor: const Color(0xFF3a3f54),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ));
        }
      },
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: isCurrent ? _pulseAnim.value : 1.0,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            if (isSelected)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  p.isRussian ? loc.nameRu : loc.nameKz,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

            Stack(
              alignment: Alignment.center,
              children: [

                if (isCurrent)
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (_, a0) => Container(
                      width: nodeSize + 20,
                      height: nodeSize + 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: loc.color.withValues(alpha: _glowAnim.value * 0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                ClipPath(
                  clipper: _HexagonClipper(),
                  child: Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          bgColor,
                          bgColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: isUnlocked
                          ? Icon(
                              isCompleted ? Icons.check_rounded : loc.iconData,
                              color: Colors.white,
                              size: isCompleted ? 30 : 28,
                            )
                          : const Icon(Icons.lock_rounded, color: Colors.white54, size: 24),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -4,
                  child: ClipPath(
                    clipper: _HexagonClipper(),
                    child: Container(
                      width: nodeSize,
                      height: 8,
                      color: isCompleted
                          ? const Color(0xFF3d8c00)
                          : (isCurrent ? loc.color.withValues(alpha: 0.4) : const Color(0xFFBDBDBD)),
                    ),
                  ),
                ),
              ],
            ),

            if (!isSelected)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p.isRussian ? loc.nameRu : loc.nameKz,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : Colors.grey.shade400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _locationPanel(GameProvider p) {
    final loc = MapLocation.allLocations.firstWhere((l) => l.id == _selectedLocationId);
    return Positioned(
      bottom: 175,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: loc.color.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: loc.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(loc.iconData, color: loc.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.isRussian ? loc.nameRu : loc.nameKz,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.isRussian ? loc.descriptionRu : loc.descriptionKz,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textOnDarkSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedLocationId = null),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: loc.gameIds.map((gid) {
                  final gi = _gameInfo[gid]!;
                  final isQuiz = gid == 'quiz';
                  return GestureDetector(
                    onTap: () {
                      if (isQuiz) {
                        _openLearnThenQuiz(p.isRussian ? loc.nameRu : loc.nameKz);
                      } else {
                        _openGame(gid, p.isRussian ? loc.nameRu : loc.nameKz);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [loc.color, loc.color.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: loc.color.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(gi['icon'] as IconData, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                p.isRussian ? gi['nameRu'] as String : gi['nameKz'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              if (isQuiz)
                                Text(
                                  p.t('(материалмен)', '(с материалом)'),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(GameProvider p) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.glassBorder),
      boxShadow: AppColors.cardShadow,
    ),
    child: Row(
      children: [
        CartoonAvatar(avatarIndex: p.profile.avatarIndex, size: 40, showBorder: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.profile.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textOnDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Lv.${p.profile.level}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: p.profile.progressToNextLevel,
                        backgroundColor: const Color(0xFF2A1010),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (p.profile.currentStreak > 0) ...[
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 2),
              Text(
                '${p.profile.currentStreak}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRewardScreen())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.botakoin.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.botakoin.withValues(alpha: 0.2)),
            ),
            child: Image.asset('assets/cumbot/face.png', width: 24, height: 24, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.botakoin.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset('assets/coin/coin.jpeg', width: 16, height: 16, fit: BoxFit.cover),
              ),
              const SizedBox(width: 4),
              Text(
                '${p.profile.botakoins}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        GestureDetector(
          onTap: () => p.toggleLanguage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  p.isRussian ? 'QAZ' : 'RUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _bottomNav(GameProvider p) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.glassBorder),
      boxShadow: AppColors.cardShadow,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(Icons.map_rounded, p.t('Карта', 'Карта'), true,
            () => setState(() => _selectedLocationId = null)),
        _navItem(Icons.assignment_rounded, p.t('Квесттер', 'Квесты'), false,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyQuestScreen()))),
        _navItem(Icons.people_rounded, p.t('Достар', 'Друзья'), false,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()))),
        _navItem(Icons.person_rounded, p.t('Профиль', 'Профиль'), false,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
        _navItem(Icons.family_restroom_rounded, p.t('Ата-ана', 'Родитель'), false,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentScreen()))),
      ],
    ),
  );

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textOnDarkSecondary, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textOnDarkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievements(GameProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              provider.t('Жетістіктер', 'Достижения'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ProgressIndicatorBar(
                progress: provider.profile.progressToNextLevel,
                color: AppColors.primary,
                height: 12,
                label: provider.t(
                  'Дeңгей ${provider.profile.level}: ${provider.profile.levelTitle}',
                  'Уровень ${provider.profile.level}: ${provider.profile.levelTitle}',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: GameProvider.achievementDefs.entries.map((entry) {
                  final isUnlocked = provider.profile.achievements.contains(entry.key);
                  final ach = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppColors.botakoin.withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isUnlocked
                            ? AppColors.botakoin.withValues(alpha: 0.3)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? AppColors.botakoin.withValues(alpha: 0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isUnlocked ? Icons.star_rounded : Icons.lock_rounded,
                            color: isUnlocked ? AppColors.botakoin : Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.isRussian ? ach['nameRu']! : ach['nameKz']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: isUnlocked
                                      ? AppColors.textPrimary
                                      : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.isRussian ? ach['descRu']! : ach['descKz']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isUnlocked
                                      ? AppColors.textSecondary
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUnlocked)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF58CC02), size: 28),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = w / 2;

    path.moveTo(r, 0);
    for (int i = 1; i <= 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      path.lineTo(
        r + r * math.cos(angle),
        h / 2 + r * math.sin(angle),
      );
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PathPainter extends CustomPainter {
  final double fromX;
  final double toX;
  final Color color;
  final bool isUnlocked;

  _PathPainter({
    required this.fromX,
    required this.toX,
    required this.color,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = isUnlocked ? 6 : 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(fromX, 0);
    path.cubicTo(
      fromX, size.height * 0.4,
      toX, size.height * 0.6,
      toX, size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) =>
      fromX != oldDelegate.fromX ||
      toX != oldDelegate.toX ||
      color != oldDelegate.color;
}
