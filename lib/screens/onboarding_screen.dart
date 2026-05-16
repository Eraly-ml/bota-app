import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';
import '../widgets/avatar_widget.dart';
import 'map_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  int _selectedAge = 7;
  int _selectedAvatar = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GameProvider>();
      if (provider.onboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<GameProvider>().t('Атыңды жаз!', 'Напиши свое имя!')),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.read<GameProvider>().completeOnboarding(name, _selectedAge, _selectedAvatar);

    final refCode = _referralController.text.trim();
    if (refCode.isNotEmpty) {
      context.read<GameProvider>().redeemReferralCode(refCode);
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MapScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.desertGradient),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                GestureDetector(
                  onTap: () => provider.toggleLanguage(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.language, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(provider.isRussian ? 'Қазақша' : 'Русский',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ]),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(provider),
                  _buildAgePage(provider),
                  _buildAvatarPage(provider),
                  _buildNamePage(provider),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(GameProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 32),
        KambotAvatar(
          size: 140, showSpeechBubble: true,
          speechText: provider.t('Сәлем! Мен КамБот! 🐪', 'Привет! Я КамБот! 🐪'),
        ),
        const SizedBox(height: 24),
        Text(provider.t('Қазақстан бойынша саяхатқа шығайық!', 'Отправимся в путешествие по Казахстану!'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3)),
        const SizedBox(height: 12),
        Text(provider.t('Ойын ойна, білім ал, ботакоин жина! 🪙', 'Играй, учись, собирай ботакоины! 🪙'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        GameButton(text: provider.t('Бастайық!', 'Начнём!'), onPressed: _nextPage, icon: Icons.arrow_forward_rounded),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildAgePage(GameProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const KambotAvatar(size: 100),
        const SizedBox(height: 24),
        Text(provider.t('Сен нешедесін?', 'Сколько тебе лет?'),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16, runSpacing: 16, alignment: WrapAlignment.center,
          children: [7, 8, 9, 10, 11].map((age) {
            final isSelected = _selectedAge == age;
            return GestureDetector(
              onTap: () => setState(() => _selectedAge = age),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: 2),
                  boxShadow: [BoxShadow(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 12 : 8, offset: Offset(0, isSelected ? 4 : 2))],
                ),
                child: Center(child: Text('$age',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.textPrimary))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        GameButton(text: provider.t('Келесі', 'Дальше'), onPressed: _nextPage, icon: Icons.arrow_forward_rounded),
      ]),
    );
  }

  Widget _buildAvatarPage(GameProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 16),
        KambotAvatar(
          size: 100, showSpeechBubble: true,
          speechText: provider.t('Аватарыңды таңда! 🎨', 'Выбери аватарку! 🎨'),
        ),
        const SizedBox(height: 20),
        Text(provider.t('Өзіңе аватар таңда', 'Выбери себе аватарку'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(provider.t('Бұл сенің профильдегі суретің болады', 'Это будет твоя картинка в профиле'),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.85,
          ),
          itemCount: kTotalAvatars,
          itemBuilder: (_, i) {
            final isSelected = _selectedAvatar == i;
            final name = isImageAvatar(i)
                ? (provider.isRussian ? getImageAvatar(i)!.nameRu : getImageAvatar(i)!.nameKz)
                : (provider.isRussian ? kAvatars[i].nameRu : kAvatars[i].nameKz);
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: isSelected ? 2.5 : 0,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
                  ] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CartoonAvatar(avatarIndex: i, size: 48, isSelected: isSelected),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        GameButton(text: provider.t('Келесі', 'Дальше'), onPressed: _nextPage, icon: Icons.arrow_forward_rounded),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildNamePage(GameProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

        CartoonAvatar(avatarIndex: _selectedAvatar, size: 100, showBorder: true, borderColor: AppColors.primary),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Text(provider.t('Атың кім? 😊', 'Как тебя зовут? 😊'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]),
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: provider.t('Атыңды жаз...', 'Твоё имя...'),
              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontWeight: FontWeight.w400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(Icons.card_giftcard_rounded, color: AppColors.accentGreen.withValues(alpha: 0.6), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _referralController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 1),
                decoration: InputDecoration(
                  hintText: provider.t('Достың коды (міндетті емес)', 'Код друга (необязательно)'),
                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.4), fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 32),
        GameButton(
          text: provider.t('Саяхатты бастау! 🚀', 'Начать путешествие! 🚀'),
          onPressed: _completeOnboarding,
          color: AppColors.accentGreen, width: 280,
        ),
      ]),
    );
  }
}
