import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';
import 'learn_screen.dart';

class DailyQuestScreen extends StatelessWidget {
  const DailyQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    p.checkScreenTime();

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
              const SizedBox(height: 20),
              _dailyBanner(p),
              const SizedBox(height: 20),
              _questCard(context, p),
              const SizedBox(height: 16),
              _tipsCard(p),
              const SizedBox(height: 16),
              _streakCard(p),
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
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF58CC02), Color(0xFF4CAF50)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 22),
    ),
    const SizedBox(width: 12),
    Expanded(child: Text(
      p.t('Күнделікті квесттер', 'Ежедневные квесты'),
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textOnDark),
    )),
    BotakoinCounter(count: p.profile.botakoins, fontSize: 13),
  ]);

  Widget _dailyBanner(GameProvider p) {
    final completed = p.profile.dailyQuestCompleted;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completed
            ? [const Color(0xFF58CC02), const Color(0xFF4CAF50)]
            : [const Color(0xFFFF9A56), const Color(0xFFFF6B35)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: (completed ? const Color(0xFF58CC02) : const Color(0xFFFF6B35)).withValues(alpha: 0.3),
          blurRadius: 20, offset: const Offset(0, 8),
        )],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(
            completed ? Icons.check_circle_rounded : Icons.today_rounded,
            color: Colors.white, size: 36,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            completed
              ? p.t('Бүгінгі квест орындалды!', 'Квест на сегодня выполнен!')
              : p.t('Бүгінгі квест', 'Квест на сегодня'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            completed
              ? p.t('Ертең жаңа квест болады!', 'Завтра будет новый квест!')
              : p.t('Квестті орында - бонус ал!', 'Выполни квест - получи бонус!'),
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
          ),
        ])),
      ]),
    );
  }

  Widget _questCard(BuildContext context, GameProvider p) {
    final completed = p.profile.dailyQuestCompleted;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(22),
        border: completed
            ? Border.all(color: const Color(0xFF58CC02).withValues(alpha: 0.3), width: 2)
            : Border.all(color: AppColors.glassBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.quiz_rounded, color: Color(0xFF3498DB), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              p.t('Қазақстан туралы викторина', 'Викторина о Казахстане'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textOnDark),
            ),
            const SizedBox(height: 4),
            Text(
              p.t('Алдымен оқы, содан кейін жауап бер!', 'Сначала изучи, потом отвечай!'),
              style: const TextStyle(fontSize: 12, color: AppColors.textOnDarkSecondary, fontWeight: FontWeight.w500),
            ),
          ])),
          if (completed)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF58CC02), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
        ]),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.botakoin.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.botakoin.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            const Icon(Icons.card_giftcard_rounded, color: AppColors.botakoin, size: 18),
            const SizedBox(width: 8),
            Text(p.t('Сыйлық:', 'Награда:'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textOnDarkSecondary)),
            const SizedBox(width: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: Image.asset('assets/coin/coin.jpeg', width: 16, height: 16, fit: BoxFit.cover)),
            const SizedBox(width: 4),
            const Text('+30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(width: 4),
            Text(p.t('ботакоин', 'ботакоинов'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textOnDarkSecondary)),
          ]),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF), borderRadius: BorderRadius.circular(14),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFF3498DB), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(
              p.t(
                '1. Алдымен оқу материалын оқы\n2. Негізгі фактілерді есте сақта\n3. Викторинаға жауап бер\n4. Бонус ботакоин ал!',
                '1. Сначала прочитай учебный материал\n2. Запомни основные факты\n3. Пройди викторину\n4. Получи бонусные ботакоины!',
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2C3E50), height: 1.5),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: completed ? null : () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => LearnScreen(
                locationName: p.t('Қазақстан', 'Казахстан'),
                isDailyQuest: true,
              ),
            ));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: completed
                ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                : const LinearGradient(colors: [Color(0xFF58CC02), Color(0xFF4CAF50)]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: completed ? null : [
                BoxShadow(color: const Color(0xFF58CC02).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(completed ? Icons.check_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                completed
                  ? p.t('Орындалды', 'Выполнено')
                  : p.t('Оқуды бастау', 'Начать обучение'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _tipsCard(GameProvider p) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.lightbulb_rounded, color: AppColors.accentYellow, size: 20)),
        const SizedBox(width: 10),
        Text(p.t('Кеңес', 'Совет'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
      ]),
      const SizedBox(height: 12),
      Text(
        p.t(
          'Оқу материалын мұқият оқы - викторинадағы барлық сұрақтар сол материалдан алынады! 📚',
          'Внимательно изучи учебный материал - все вопросы в викторине будут именно по нему! 📚',
        ),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textOnDarkSecondary, height: 1.5),
      ),
    ]),
  );

  Widget _streakCard(GameProvider p) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
    ),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.t('Күнделікті квестті ұмытпа!', 'Не забывай про ежедневный квест!'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        Text(p.t('Күн сайын квест орында, ботакоин жина!', 'Выполняй квест каждый день и копи ботакоины!'),
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
      ])),
    ]),
  );
}
