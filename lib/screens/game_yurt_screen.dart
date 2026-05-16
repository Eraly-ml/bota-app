import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';

/// Yurt Builder — cultural sequential-assembly game.
///
/// The child drags 5 pieces of a traditional Kazakh yurt onto the build area
/// in a fixed order: base → walls → crown (shanyrak) → felt → door. Only the
/// `nextRequired` piece accepts drops; out-of-order pieces are rejected and
/// the build area shakes. After the structure is complete, 6 decorations
/// become tap-to-place + free-drag inside the yurt area.
///
/// Reward flow on completion (after a 900ms celebratory delay):
/// `addBotakoins(50)` + `completeGame('yurt', 100, 5)` + `unlockBadge('yurt_master')`.
class GameYurtScreen extends StatefulWidget {
  final String locationName;
  const GameYurtScreen({super.key, required this.locationName});

  @override
  State<GameYurtScreen> createState() => _GameYurtScreenState();
}

class _GameYurtScreenState extends State<GameYurtScreen>
    with TickerProviderStateMixin {
  static const List<String> _requiredOrder = [
    'base',
    'walls',
    'crown',
    'felt',
    'door',
  ];

  static const Map<String, Map<String, String>> _pieces = {
    'base': {'emoji': '🟫', 'kz': 'Іргетас', 'ru': 'Основание'},
    'walls': {'emoji': '🧱', 'kz': 'Керегелер', 'ru': 'Стены (кереге)'},
    'crown': {'emoji': '☀️', 'kz': 'Шаңырақ', 'ru': 'Шанырак'},
    'felt': {'emoji': '🟪', 'kz': 'Киіз', 'ru': 'Войлок'},
    'door': {'emoji': '🚪', 'kz': 'Есік', 'ru': 'Дверь'},
  };

  static const Map<String, Map<String, String>> _decorationDefs = {
    'carpet': {'emoji': '🎨', 'kz': 'Кілем', 'ru': 'Ковёр'},
    'dombra': {'emoji': '🎵', 'kz': 'Домбыра', 'ru': 'Домбра'},
    'lantern': {'emoji': '🏮', 'kz': 'Шам', 'ru': 'Фонарь'},
    'chest': {'emoji': '🧰', 'kz': 'Сандық', 'ru': 'Сундук'},
    'cauldron': {'emoji': '🫕', 'kz': 'Қазан', 'ru': 'Казан'},
    'flowers': {'emoji': '🌸', 'kz': 'Гүлдер', 'ru': 'Цветы'},
  };

  static const Map<String, Map<String, String>> _kambotMsgs = {
    'start': {
      'kz': 'Іргетастан бастайық, балапаным!',
      'ru': 'Начнём с основания, малыш!',
    },
    'base': {
      'kz': 'Енді керегелерді орнатамыз!',
      'ru': 'Теперь установим стены (кереге)!',
    },
    'walls': {
      'kz': 'Шаңырақ — юртаның жүрегі!',
      'ru': 'Шанырак — сердце юрты!',
    },
    'crown': {
      'kz': 'Жылулыққа киіз қажет!',
      'ru': 'Для тепла — войлок!',
    },
    'felt': {
      'kz': 'Соңында — есік. Қош келдіңіз!',
      'ru': 'И в конце — дверь. Добро пожаловать!',
    },
    'done': {
      'kz': 'Тамаша! Юртаң дайын — әшекейлейік!',
      'ru': 'Отлично! Юрта готова — украшаем!',
    },
  };

  final Set<String> _placed = {};
  final Map<String, Offset> _decorationPositions = {};
  bool _complete = false;
  bool _rewardShown = false;
  bool _shake = false;

  late AnimationController _celebrationCtrl;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _celebrationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _celebrationCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  String? get _nextRequired {
    for (final id in _requiredOrder) {
      if (!_placed.contains(id)) return id;
    }
    return null;
  }

  String _currentMessage(GameProvider p) {
    if (_complete) {
      return p.t(_kambotMsgs['done']!['kz']!, _kambotMsgs['done']!['ru']!);
    }
    if (_placed.isEmpty) {
      return p.t(_kambotMsgs['start']!['kz']!, _kambotMsgs['start']!['ru']!);
    }
    String? lastDone;
    for (final id in _requiredOrder) {
      if (_placed.contains(id)) lastDone = id;
    }
    final key = lastDone ?? 'start';
    final msg = _kambotMsgs[key]!;
    return p.t(msg['kz']!, msg['ru']!);
  }

  void _onPieceAccepted(String id, GameProvider p) {
    if (id != _nextRequired) return;
    setState(() => _placed.add(id));
    if (_placed.length == _requiredOrder.length) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _complete = true);
        _celebrationCtrl.forward(from: 0);
        if (!_rewardShown) {
          _rewardShown = true;
          p.addBotakoins(50);
          p.completeGame('yurt', 100, _requiredOrder.length);
          p.unlockBadge('yurt_master');
        }
      });
    }
  }

  void _onPieceRejected() {
    _shakeCtrl.forward(from: 0);
    setState(() => _shake = true);
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() => _shake = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5E5), Color(0xFFFFE0B2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(p),
              _kambotBubble(p),
              Expanded(child: _buildArea(p)),
              if (!_complete) _piecePalette(p) else _decorationPalette(p),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(GameProvider p) => Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                p.t('🏕️ Юрта құрастыру', '🏕️ Сборка юрты'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            BotakoinCounter(count: p.profile.botakoins, fontSize: 14),
          ],
        ),
      );

  Widget _kambotBubble(GameProvider p) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            const KambotAvatar(size: 44, animated: true),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _currentMessage(p),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildArea(GameProvider p) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final yurtSize = (w < h ? w : h) * 0.78;

        return DragTarget<String>(
          onWillAcceptWithDetails: (details) {
            final accept = details.data == _nextRequired;
            if (!accept) _onPieceRejected();
            return accept;
          },
          onAcceptWithDetails: (details) => _onPieceAccepted(details.data, p),
          builder: (context, candidate, rejected) {
            final highlight = candidate.isNotEmpty;
            return AnimatedBuilder(
              animation: _shakeCtrl,
              builder: (context, child) {
                final dx = _shake
                    ? 6 *
                        (_shakeCtrl.value * 8 % 2 < 1 ? 1 : -1) *
                        (1 - _shakeCtrl.value)
                    : 0.0;
                return Transform.translate(
                    offset: Offset(dx, 0), child: child);
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: highlight
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.12),
                    width: highlight ? 3 : 2,
                  ),
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: yurtSize,
                        height: yurtSize,
                        child: _yurtCanvas(yurtSize),
                      ),
                    ),
                    if (!_complete && _nextRequired != null)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              p.t(
                                '${_placed.length}/5 бөлік орналастырылды',
                                '${_placed.length}/5 деталей размещено',
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_complete)
                      ..._decorationPositions.entries.map((entry) {
                        final id = entry.key;
                        final pos = entry.value;
                        return Positioned(
                          left: pos.dx.clamp(0.0, w - 60),
                          top: pos.dy.clamp(0.0, h - 60),
                          child: _draggableDecoration(id, w, h),
                        );
                      }),
                    if (_complete) _celebrationOverlay(p),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _yurtCanvas(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: size * 0.10,
          child: _pieceVisual(
            id: 'base',
            width: size * 0.78,
            height: size * 0.12,
            radius: 12,
            color: const Color(0xFF8B6F47),
          ),
        ),
        Positioned(
          bottom: size * 0.22,
          child: _pieceVisual(
            id: 'walls',
            width: size * 0.7,
            height: size * 0.32,
            radius: 18,
            color: const Color(0xFFD4A574),
          ),
        ),
        Positioned(
          bottom: size * 0.22,
          child: _pieceVisual(
            id: 'felt',
            width: size * 0.72,
            height: size * 0.34,
            radius: 20,
            color: const Color(0xFFF5E6D3),
            opacityWhenPlaced: 0.55,
          ),
        ),
        Positioned(
          top: size * 0.12,
          child: _pieceVisual(
            id: 'crown',
            width: size * 0.55,
            height: size * 0.30,
            radius: size * 0.18,
            color: const Color(0xFFC8956D),
          ),
        ),
        Positioned(
          bottom: size * 0.22,
          child: _pieceVisual(
            id: 'door',
            width: size * 0.18,
            height: size * 0.28,
            radius: size * 0.09,
            color: const Color(0xFF6B4423),
          ),
        ),
        if (_placed.contains('crown'))
          Positioned(
            top: size * 0.04,
            child: Text(
              _pieces['crown']!['emoji']!,
              style: TextStyle(fontSize: size * 0.18),
            ),
          ),
      ],
    );
  }

  Widget _pieceVisual({
    required String id,
    required double width,
    required double height,
    required double radius,
    required Color color,
    double opacityWhenPlaced = 1.0,
  }) {
    final placed = _placed.contains(id);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: placed ? opacityWhenPlaced : 0.0,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: placed
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _piecePalette(GameProvider p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _requiredOrder.map((id) {
          final placed = _placed.contains(id);
          final isNext = id == _nextRequired;
          final piece = _pieces[id]!;
          final label = p.t(piece['kz']!, piece['ru']!);
          final tile = _paletteTile(piece['emoji']!, label, placed, isNext);
          if (placed || !isNext) return tile;
          return LongPressDraggable<String>(
            data: id,
            delay: const Duration(milliseconds: 120),
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.15,
                child: _paletteTile(piece['emoji']!, label, false, true),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: tile),
            child: tile,
          );
        }).toList(),
      ),
    );
  }

  Widget _paletteTile(String emoji, String label, bool placed, bool active) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: placed
            ? AppColors.success.withValues(alpha: 0.15)
            : active
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: placed ? 0.5 : (active ? 1.0 : 0.4),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: placed
                  ? AppColors.success
                  : (active ? AppColors.primary : Colors.grey),
            ),
          ),
          if (placed)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.check_circle_rounded,
                  size: 12, color: AppColors.success),
            ),
        ],
      ),
    );
  }

  Widget _decorationPalette(GameProvider p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            p.t('🎨 Декорациялар (тиіп қойыңыз)', '🎨 Декорации (нажми, чтобы добавить)'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _decorationDefs.entries.map((entry) {
                final id = entry.key;
                final def = entry.value;
                final inUse = _decorationPositions.containsKey(id);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: inUse
                        ? null
                        : () {
                            setState(() {
                              final n = _decorationPositions.length;
                              _decorationPositions[id] = Offset(
                                80.0 + (n * 28) % 200,
                                120.0 + (n * 24) % 160,
                              );
                            });
                          },
                    child: Opacity(
                      opacity: inUse ? 0.3 : 1.0,
                      child: Container(
                        width: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(def['emoji']!,
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _draggableDecoration(String id, double areaW, double areaH) {
    final def = _decorationDefs[id]!;
    return _DecorationDraggable(
      key: ValueKey('dec-$id'),
      emoji: def['emoji']!,
      onMoved: (delta) {
        setState(() {
          final current = _decorationPositions[id] ?? Offset.zero;
          _decorationPositions[id] = Offset(
            (current.dx + delta.dx).clamp(0.0, areaW - 60),
            (current.dy + delta.dy).clamp(0.0, areaH - 60),
          );
        });
      },
    );
  }

  Widget _celebrationOverlay(GameProvider p) {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _celebrationCtrl,
            curve: Curves.elasticOut,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  p.t('+50 ботакоин!', '+50 ботакоинов!'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Single decoration sprite — free-form draggable inside the build area.
class _DecorationDraggable extends StatelessWidget {
  final String emoji;
  final void Function(Offset delta) onMoved;

  const _DecorationDraggable({
    super.key,
    required this.emoji,
    required this.onMoved,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) => onMoved(d.delta),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
