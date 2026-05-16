import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import 'game_quiz_screen.dart';

class LearnScreen extends StatefulWidget {
  final String locationName;
  final bool isDailyQuest;
  const LearnScreen({super.key, required this.locationName, this.isDailyQuest = false});
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with TickerProviderStateMixin {
  List<Map<String, String>> _materials = [];
  bool _loading = true;
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _progressCtrl;

  static const _categoryIcons = {
    'geography': Icons.public_rounded,
    'symbols': Icons.shield_rounded,
    'landmarks': Icons.location_city_rounded,
    'culture': Icons.auto_stories_rounded,
  };

  static const _categoryColors = {
    'geography': Color(0xFF4CAF50),
    'symbols': Color(0xFF2196F3),
    'landmarks': Color(0xFFFF9800),
    'culture': Color(0xFF9C27B0),
  };

  static const _categoryNamesRu = {
    'geography': 'География',
    'symbols': 'Символы',
    'landmarks': 'Достопримечательности',
    'culture': 'Культура',
  };

  static const _categoryNamesKz = {
    'geography': 'География',
    'symbols': 'Символдар',
    'landmarks': 'Көрнекті орындар',
    'culture': 'Мәдениет',
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final data = await SupabaseService.getLearningMaterials();
    if (!mounted) return;
    setState(() {
      _materials = data;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _nextCard() {
    if (_currentIndex < _materials.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _startQuiz() {
    if (widget.isDailyQuest) {
      context.read<GameProvider>().completeDailyQuest();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameQuizScreen(locationName: widget.locationName),
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();

    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1b1e2b), Color(0xFF2d3248)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1b1e2b), Color(0xFF2d3248)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(p),
              _buildProgressBar(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _materials.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) => _buildCard(index, p),
                ),
              ),
              _buildBottomControls(p),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameProvider p) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.t('Оқу материалы', 'Учебный материал'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                p.t('Викторинаға дайындал', 'Подготовься к викторине'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '${_currentIndex + 1}/${_materials.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildProgressBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: (_currentIndex + 1) / _materials.length,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF58CC02)),
        minHeight: 8,
      ),
    ),
  );

  Widget _buildCard(int index, GameProvider p) {
    final m = _materials[index];
    final category = m['category'] ?? 'geography';
    final catColor = _categoryColors[category] ?? Colors.blue;
    final catIcon = _categoryIcons[category] ?? Icons.public_rounded;
    final catName = p.isRussian
        ? (_categoryNamesRu[category] ?? '')
        : (_categoryNamesKz[category] ?? '');
    final title = p.isRussian ? m['titleRu']! : m['titleKz']!;
    final content = p.isRussian ? m['contentRu']! : m['contentKz']!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF252940),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: catColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: catColor.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [catColor.withValues(alpha: 0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(catIcon, color: catColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    catName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _materials.length,
                  (i) => Container(
                    width: i == _currentIndex ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? catColor
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(GameProvider p) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: Row(
      children: [

        GestureDetector(
          onTap: _currentIndex > 0 ? _prevCard : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _currentIndex > 0
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: _currentIndex > 0
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: GestureDetector(
            onTap: _currentIndex == _materials.length - 1 ? _startQuiz : _nextCard,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _currentIndex == _materials.length - 1
                      ? [const Color(0xFF58CC02), const Color(0xFF4CAF50)]
                      : [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_currentIndex == _materials.length - 1
                            ? const Color(0xFF58CC02)
                            : AppColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _currentIndex == _materials.length - 1
                        ? Icons.quiz_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentIndex == _materials.length - 1
                        ? p.t('Викторинаны бастау', 'Начать викторину')
                        : p.t('Келесі', 'Далее'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
