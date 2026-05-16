import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_widget.dart';
import 'shop_screen.dart';
import 'explore_kz_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgDarkMid],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _header(context, p),
              const SizedBox(height: 24),
              _profileCard(p),
              const SizedBox(height: 16),
              _statsGrid(p),
              const SizedBox(height: 16),
              _achievements(p),
              const SizedBox(height: 16),
              _actions(context, p),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, GameProvider p) => Row(children: [
    GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)]),
        child: const Icon(Icons.arrow_back_rounded, size: 22, color: AppColors.textOnDark),
      ),
    ),
    const SizedBox(width: 14),
    Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 22)),
    const SizedBox(width: 12),
    Expanded(child: Text(p.t('Профиль', 'Профиль'),
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textOnDark))),
  ]);

  Widget _profileCard(GameProvider p) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFFF9A56), Color(0xFFFF6B35)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3)),
        child: CartoonAvatar(avatarIndex: p.profile.avatarIndex, size: 80),
      ),
      const SizedBox(height: 14),
      Text(p.profile.name.isNotEmpty ? p.profile.name : '???',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _badge(Icons.cake_rounded, '${p.profile.age} ${p.t("жас", "лет")}'),
        const SizedBox(width: 8),
        _badge(Icons.shield_rounded, 'Lv.${p.profile.level}'),
      ]),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(p.profile.levelTitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600)),
        Text('${(p.profile.progressToNextLevel * 100).round()}%', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: p.profile.progressToNextLevel, backgroundColor: Colors.white.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 8)),
    ]),
  );

  Widget _badge(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 14), const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _statsGrid(GameProvider p) => Row(children: [
    Expanded(child: _stat(null, AppColors.botakoin, '${p.profile.botakoins}', p.t('Ботакоин', 'Ботакоинов'), true)),
    const SizedBox(width: 12),
    Expanded(child: _stat(Icons.sports_esports_rounded, AppColors.accentGreen, '${p.profile.totalGamesPlayed}', p.t('Ойын', 'Игр'), false)),
    const SizedBox(width: 12),
    Expanded(child: _stat(Icons.check_circle_rounded, AppColors.accentBlue, '${p.profile.totalCorrectAnswers}', p.t('Дұрыс', 'Верных'), false)),
  ]);

  Widget _stat(IconData? icon, Color color, String value, String label, bool asset) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
        child: asset
          ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset('assets/coin/coin.jpeg', width: 24, height: 24, fit: BoxFit.cover))
          : Icon(icon, color: color, size: 24)),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textOnDark)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textOnDarkSecondary), textAlign: TextAlign.center),
    ]),
  );

  Widget _achievements(GameProvider p) {
    final earned = GameProvider.achievementDefs.entries.where((e) => p.profile.achievements.contains(e.key)).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.botakoin, size: 22),
          const SizedBox(width: 8),
          Text(p.t('Жетістіктер', 'Достижения'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.botakoin.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text('${earned.length}/${GameProvider.achievementDefs.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.botakoin))),
        ]),
        const SizedBox(height: 14),
        if (earned.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(16),
            child: Text(p.t('Әзірге жетістік жоқ', 'Пока нет достижений'), style: const TextStyle(color: AppColors.textOnDarkSecondary, fontWeight: FontWeight.w500))))
        else
          Wrap(spacing: 8, runSpacing: 8, children: earned.map((e) {
            final a = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.botakoin.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.botakoin.withValues(alpha: 0.2))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(a['icon'] ?? '🏆', style: const TextStyle(fontSize: 18)), const SizedBox(width: 6),
                Text(p.isRussian ? a['nameRu']! : a['nameKz']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textOnDark)),
              ]),
            );
          }).toList()),
      ]),
    );
  }

  Widget _actions(BuildContext context, GameProvider p) => Column(children: [
    _actionBtn(context, Icons.store_rounded, p.t('Дүкен', 'Магазин'), const [Color(0xFF667EEA), Color(0xFF764BA2)],
      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()))),
    const SizedBox(height: 10),
    _actionBtn(context, Icons.explore_rounded, p.t('Қазақстанды зерттеу', 'Исследуй Казахстан'), const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreKzScreen()))),
  ]);

  Widget _actionBtn(BuildContext context, IconData icon, String label, List<Color> grad, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(gradient: LinearGradient(colors: grad), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textOnDark))),
        Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textOnDarkSecondary.withValues(alpha: 0.5), size: 16),
      ]),
    ),
  );
}
