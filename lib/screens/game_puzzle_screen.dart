import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';
import '../services/supabase_service.dart';

class GamePuzzleScreen extends StatefulWidget {
  final String locationName;
  const GamePuzzleScreen({super.key, required this.locationName});
  @override
  State<GamePuzzleScreen> createState() => _GamePuzzleScreenState();
}

class _GamePuzzleScreenState extends State<GamePuzzleScreen> {
  List<String> _candyImages = [];

  int _difficulty = 0;
  int get _pairCount => [6, 9, 12][_difficulty];
  String get _difficultyName {
    final p = context.read<GameProvider>();
    return [
      p.t('Жеңіл', 'Легкий'),
      p.t('Орташа', 'Средний'),
      p.t('Қиын', 'Сложный'),
    ][_difficulty];
  }

  List<_PuzzleCard> _cards = [];
  int? _first, _second;
  bool _checking = false;
  int _matches = 0, _attempts = 0;
  bool _done = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _loadCandies();
  }

  Future<void> _loadCandies() async {
    final paths = await SupabaseService.getCandyImages();
    if (!mounted) return;
    setState(() {
      _candyImages = paths.map((p) => 'assets/$p').toList();
    });
  }

  void _startGame(int diff) {
    setState(() {
      _difficulty = diff;
      _started = true;
      _initCards();
    });
  }

  void _initCards() {
    final rng = Random();
    final selected = List.generate(_candyImages.length, (i) => i)..shuffle(rng);
    final pairs = selected.take(_pairCount).toList();

    _cards = [];
    for (final idx in pairs) {
      _cards.add(_PuzzleCard(imageIndex: idx));
      _cards.add(_PuzzleCard(imageIndex: idx));
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
            _onComplete();
          }
        } else {
          Future.delayed(const Duration(milliseconds: 900), () {
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
    int stars;
    if (_difficulty == 0) {
      stars = _attempts <= 10 ? 3 : _attempts <= 15 ? 2 : 1;
    } else if (_difficulty == 1) {
      stars = _attempts <= 16 ? 3 : _attempts <= 22 ? 2 : 1;
    } else {
      stars = _attempts <= 22 ? 3 : _attempts <= 30 ? 2 : 1;
    }
    int bonus = (_difficulty + 1) * 5;
    p.completeGame('puzzle', stars * 10 + bonus, _matches);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    if (_candyImages.isEmpty) {
      return Scaffold(body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.bgDark, AppColors.bgDarkMid, AppColors.bgDarkLight], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ));
    }
    if (!_started) return _difficultySelector(p);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgDarkMid, AppColors.bgDarkLight],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: Column(children: [
          _header(p),
          _stats(p),
          Expanded(child: _grid()),
          if (_done) _complete(p),
        ])),
      ),
    );
  }

  Widget _difficultySelector(GameProvider p) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgDarkMid, AppColors.bgDarkLight],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: SingleChildScrollView(child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Image.asset('assets/cumbot/thinking.png', width: 80, height: 80),
            const SizedBox(height: 16),
            Text(
              p.t('Баян Сулу Пазл', 'Пазл Баян Сулу'),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              p.t('Нақты конфеттерді тап!', 'Найди одинаковые конфеты!'),
              style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 6,
                itemBuilder: (_, i) => Container(
                  width: 64, height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(_candyImages[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              p.t('Қиындық деңгейін таңда:', 'Выбери сложность:'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _diffButton(p.t('⭐ Жеңіл (6 жұп)', '⭐ Лёгкий (6 пар)'), 0, AppColors.accentGreen, p),
            const SizedBox(height: 10),
            _diffButton(p.t('⭐⭐ Орташа (9 жұп)', '⭐⭐ Средний (9 пар)'), 1, AppColors.primary, p),
            const SizedBox(height: 10),
            _diffButton(p.t('⭐⭐⭐ Қиын (12 жұп)', '⭐⭐⭐ Сложный (12 пар)'), 2, AppColors.accent, p),
            const SizedBox(height: 40),
          ],
        ))),
      ),
    );
  }

  Widget _diffButton(String text, int diff, Color color, GameProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GameButton(
        text: text, onPressed: () => _startGame(diff),
        color: color, width: double.infinity, height: 52, fontSize: 15,
      ),
    );
  }

  Widget _header(GameProvider p) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.t('🧩 Баян Сулу Пазл', '🧩 Пазл Баян Сулу'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(_difficultyName,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
        ],
      )),
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
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      Text(v, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
      Text(l, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
    ]),
  );

  Widget _grid() {
    int crossCount = _difficulty == 0 ? 3 : 4;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount, mainAxisSpacing: 6, crossAxisSpacing: 6,
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: c.matched ? AppColors.success : Colors.white.withValues(alpha: 0.5),
            width: c.matched ? 3 : 2,
          ),
          boxShadow: [BoxShadow(
            color: (c.matched ? AppColors.success : Colors.black).withValues(alpha: 0.2),
            blurRadius: 8, offset: const Offset(0, 3),
          )],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: show
            ? Stack(children: [
                Image.asset(_candyImages[c.imageIndex], fit: BoxFit.cover,
                  width: double.infinity, height: double.infinity),
                if (c.matched) Container(
                  color: AppColors.success.withValues(alpha: 0.3),
                  child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 32)),
                ),
              ])
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8C00), Color(0xFFFFAD33)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/cumbot/glad.png', width: 30, height: 30),
                    Text('Бота', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.8))),
                  ],
                )),
              ),
        ),
      ),
    );
  }

  Widget _complete(GameProvider p) {
    int stars;
    if (_difficulty == 0) {
      stars = _attempts <= 10 ? 3 : _attempts <= 15 ? 2 : 1;
    } else if (_difficulty == 1) {
      stars = _attempts <= 16 ? 3 : _attempts <= 22 ? 2 : 1;
    } else {
      stars = _attempts <= 22 ? 3 : _attempts <= 30 ? 2 : 1;
    }
    int bonus = (_difficulty + 1) * 5;
    int earned = 5 + (_matches * 2) + bonus + (stars == 3 ? 5 : 0);
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(p.t('Керемет! 🎉', 'Отлично! 🎉'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (j) =>
          Icon(j < stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: j < stars ? AppColors.botakoin : Colors.grey.shade300, size: 36))),
        const SizedBox(height: 8),
        Text('+$earned 🪙', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 12),
        if (_difficulty < 2) ...[
          GameButton(
            text: p.t('Келесі деңгей ➡️', 'Следующий уровень ➡️'),
            onPressed: () => setState(() { _difficulty++; _initCards(); }),
            color: AppColors.accentPurple, height: 44, fontSize: 14, width: double.infinity,
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          Expanded(child: GameButton(text: p.t('Қайта', 'Снова'), onPressed: () => setState(() => _initCards()),
            color: AppColors.secondary, height: 44, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: GameButton(text: p.t('Картаға', 'На карту'), onPressed: () => Navigator.pop(context),
            color: AppColors.primary, height: 44, fontSize: 14)),
        ]),
      ]),
    );
  }
}

class _PuzzleCard {
  final int imageIndex;
  bool flipped;
  bool matched;
  _PuzzleCard({required this.imageIndex}) : flipped = false, matched = false;
}
