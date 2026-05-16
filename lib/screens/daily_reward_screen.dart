import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';

class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({super.key});
  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _opened = false;
  int _reward = 0;

  static const List<Map<String, dynamic>> _dailyRewards = [
    {'day': 1, 'coins': 5, 'emoji': '🎁'},
    {'day': 2, 'coins': 10, 'emoji': '⭐'},
    {'day': 3, 'coins': 15, 'emoji': '🌟'},
    {'day': 4, 'coins': 20, 'emoji': '💫'},
    {'day': 5, 'coins': 25, 'emoji': '🏆'},
    {'day': 6, 'coins': 30, 'emoji': '👑'},
    {'day': 7, 'coins': 50, 'emoji': '🎉'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openChest(GameProvider p) {
    final streak = (p.profile.totalGamesPlayed % 7);
    final dayReward = _dailyRewards[streak];
    _reward = dayReward['coins'] as int;
    p.addBotakoins(_reward);
    _controller.forward();
    setState(() => _opened = true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _header(p),
                const SizedBox(height: 32),
                _chest(p),
                const SizedBox(height: 32),
                _weekStreak(p),
                const SizedBox(height: 32),
                _closeButton(p),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(GameProvider p) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Text(
        p.t('Күнделікті сыйлық! 🎁', 'Ежедневная награда! 🎁'),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      const SizedBox(height: 8),
      Text(
        p.t('Күн сайын кіріп, сыйлық ал!', 'Заходи каждый день за наградой!'),
        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
      ),
    ]),
  );

  Widget _chest(GameProvider p) {
    return GestureDetector(
      onTap: _opened ? null : () => _openChest(p),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _opened ? _scaleAnim.value : 1.0,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _opened
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF8B4513),
                          const Color(0xFFD2691E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (_opened ? AppColors.botakoin : const Color(0xFF8B4513))
                        .withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  _opened ? 'assets/coin/coin.jpeg' : 'assets/cumbot/withcoins_v2.png',
                  width: 72, height: 72, fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_opened) ...[
              Text(
                '+$_reward',
                style: const TextStyle(
                  fontSize: 48, fontWeight: FontWeight.w900,
                  color: AppColors.botakoin,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                ),
              ),
              Text(
                p.t('Ботакоин! 🎉', 'Ботакоинов! 🎉'),
                style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
              ),
            ] else ...[
              Text(
                p.t('Тигіне бас! 👆', 'Нажми на сундук! 👆'),
                style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _weekStreak(GameProvider p) {
    final currentDay = (p.profile.totalGamesPlayed % 7);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            p.t('7 күндік серия', '7 дней подряд'),
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final isDone = i < currentDay;
              final isCurrent = i == currentDay;
              final reward = _dailyRewards[i];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.botakoin
                              : Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isCurrent ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [BoxShadow(color: AppColors.botakoin.withValues(alpha: 0.5), blurRadius: 8)]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        isDone ? '✓' : '${reward['coins']}',
                        style: TextStyle(
                          fontSize: isDone ? 16 : 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.t("Күн", "День")} ${i + 1}',
                    style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _closeButton(GameProvider p) => GameButton(
    text: p.t('Ойнауға! 🎮', 'К играм! 🎮'),
    onPressed: () => Navigator.pop(context),
    color: _opened ? AppColors.primary : AppColors.textSecondary,
    width: 220,
  );
}
