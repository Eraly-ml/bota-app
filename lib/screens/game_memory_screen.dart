import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';
import '../services/supabase_service.dart';

class GameMemoryScreen extends StatefulWidget {
  final String locationName;
  const GameMemoryScreen({super.key, required this.locationName});
  @override
  State<GameMemoryScreen> createState() => _GameMemoryScreenState();
}

class _GameMemoryScreenState extends State<GameMemoryScreen>
    with SingleTickerProviderStateMixin {
  List<String> _candyImages = [];

  int _difficulty = -1;
  int get _pairCount => [6, 9, 12][_difficulty.clamp(0, 2)];

  List<_MemCard> _cards = [];
  int? _first, _second;
  bool _checking = false;
  int _matches = 0, _attempts = 0;
  bool _done = false;

  late AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadCandies();
  }

  Future<void> _loadCandies() async {
    final paths = await SupabaseService.getCandyImages();
    if (!mounted) return;
    setState(() {
      _candyImages = paths.map((p) => 'assets/$p').toList();
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _startGame(int diff) {
    setState(() {
      _difficulty = diff;
      _initCards();
    });
  }

  void _initCards() {
    final rng = Random();
    final indices = List.generate(_candyImages.length, (i) => i)..shuffle(rng);
    final selected = indices.take(_pairCount).toList();

    _cards = [];
    for (final idx in selected) {
      _cards.add(_MemCard(imageIndex: idx));
      _cards.add(_MemCard(imageIndex: idx));
    }
    _cards.shuffle(rng);
    _first = _second = null;
    _checking = false;
    _matches = _attempts = 0;
    _done = false;
  }

  void _onTap(int i) {
    if (_checking || _cards[i].matched || _cards[i].flipped) return;
    setState(() {
      _cards[i].flipped = true;
      if (_first == null) {
        _first = i;
      } else {
        _second = i;
        _attempts++;
        _checking = true;
        if (_cards[_first!].imageIndex == _cards[_second!].imageIndex) {
          _cards[_first!].matched = true;
          _cards[_second!].matched = true;
          _matches++;
          _checking = false;
          _first = _second = null;
          if (_matches == _pairCount) {
            _done = true;
            _bounceCtrl.forward(from: 0);
            _onComplete();
          }
        } else {
          Timer(const Duration(milliseconds: 900), () {
            if (mounted) {
              setState(() {
                _cards[_first!].flipped = false;
                _cards[_second!].flipped = false;
                _first = _second = null;
                _checking = false;
              });
            }
          });
        }
      }
    });
  }

  void _onComplete() {
    final p = context.read<GameProvider>();
    int stars = _getStars();
    int bonus = (_difficulty + 1) * 5;
    p.completeGame('memory', stars * 10 + bonus, _matches);
  }

  int _getStars() {
    if (_difficulty == 0) {
      return _attempts <= 10 ? 3 : _attempts <= 15 ? 2 : 1;
    } else if (_difficulty == 1) {
      return _attempts <= 16 ? 3 : _attempts <= 22 ? 2 : 1;
    } else {
      return _attempts <= 22 ? 3 : _attempts <= 30 ? 2 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_candyImages.isEmpty) {
      return Scaffold(body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ));
    }
    if (_difficulty < 0) return _difficultySelector();

    final p = context.watch<GameProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _header(p),
            _stats(p),
            Expanded(child: _grid()),
            if (_done) _completeWidget(p),
          ]),
        ),
      ),
    );
  }

  Widget _difficultySelector() {
    final p = context.watch<GameProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              const Text('🃏', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 12),
              Text(
                p.t('Жадты жаттықтыр', 'Тренируй память'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                p.t('Нақты Баян Сулу конфеттерін тап!', 'Найди одинаковые конфеты Баян Сулу!'),
                style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _candyImages.length,
                  itemBuilder: (_, i) => Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(_candyImages[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                p.t('Қиындық деңгейін таңда:', 'Выбери сложность:'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _diffCard(
                p,
                emoji: '⭐',
                titleKz: 'Жеңіл',
                titleRu: 'Лёгкий',
                descKz: '6 жұп • 12 карта',
                descRu: '6 пар • 12 карточек',
                color: AppColors.accentGreen,
                diff: 0,
              ),
              const SizedBox(height: 12),
              _diffCard(
                p,
                emoji: '⭐⭐',
                titleKz: 'Орташа',
                titleRu: 'Средний',
                descKz: '9 жұп • 18 карта',
                descRu: '9 пар • 18 карточек',
                color: AppColors.primary,
                diff: 1,
              ),
              const SizedBox(height: 12),
              _diffCard(
                p,
                emoji: '⭐⭐⭐',
                titleKz: 'Қиын',
                titleRu: 'Сложный',
                descKz: '12 жұп • 24 карта',
                descRu: '12 пар • 24 карточки',
                color: AppColors.accent,
                diff: 2,
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _diffCard(
    GameProvider p, {
    required String emoji,
    required String titleKz,
    required String titleRu,
    required String descKz,
    required String descRu,
    required Color color,
    required int diff,
  }) {
    return GestureDetector(
      onTap: () => _startGame(diff),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Row(children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.isRussian ? titleRu : titleKz,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  p.isRussian ? descRu : descKz,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded, color: color, size: 40),
        ]),
      ),
    );
  }

  Widget _header(GameProvider p) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.t('🃏 Жадты жаттықтыр', '🃏 Тренируй память'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              p.t(
                ['Жеңіл', 'Орташа', 'Қиын'][_difficulty],
                ['Лёгкий', 'Средний', 'Сложный'][_difficulty],
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      BotakoinCounter(count: p.profile.botakoins, fontSize: 14),
    ]),
  );

  Widget _stats(GameProvider p) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _stat(p.t('Жұптар', 'Пары'), '$_matches/$_pairCount'),
      _stat(p.t('Әрекеттер', 'Попытки'), '$_attempts'),
    ]),
  );

  Widget _stat(String l, String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(children: [
      Text(v, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
      Text(l, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
    ]),
  );

  Widget _grid() {
    int crossCount;
    double ratio;
    if (_difficulty == 0) {
      crossCount = 3;
      ratio = 0.85;
    } else if (_difficulty == 1) {
      crossCount = 3;
      ratio = 0.75;
    } else {
      crossCount = 4;
      ratio = 0.75;
    }
    return Padding(
      padding: const EdgeInsets.all(6),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: ratio,
        ),
        itemCount: _cards.length,
        itemBuilder: (_, i) => _card(i),
      ),
    );
  }

  Widget _card(int i) {
    final c = _cards[i];
    final show = c.flipped || c.matched;
    return GestureDetector(
      onTap: () => _onTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.matched
                ? AppColors.success
                : (c.flipped ? Colors.white : Colors.white.withValues(alpha: 0.3)),
            width: c.matched ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (c.matched ? AppColors.success : Colors.black).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: show
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _candyImages[c.imageIndex],
                      fit: BoxFit.cover,
                    ),
                    if (c.matched)
                      Container(
                        color: AppColors.success.withValues(alpha: 0.35),
                        child: const Center(
                          child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                        ),
                      ),
                  ],
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF9B59B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/cumbot/glad.png', width: 30, height: 30),
                        Text(
                          'Бота',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _completeWidget(GameProvider p) {
    int stars = _getStars();
    int bonus = (_difficulty + 1) * 5;
    int earned = 5 + (_matches * 2) + bonus + (stars == 3 ? 5 : 0);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          p.t('Керемет! 🎉', 'Отлично! 🎉'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (j) => Icon(
              j < stars ? Icons.star_rounded : Icons.star_border_rounded,
              color: j < stars ? AppColors.botakoin : Colors.grey.shade300,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '+$earned 🪙',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        if (_difficulty < 2) ...[
          GameButton(
            text: p.t('Келесі деңгей ➡️', 'Следующий уровень ➡️'),
            onPressed: () => setState(() {
              _difficulty++;
              _initCards();
            }),
            color: AppColors.accentPurple,
            height: 44,
            fontSize: 14,
            width: double.infinity,
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          Expanded(
            child: GameButton(
              text: p.t('Қайта', 'Снова'),
              onPressed: () => setState(() => _initCards()),
              color: AppColors.secondary,
              height: 44,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GameButton(
              text: p.t('Картаға', 'На карту'),
              onPressed: () => Navigator.pop(context),
              color: AppColors.primary,
              height: 44,
              fontSize: 14,
            ),
          ),
        ]),
      ]),
    );
  }
}

class _MemCard {
  final int imageIndex;
  bool flipped;
  bool matched;
  _MemCard({required this.imageIndex}) : flipped = false, matched = false;
}
