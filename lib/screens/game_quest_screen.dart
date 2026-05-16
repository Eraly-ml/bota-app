import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';
import '../services/supabase_service.dart';

class GameQuestScreen extends StatefulWidget {
  final String locationName;
  const GameQuestScreen({super.key, required this.locationName});
  @override
  State<GameQuestScreen> createState() => _GameQuestScreenState();
}

class _GameQuestScreenState extends State<GameQuestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  int _scene = 0;
  int _correctChoices = 0;
  bool _done = false;

  List<Map<String, dynamic>> _scenes = [];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: this,
    )..forward();
    _loadScenes();
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  Future<void> _loadScenes() async {
    final data = await SupabaseService.getQuestScenes();
    if (!mounted) return;
    if (data.isNotEmpty) {
      setState(() {
        _scenes = data.map((s) {
          final bgColors = s['bg_colors'] as List;
          final choices = s['choices'] as List;
          return <String, dynamic>{
            'bgColors': bgColors.map((c) => _parseColor(c.toString())).toList(),
            'titleKz': s['title_kz'],
            'titleRu': s['title_ru'],
            'textKz': s['text_kz'],
            'textRu': s['text_ru'],
            'choices': choices.map((c) => Map<String, dynamic>.from(c as Map)).toList(),
          };
        }).toList();
      });
    } else {
      setState(() {
        _scenes = _defaultScenes();
      });
    }
  }

  List<Map<String, dynamic>> _defaultScenes() => [
    {
      'bgColors': [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
      'titleKz': 'Шарын шатқалы', 'titleRu': 'Чарынский каньон',
      'textKz': 'КамБот Шарын шатқалына келді.', 'textRu': 'КамБот пришёл к Чарынскому каньону.',
      'choices': [
        {'textKz': 'Жасыл орман жолы', 'textRu': 'Через зелёный лес', 'correct': true, 'replyKz': 'Жарайсың!', 'replyRu': 'Молодец!'},
        {'textKz': 'Құм жолы', 'textRu': 'Через пустыню', 'correct': false, 'replyKz': 'Құмда ыстық!', 'replyRu': 'В пустыне жарко!'},
      ],
    },
  ];

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _choose(Map<String, dynamic> choice) {
    if (choice['correct'] == true) _correctChoices++;
    final p = context.read<GameProvider>();
    final reply = p.isRussian ? choice['replyRu'] : choice['replyKz'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const KambotAvatar(size: 80),
          const SizedBox(height: 12),
          Text(reply as String, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4)),
        ]),
        actions: [
          Center(child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (_scene < _scenes.length - 1) {
                  _scene++;
                  _fadeCtrl.reset();
                  _fadeCtrl.forward();
                } else {
                  _done = true;
                  _onComplete();
                }
              });
            },
            child: Text(
              _scene < _scenes.length - 1
                  ? p.t('Алға! ➡️', 'Дальше! ➡️')
                  : p.t('Аяқтау 🏆', 'Завершить 🏆'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          )),
        ],
      ),
    );
  }

  void _onComplete() {
    final p = context.read<GameProvider>();
    int stars = _correctChoices >= 4 ? 3 : _correctChoices >= 2 ? 2 : 1;
    p.completeGame('quest', stars * 10, _correctChoices);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    if (_scenes.isEmpty) {
      return Scaffold(body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1a1a2e), Color(0xFF16213e)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ));
    }
    if (_done) return _completeScreen(p);

    final scene = _scenes[_scene];
    final bgColors = scene['bgColors'] as List<Color>;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: bgColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(child: FadeTransition(
          opacity: _fadeCtrl,
          child: SingleChildScrollView(child: Column(children: [
            _header(p),
            _progressDots(),
            const SizedBox(height: 16),
            Image.asset('assets/cumbot/thinking.png', width: 72, height: 72),
            const SizedBox(height: 12),
            Text(p.isRussian ? scene['titleRu'] as String : scene['titleKz'] as String,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                p.isRussian ? scene['textRu'] as String : scene['textKz'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            ...((scene['choices'] as List<Map<String, dynamic>>).map((choice) =>
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                child: GameButton(
                  text: (p.isRussian ? choice['textRu'] : choice['textKz']) as String,
                  onPressed: () => _choose(choice),
                  color: Colors.white.withValues(alpha: 0.25),
                  width: double.infinity, height: 52, fontSize: 15,
                ),
              ),
            )),
            const SizedBox(height: 40),
          ])),
        )),
      ),
    );
  }

  Widget _header(GameProvider p) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      GestureDetector(onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white))),
      const SizedBox(width: 12),
      Expanded(child: Text(p.t('📖 Шарын квесті', '📖 Квест Чарына'),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white))),
      BotakoinCounter(count: p.profile.botakoins, fontSize: 14),
    ]),
  );

  Widget _progressDots() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_scenes.length, (i) => Container(
        width: i == _scene ? 32 : 12, height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: i <= _scene ? Colors.white : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6)),
      )),
    ),
  );

  Widget _completeScreen(GameProvider p) {
    int stars = _correctChoices >= 4 ? 3 : _correctChoices >= 2 ? 2 : 1;
    int earned = 10 + (_correctChoices * 3) + (stars == 3 ? 10 : 0);
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0xFFFF8C00), Color(0xFFFFAD33)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: SafeArea(child: Center(child: Container(
        margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const KambotAvatar(size: 100),
          const SizedBox(height: 16),
          Text(p.t('Квест аяқталды! 🏆', 'Квест пройден! 🏆'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (j) =>
            Icon(j < stars ? Icons.star_rounded : Icons.star_border_rounded,
              color: j < stars ? AppColors.botakoin : Colors.grey.shade300, size: 40))),
          const SizedBox(height: 12),
          Text('+$earned 🪙', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 20),
          GameButton(text: p.t('Картаға', 'На карту'), onPressed: () => Navigator.pop(context),
            color: AppColors.primary, height: 48, width: 200),
        ]),
      ))),
    ));
  }
}
