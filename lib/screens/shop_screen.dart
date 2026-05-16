import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coupon.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import 'coupon_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await SupabaseService.getShopItems();
    if (!mounted) return;
    setState(() {
      _items = data.map((s) {
        final imagePath = (s['imagePath'] ?? '').toString();
        return <String, dynamic>{
          'id': (s['id'] ?? '').toString(),
          'nameKz': (s['nameKz'] ?? '').toString(),
          'nameRu': (s['nameRu'] ?? '').toString(),
          'image': imagePath,
          'emoji': (s['emoji'] ?? '🎁').toString(),
          'price': (s['cost'] as num?)?.toInt() ?? 0,
          'descKz': (s['descriptionKz'] ?? '').toString(),
          'descRu': (s['descriptionRu'] ?? '').toString(),
          'category': (s['category'] ?? '').toString(),
          'isCoupon': s['isCoupon'] == true,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    if (_items.isEmpty) {
      return Scaffold(body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.bgDark, AppColors.bgDarkMid], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
      ));
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppColors.bgDark, AppColors.bgDarkMid],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        )),
        child: SafeArea(child: Column(children: [
          _header(p, context),
          _balance(p),
          _conversionInfo(p),
          if (p.profile.purchasedCoupons.isNotEmpty) _myCouponsBar(p, context),
          Expanded(child: _grid(p, context)),
        ])),
      ),
    );
  }

  Widget _header(GameProvider p, BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textOnDark)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(p.t('🏪 Бота Дүкені', '🏪 Магазин Боты'),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textOnDark))),
    ]),
  );

  Widget _balance(GameProvider p) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppColors.botakoin.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      const Text('🪙', style: TextStyle(fontSize: 40)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.t('Сенің ботакоиндерің', 'Твои ботакоины'),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500)),
        Text('${p.profile.botakoins}',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
      ]),
      const Spacer(),
      Image.asset('assets/cumbot/glad.png', width: 48, height: 48),
    ]),
  );

  Widget _conversionInfo(GameProvider p) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
      const SizedBox(width: 8),
      Expanded(child: Text(
        p.t('100 ботакоин = 500₸ жеңілдік', '100 ботакоинов = 500₸ скидка'),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textOnDark),
      )),
    ]),
  );

  Widget _grid(GameProvider p, BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _items.length,
    itemBuilder: (_, i) => _shopCard(_items[i], p, context),
  );

  Widget _shopCard(Map<String, dynamic> item, GameProvider p, BuildContext context) {
    final canBuy = p.profile.botakoins >= (item['price'] as int);
    final imagePath = (item['image'] as String?) ?? '';
    final emoji = (item['emoji'] as String?) ?? '🎁';
    final desc = p.isRussian ? (item['descRu'] as String? ?? '') : (item['descKz'] as String? ?? '');
    final name = p.isRussian ? item['nameRu'] as String : item['nameKz'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(24), // rounded-4xl
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon/Image
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: imagePath.isEmpty
                ? Text(emoji, style: const TextStyle(fontSize: 32))
                : Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textOnDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item['price']} 🪙',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AppColors.textOnDarkSecondary, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Buy Button
                GestureDetector(
                  onTap: canBuy ? () => _buy(item, p, context) : null,
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: canBuy ? AppColors.primaryGradient : null,
                      color: canBuy ? null : const Color(0xFF2A1010),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      canBuy ? p.t('Сатып алу', 'Купить') : p.t('Тиындар жеткіліксіз', 'Недостаточно монет'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: canBuy ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buy(Map<String, dynamic> item, GameProvider p, BuildContext context) {
    final price = item['price'] as int;
    final isCoupon = item['isCoupon'] == true;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF2E3248),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(p.isRussian ? item['nameRu'] as String : item['nameKz'] as String,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(p.t(
        '$price ботакоин жұмсағыңыз келе ме?',
        'Потратить $price ботакоинов?'),
        style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(p.t('Жоқ', 'Нет'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            Navigator.pop(context);
            if (isCoupon) {
              final coupon = p.buyPrize(item['id'] as String, price);
              if (coupon == null) {
                _showSnack(context, p.t('Ботакоин жетпейді', 'Недостаточно ботакоинов'),
                  isError: true);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CouponScreen(coupon: coupon, prize: item),
                ),
              );
            } else {
              final ok = p.spendBotakoins(price);
              _showSnack(
                context,
                ok
                  ? p.t('Сатып алынды! 🎉', 'Куплено! 🎉')
                  : p.t('Ботакоин жетпейді', 'Недостаточно ботакоинов'),
                isError: !ok,
              );
            }
          },
          child: Text(p.t('Иә!', 'Да!'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _showSnack(BuildContext context, String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: isError ? Colors.redAccent : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Map<String, dynamic>? _prizeForCoupon(Coupon c) {
    for (final it in _items) {
      if ((it['id'] as String?) == c.prizeId) return it;
    }
    return null;
  }

  Widget _myCouponsBar(GameProvider p, BuildContext context) {
    final coupons = p.profile.purchasedCoupons.reversed.toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text(
                p.t('Менің купондарым', 'Мои купоны'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${coupons.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: coupons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = coupons[i];
                final prize = _prizeForCoupon(c);
                final emoji = (prize?['emoji'] as String?) ?? '🎫';
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CouponScreen(coupon: c, prize: prize),
                    ),
                  ),
                  child: Container(
                    width: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
