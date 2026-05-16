import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/friend.dart';
import '../models/challenge.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_widget.dart';
import 'multiplayer_challenge_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _nameCtrl = TextEditingController();
  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgDarkMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(p),
              const SizedBox(height: 8),
              _buildTabBar(p),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildFriendsTab(p),
                    _buildChallengesTab(p),
                    _buildLeaderboardTab(p),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameProvider p) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 22, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.people_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            p.t('Достар', 'Друзья'),
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white),
          ),
        ),
        _buildCoinBadge(p),
      ],
    ),
  );

  Widget _buildCoinBadge(GameProvider p) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.botakoin.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
          color: AppColors.botakoin.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset('assets/coin/coin.jpeg',
              width: 16, height: 16, fit: BoxFit.cover),
        ),
        const SizedBox(width: 6),
        Text(
          '${p.profile.botakoins}',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.botakoin),
        ),
      ],
    ),
  );

  Widget _buildTabBar(GameProvider p) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: TabBar(
      controller: _tabCtrl,
      indicator: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      dividerColor: Colors.transparent,
      padding: const EdgeInsets.all(4),
      tabs: [
        Tab(text: p.t('Достар', 'Друзья')),
        Tab(text: p.t('Челлендждер', 'Челленджи')),
        Tab(text: p.t('Лидерборд', 'Лидерборд')),
      ],
    ),
  );

  // ─── Friends Tab ───

  Widget _buildFriendsTab(GameProvider p) {
    final friends = p.profile.friends;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAddFriendCard(p),
          const SizedBox(height: 16),
          if (friends.isEmpty)
            _buildEmptyFriends(p)
          else
            ...friends.map((f) => _buildFriendTile(f, p)),
          const SizedBox(height: 16),
          _buildReferralCard(p),
        ],
      ),
    );
  }

  Widget _buildAddFriendCard(GameProvider p) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_add_rounded,
              color: Colors.white, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          p.t('Дос қосу', 'Добавить друга'),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: p.t('Аты', 'Имя друга'),
              hintStyle:
                  TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            final rng = _rng();
            p.addFriend(
              name,
              rng.nextInt(12),
              rng.nextInt(500) + 50,
              rng.nextInt(30),
              rng.nextInt(3) + 1,
              '',
            );
            _nameCtrl.clear();
            FocusScope.of(context).unfocus();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              p.t('Қосу', 'Добавить'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
          ),
        ),
      ],
    ),
  );

  Random _rng() => Random();

  Widget _buildEmptyFriends(GameProvider p) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: Column(
      children: [
        Icon(Icons.people_outline_rounded,
            color: Colors.white.withValues(alpha: 0.3), size: 48),
        const SizedBox(height: 12),
        Text(
          p.t('Әлі достар жоқ', 'Пока нет друзей'),
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 4),
        Text(
          p.t('Жоғарыдан дос қос', 'Добавь друга сверху'),
          style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.3)),
        ),
      ],
    ),
  );

  Widget _buildFriendTile(Friend f, GameProvider p) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: Row(
      children: [
        CartoonAvatar(avatarIndex: f.avatarIndex, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f.name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                '${p.t('Деңгей', 'Уровень')} ${f.level}  •  ${f.totalGamesPlayed} ${p.t('ойын', 'игр')}',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.botakoin.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.asset('assets/coin/coin.jpeg',
                    width: 12, height: 12, fit: BoxFit.cover),
              ),
              const SizedBox(width: 4),
              Text(
                '${f.botakoins}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.botakoin),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showChallengeOptions(f, p),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports_esports_rounded,
                color: AppColors.primary, size: 18),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => p.removeFriend(f.id),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.4), size: 18),
          ),
        ),
      ],
    ),
  );

  void _showChallengeOptions(Friend f, GameProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1b1e2b),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              p.t('Челлендж жіберу', 'Отправить челлендж'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${f.name} ${p.t('ұсынды', 'предлагает')}',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            _challengeOption(p, f, 'quiz', Icons.quiz_rounded,
                p.t('Викторина', 'Викторина')),
            _challengeOption(p, f, 'math', Icons.calculate_rounded,
                p.t('Математика', 'Математика')),
            _challengeOption(p, f, 'memory', Icons.memory_rounded,
                p.t('Жады', 'Память')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _challengeOption(GameProvider p, Friend f, String gameId,
      IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiplayerChallengeScreen(
              friendId: f.id,
              gameId: gameId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(GameProvider p) {
    final referralLink =
        'https://mybota.vercel.app?ref=${p.profile.referralCode}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                p.t('Шақыру сілтемесі', 'Ссылка для приглашения'),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralLink,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referralLink));
                    setState(() => _linkCopied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _linkCopied = false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            _linkCopied
                                ? Icons.check_rounded
                                : Icons.copy_rounded,
                            color: Colors.white,
                            size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _linkCopied
                              ? p.t('Көшірілді', 'Скопировано')
                              : p.t('Көшіру', 'Копировать'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              p.inviteFriend();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset('assets/coin/coin.jpeg',
                          width: 20, height: 20, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    Text(p.t('+15 ботакоин алдың!', '+15 ботакоинов получено!'),
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                backgroundColor: const Color(0xFF58CC02),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF58CC02), Color(0xFF4CAF50)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    p.t('Досты шақыру', 'Пригласить друга'),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Challenges Tab ───

  Widget _buildChallengesTab(GameProvider p) {
    final active = p.getActiveChallenges();
    final completed = p.getCompletedChallenges();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (active.isNotEmpty) ...[
            _sectionTitle(p.t('Белсенді', 'Активные'), p),
            const SizedBox(height: 10),
            ...active.map((c) => _buildChallengeCard(c, p, true)),
            const SizedBox(height: 20),
          ],
          if (completed.isNotEmpty) ...[
            _sectionTitle(p.t('Аяқталған', 'Завершённые'), p),
            const SizedBox(height: 10),
            ...completed.map((c) => _buildChallengeCard(c, p, false)),
          ],
          if (active.isEmpty && completed.isEmpty) _buildEmptyChallenges(p),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, GameProvider p) => Text(
    text,
    style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
  );

  Widget _buildChallengeCard(Challenge c, GameProvider p, bool isActive) {
    final gameNames = {
      'quiz': p.t('Викторина', 'Викторина'),
      'math': p.t('Математика', 'Математика'),
      'memory': p.t('Жады', 'Память'),
    };
    final gameName = gameNames[c.gameId] ?? c.gameId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_esports_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    Text(
                      c.status == 'pending'
                          ? p.t('Күтілуде', 'Ожидает')
                          : c.status == 'accepted'
                              ? p.t('Қабылданды', 'Принят')
                              : p.t('Аяқталды', 'Завершён'),
                      style: TextStyle(
                          fontSize: 11,
                          color: c.status == 'completed'
                              ? const Color(0xFF58CC02)
                              : Colors.white.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
              if (isActive)
                GestureDetector(
                  onTap: () => p.deleteChallenge(c.id),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.3), size: 18),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _challengePlayerBlock(
                    c.fromPlayerName, c.fromScore, c.fromCorrect, true),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'VS',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.5)),
                ),
              ),
              Expanded(
                child: _challengePlayerBlock(
                  c.toPlayerId != null
                      ? p.profile.name.isNotEmpty
                          ? p.profile.name
                          : 'You'
                      : p.t('Күтілуде', 'Ожидает'),
                  c.toScore,
                  c.toCorrect,
                  false,
                ),
              ),
            ],
          ),
          if (c.status == 'completed' && c.localWon != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: c.localWon!
                    ? const Color(0xFF58CC02).withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                c.localWon!
                    ? p.t('Жеңіс! +10 ботакоин', 'Победа! +10 ботакоин')
                    : p.t('Жеңіліс...', 'Поражение...'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: c.localWon!
                        ? const Color(0xFF58CC02)
                        : AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _challengePlayerBlock(
      String name, int? score, int? correct, bool isLeft) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          name,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 2),
        Text(
          score != null ? '$score pts' : '-',
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        if (correct != null)
          Text(
            '$correct correct',
            style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4)),
          ),
      ],
    );
  }

  Widget _buildEmptyChallenges(GameProvider p) => Container(
    padding: const EdgeInsets.all(40),
    child: Column(
      children: [
        Icon(Icons.emoji_events_outlined,
            color: Colors.white.withValues(alpha: 0.2), size: 56),
        const SizedBox(height: 12),
        Text(
          p.t('Челлендждер жоқ', 'Нет челленджей'),
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 4),
        Text(
          p.t('Досқа челлендж жібер', 'Отправь челлендж другу'),
          style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.25)),
        ),
      ],
    ),
  );

  // ─── Leaderboard Tab ───

  Widget _buildLeaderboardTab(GameProvider p) {
    final entries = _buildRealLeaderboard(p);

    return Column(
      children: [
        const SizedBox(height: 16),
        if (entries.length >= 3) _buildPodium(entries, p),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: entries.length > 3 ? entries.length - 3 : 0,
            itemBuilder: (_, i) =>
                _buildLeaderboardTile(entries[i + 3], i + 4, p),
          ),
        ),
      ],
    );
  }

  List<_LeaderboardEntry> _buildRealLeaderboard(GameProvider p) {
    final List<_LeaderboardEntry> entries = [
      _LeaderboardEntry(
        name: p.profile.name.isNotEmpty ? p.profile.name : 'Сен',
        avatarIndex: p.profile.avatarIndex,
        botakoins: p.profile.botakoins,
        isUser: true,
      ),
      ...p.profile.friends.map((f) => _LeaderboardEntry(
            name: f.name,
            avatarIndex: f.avatarIndex,
            botakoins: f.botakoins,
            isUser: false,
          )),
    ];
    entries.sort((a, b) => b.botakoins.compareTo(a.botakoins));
    return entries;
  }

  Widget _buildPodium(List<_LeaderboardEntry> entries, GameProvider p) {
    final second = entries[1];
    final first = entries[0];
    final third = entries[2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _podiumItem(second, 2, 90, const Color(0xFFAEB6BF), p)),
          const SizedBox(width: 8),
          Expanded(child: _podiumItem(first, 1, 110, const Color(0xFFFFD700), p)),
          const SizedBox(width: 8),
          Expanded(child: _podiumItem(third, 3, 75, const Color(0xFFCD7F32), p)),
        ],
      ),
    );
  }

  Widget _podiumItem(_LeaderboardEntry entry, int rank, double height,
      Color medalColor, GameProvider p) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            CartoonAvatar(
              avatarIndex: entry.avatarIndex,
              size: rank == 1 ? 64 : 52,
              showBorder: true,
              borderColor: medalColor,
            ),
            Positioned(
              bottom: -8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: medalColor.withValues(alpha: 0.4),
                        blurRadius: 6)
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          entry.name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: entry.isUser ? FontWeight.w900 : FontWeight.w700,
            color: entry.isUser ? AppColors.primary : Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset('assets/coin/coin.jpeg',
                  width: 12, height: 12, fit: BoxFit.cover),
            ),
            const SizedBox(width: 3),
            Text(
              '${entry.botakoins}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.botakoin),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                medalColor.withValues(alpha: 0.2),
                medalColor.withValues(alpha: 0.08),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: medalColor.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Icon(
              rank == 1 ? Icons.emoji_events_rounded : Icons.star_rounded,
              color: medalColor.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(_LeaderboardEntry entry, int rank, GameProvider p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: entry.isUser
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.3), width: 1.5)
            : Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: entry.isUser
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CartoonAvatar(avatarIndex: entry.avatarIndex, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            entry.isUser ? FontWeight.w900 : FontWeight.w700,
                        color: entry.isUser
                            ? AppColors.primary
                            : Colors.white,
                      ),
                    ),
                    if (entry.isUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.t('Сен', 'Ты'),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset('assets/coin/coin.jpeg',
                    width: 16, height: 16, fit: BoxFit.cover),
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.botakoins}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.botakoin),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry {
  final String name;
  final int avatarIndex;
  final int botakoins;
  final bool isUser;

  const _LeaderboardEntry({
    required this.name,
    required this.avatarIndex,
    required this.botakoins,
    this.isUser = false,
  });
}
