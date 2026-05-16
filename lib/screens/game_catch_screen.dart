import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';
import '../services/supabase_service.dart';

class GameCatchScreen extends StatefulWidget {
  final String locationName;
  const GameCatchScreen({super.key, required this.locationName});
  @override
  State<GameCatchScreen> createState() => _GameCatchScreenState();
}

class _GameCatchScreenState extends State<GameCatchScreen> {
  final rng = Random();

  List<String> _candyImages = [];
  List<String> _badImages = [];

  List<_FallingItem> _items = [];
  Timer? _spawnTimer;
  Timer? _moveTimer;
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  bool _done = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final candies = await SupabaseService.getCandyImages();
    final obstacles = await SupabaseService.getObstacleImages();
    if (!mounted) return;
    setState(() {
      _candyImages = candies.map((p) => 'assets/$p').toList();
      _badImages = obstacles.map((p) => 'assets/$p').toList();
    });
  }

  void _startGame() {
    setState(() {
      _started = true;
      _score = 0;
      _timeLeft = 30;
      _done = false;
      _items = [];
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
          t.cancel();
        }
      });
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted || _done) { t.cancel(); return; }
      _spawnItem();
    });

    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted || _done) { t.cancel(); return; }
      setState(() {
        for (final item in _items) {
          item.y += item.speed;
        }
        final screenH = MediaQuery.of(context).size.height;
        _items.removeWhere((it) => it.y > screenH || it.caught);
      });
    });
  }

  void _spawnItem() {
    final screenW = MediaQuery.of(context).size.width;
    final isCandy = rng.nextDouble() > 0.2;
    final image = isCandy
        ? _candyImages[rng.nextInt(_candyImages.length)]
        : _badImages[rng.nextInt(_badImages.length)];
    setState(() {
      _items.add(_FallingItem(
        x: rng.nextDouble() * (screenW - 60) + 10,
        y: -50,
        image: image,
        speed: 6.0 + rng.nextDouble() * 5.0,
        isCandy: isCandy,
      ));
    });
  }

  void _catchItem(int index) {
    final item = _items[index];
    if (item.caught) return;
    setState(() {
      item.caught = true;
      if (item.isCandy) {
        _score++;
      } else {
        _score = (_score - 2).clamp(0, 9999);
      }
    });
  }

  void _endGame() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();
    _gameTimer?.cancel();
    setState(() => _done = true);
    final p = context.read<GameProvider>();
    int stars = _score >= 20 ? 3 : _score >= 12 ? 2 : 1;
    p.completeGame('catch', stars * 10, _score);
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    if (_candyImages.isEmpty) {
      return Scaffold(body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ));
    }
    if (!_started) return _startScreen(p);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: Stack(children: [
          ..._items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            if (item.caught) return const SizedBox.shrink();
            return Positioned(
              left: item.x, top: item.y,
              child: GestureDetector(
                onTap: () => _catchItem(i),
                child: AnimatedOpacity(
                  opacity: item.caught ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (item.isCandy ? AppColors.primary : Colors.red).withValues(alpha: 0.4),
                          blurRadius: 8, offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(item.image, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            );
          }),
          Column(children: [
            _hud(p),
            const Spacer(),
            if (_done) _complete(p),
          ]),
        ])),
      ),
    );
  }

  Widget _startScreen(GameProvider p) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: SafeArea(child: SingleChildScrollView(child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white))),
        ])),
        const SizedBox(height: 32),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 6,
            itemBuilder: (_, i) => Container(
              width: 56, height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(_candyImages[i], fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Image.asset('assets/cumbot/glad.png', width: 100, height: 100),
        const SizedBox(height: 16),
        Text(p.t('Кәмпитті ұста!', 'Поймай конфету!'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(p.t(
            'Конфеттерді бас!\nЖаман заттардан қашыңыз!',
            'Нажимай на конфеты!\nИзбегай плохих предметов!'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.8), height: 1.5))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _badItemPreview('assets/catchgame/pepper.png', p.t('Бұрыш', 'Перец')),
          const SizedBox(width: 12),
          _badItemPreview('assets/catchgame/stone.png', p.t('Тас', 'Камень')),
          const SizedBox(width: 12),
          _badItemPreview('assets/catchgame/bomb.png', p.t('Бомба', 'Бомба')),
        ]),
        const SizedBox(height: 16),
        Text(p.t('30 секунд', '30 секунд'),
          style: const TextStyle(fontSize: 16, color: AppColors.botakoin, fontWeight: FontWeight.w700)),
        const SizedBox(height: 32),
        GameButton(text: p.t('Бастау!', 'Начать!'), onPressed: _startGame,
          color: AppColors.primary, width: 220, icon: Icons.play_arrow_rounded),
        const SizedBox(height: 40),
      ]))),
    ),
  );

  Widget _badItemPreview(String image, String label) => Column(
    children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, fit: BoxFit.cover),
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
    ],
  );

  Widget _hud(GameProvider p) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      GestureDetector(onTap: () { _endGame(); Navigator.pop(context); },
        child: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.close_rounded, color: Colors.white))),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset('assets/candies/candy0.jpeg', width: 20, height: 20, fit: BoxFit.cover),
          ),
          const SizedBox(width: 6),
          Text('$_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _timeLeft <= 5 ? AppColors.error.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.timer_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text('$_timeLeft', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
      ),
    ]),
  );

  Widget _complete(GameProvider p) {
    int stars = _score >= 20 ? 3 : _score >= 12 ? 2 : 1;
    int earned = 2 + (_score.clamp(0, 8)) + (stars == 3 ? 2 : 0);
    return Container(
      margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/cumbot/glad.png', width: 60, height: 60),
        const SizedBox(height: 8),
        Text(p.t('Уақыт бітті!', 'Время вышло!'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (j) =>
          Icon(j < stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: j < stars ? AppColors.botakoin : Colors.grey.shade300, size: 36))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset('assets/candies/candy0.jpeg', width: 24, height: 24, fit: BoxFit.cover),
          ),
          const SizedBox(width: 6),
          Text('$_score ${p.t("кәмпит", "конфет")}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 4),
        Text('+$earned', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: GameButton(text: p.t('Қайта', 'Снова'),
            onPressed: () { setState(() { _started = false; _done = false; _items = []; }); },
            color: AppColors.secondary, height: 44, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: GameButton(text: p.t('Картаға', 'На карту'), onPressed: () => Navigator.pop(context),
            color: AppColors.primary, height: 44, fontSize: 14)),
        ]),
      ]),
    );
  }
}

class _FallingItem {
  double x, y, speed;
  String image;
  bool isCandy;
  bool caught;
  _FallingItem({required this.x, required this.y, required this.image,
    required this.speed, required this.isCandy}) : caught = false;
}
