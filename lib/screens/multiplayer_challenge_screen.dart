import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/friend.dart';
import '../models/challenge.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_widget.dart';
import 'game_quiz_screen.dart';
import 'game_math_screen.dart';
import 'game_memory_screen.dart';

/// Hot-seat multiplayer challenge screen.
///
/// Player 1 (local user) plays first, then passes the device to
/// Player 2 (friend). Scores are compared and the challenge is
/// resolved automatically. Works fully offline.
class MultiplayerChallengeScreen extends StatefulWidget {
  final String friendId;
  final String gameId;

  const MultiplayerChallengeScreen({
    super.key,
    required this.friendId,
    required this.gameId,
  });

  @override
  State<MultiplayerChallengeScreen> createState() =>
      _MultiplayerChallengeScreenState();
}

class _MultiplayerChallengeScreenState
    extends State<MultiplayerChallengeScreen> {
  int? _p1Score;
  int? _p1Correct;
  int? _p2Score;
  int? _p2Correct;
  int _phase = 0; // 0 = intro, 1 = p1 done, 2 = p2 done

  String _gameName(GameProvider p) {
    final names = {
      'quiz': p.t('Викторина', 'Викторина'),
      'math': p.t('Математика', 'Математика'),
      'memory': p.t('Жады', 'Память'),
    };
    return names[widget.gameId] ?? widget.gameId;
  }

  void _launchGame(int player) async {
    final bestBefore =
        context.read<GameProvider>().profile.gameBestScores[widget.gameId] ?? 0;

    Widget screen;
    switch (widget.gameId) {
      case 'quiz':
        screen = const GameQuizScreen(locationName: 'kz');
        break;
      case 'math':
        screen = const GameMathScreen(locationName: 'kz');
        break;
      case 'memory':
        screen = const GameMemoryScreen(locationName: 'kz');
        break;
      default:
        screen = const GameQuizScreen(locationName: 'kz');
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;
    final bestAfter =
        context.read<GameProvider>().profile.gameBestScores[widget.gameId] ?? 0;
    final p = context.read<GameProvider>();

    int score = bestAfter > bestBefore ? bestAfter : bestBefore;
    int correct = 0;
    if (widget.gameId == 'quiz') {
      correct = (score ~/ 10).clamp(1, 8);
    } else if (widget.gameId == 'math') {
      correct = (score ~/ 10).clamp(1, 10);
    } else {
      correct = score ~/ 5;
    }

    setState(() {
      if (player == 1) {
        _p1Score = score;
        _p1Correct = correct;
        _phase = 1;
      } else {
        _p2Score = score;
        _p2Correct = correct;
        _phase = 2;
        _resolveChallenge(p);
      }
    });
  }

  void _resolveChallenge(GameProvider p) {
    if (_p1Score == null || _p2Score == null) return;
    final friend = p.profile.friends.firstWhere(
      (f) => f.id == widget.friendId,
      orElse: () => Friend(id: '', name: 'Friend', addedAt: DateTime.now()),
    );

    p.createChallenge(
      widget.gameId,
      _p1Score!,
      _p1Correct ?? 0,
      toPlayerId: friend.id.isNotEmpty ? friend.id : null,
    );

    final challenge = p.getActiveChallenges().lastWhere(
      (c) => c.gameId == widget.gameId && c.toPlayerId == friend.id,
      orElse: () => Challenge(
        id: '',
        gameId: '',
        fromPlayerId: '',
        fromPlayerName: '',
        fromScore: 0,
        fromCorrect: 0,
        createdAt: DateTime.now(),
      ),
    );

    if (challenge.id.isNotEmpty) {
      p.resolveChallenge(challenge.id, _p2Score!, _p2Correct ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    final friend = p.profile.friends.firstWhere(
      (f) => f.id == widget.friendId,
      orElse: () => Friend(id: '', name: 'Friend', addedAt: DateTime.now()),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgDarkMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(p),
                const SizedBox(height: 24),
                Expanded(child: _buildBody(p, friend)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameProvider p) => Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Icon(Icons.arrow_back_rounded,
              size: 22, color: Colors.white),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
          p.t('Дуэль', 'Дуэль'),
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    ],
  );

  Widget _buildBody(GameProvider p, Friend friend) {
    if (_phase == 2) {
      return _buildResult(p, friend);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.sports_esports_rounded,
                  color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                _gameName(p),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                p.t('Қолдан келгенше көп ұпай жина!',
                    'Набери как можно больше очков!'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _playerCard(
          p,
          name: p.profile.name.isNotEmpty ? p.profile.name : 'Player 1',
          avatarIndex: p.profile.avatarIndex,
          isActive: _phase == 0,
          score: _p1Score,
          label: p.t('Ойыншы 1', 'Игрок 1'),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: Text(
            'VS',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: 12),
        _playerCard(
          p,
          name: friend.name.isNotEmpty ? friend.name : 'Player 2',
          avatarIndex: friend.avatarIndex,
          isActive: _phase == 1,
          score: _p2Score,
          label: p.t('Ойыншы 2', 'Игрок 2'),
        ),
        const Spacer(),
        if (_phase == 0)
          _actionButton(
            p.t('Ойыншы 1 ойнайды', 'Играет Игрок 1'),
            () => _launchGame(1),
          )
        else if (_phase == 1)
          _actionButton(
            p.t('Ойыншы 2 ойнайды', 'Играет Игрок 2'),
            () => _launchGame(2),
          ),
      ],
    );
  }

  Widget _playerCard(GameProvider p,
      {required String name,
      required int avatarIndex,
      required bool isActive,
      required String label,
      int? score}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CartoonAvatar(avatarIndex: avatarIndex, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.4)),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          if (score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$score',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    ),
  );

  Widget _buildResult(GameProvider p, Friend friend) {
    final p1Won = (_p1Score ?? 0) > (_p2Score ?? 0);
    final draw = (_p1Score ?? 0) == (_p2Score ?? 0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: draw
                ? Colors.white.withValues(alpha: 0.06)
                : p1Won
                    ? const Color(0xFF58CC02).withValues(alpha: 0.12)
                    : AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: draw
                  ? Colors.white.withValues(alpha: 0.1)
                  : p1Won
                      ? const Color(0xFF58CC02).withValues(alpha: 0.3)
                      : AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                draw
                    ? Icons.handshake_rounded
                    : p1Won
                        ? Icons.emoji_events_rounded
                        : Icons.sentiment_dissatisfied_rounded,
                color: draw
                    ? Colors.white.withValues(alpha: 0.5)
                    : p1Won
                        ? const Color(0xFF58CC02)
                        : AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                draw
                    ? p.t('Тең!', 'Ничья!')
                    : p1Won
                        ? p.t('Жеңіс!', 'Победа!')
                        : p.t('Жеңіліс...', 'Поражение...'),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: draw
                      ? Colors.white
                      : p1Won
                          ? const Color(0xFF58CC02)
                          : AppColors.error,
                ),
              ),
              if (p1Won) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset('assets/coin/coin.jpeg',
                          width: 18, height: 18, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '+10',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF58CC02)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _playerCard(
          p,
          name: p.profile.name.isNotEmpty ? p.profile.name : 'Player 1',
          avatarIndex: p.profile.avatarIndex,
          isActive: false,
          score: _p1Score,
          label: p.t('Ойыншы 1', 'Игрок 1'),
        ),
        const SizedBox(height: 12),
        _playerCard(
          p,
          name: friend.name.isNotEmpty ? friend.name : 'Player 2',
          avatarIndex: friend.avatarIndex,
          isActive: false,
          score: _p2Score,
          label: p.t('Ойыншы 2', 'Игрок 2'),
        ),
        const Spacer(),
        _actionButton(
          p.t('Жабу', 'Закрыть'),
          () => Navigator.pop(context),
        ),
      ],
    );
  }
}
