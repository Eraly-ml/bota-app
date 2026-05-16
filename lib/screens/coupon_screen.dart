import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/coupon.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';

/// Full-screen redemption coupon: QR code + human-readable code + prize info.
///
/// Pass the [coupon] returned by `GameProvider.buyPrize`. The optional [prize]
/// map (from `prizes.json`) supplies emoji, name & description for the header;
/// when absent, a generic gift placeholder is rendered.
class CouponScreen extends StatelessWidget {
  final Coupon coupon;
  final Map<String, dynamic>? prize;

  const CouponScreen({super.key, required this.coupon, this.prize});

  String _two(int n) => n < 10 ? '0$n' : '$n';

  String _formatDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    final emoji = (prize?['emoji'] as String?) ?? '🎁';
    final name = p.isRussian
        ? (prize?['nameRu'] as String? ?? p.t('Сыйлық', 'Приз'))
        : (prize?['nameKz'] as String? ?? p.t('Сыйлық', 'Приз'));
    final desc = p.isRussian
        ? (prize?['descriptionRu'] as String? ?? '')
        : (prize?['descriptionKz'] as String? ?? '');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgDarkMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _topBar(context, p),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _prizeHeader(emoji, name, desc),
                        const SizedBox(height: 20),
                        _qrCard(),
                        const SizedBox(height: 16),
                        _codeCard(),
                        const SizedBox(height: 12),
                        _dateLine(p),
                        const SizedBox(height: 20),
                        _instructions(p),
                      ],
                    ),
                  ),
                ),
                _closeButton(context, p),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, GameProvider p) => Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textOnDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.t('🎫 Купон', '🎫 Купон'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textOnDark,
              ),
            ),
          ),
        ],
      );

  Widget _prizeHeader(String emoji, String name, String desc) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          border: Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textOnDark,
                    ),
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textOnDarkSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

  Widget _qrCard() => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: QrImageView(
                data: coupon.code,
                size: 200,
                backgroundColor: Colors.white, // Белый фон важен для сканирования!
                version: QrVersions.auto,
              ),
            ),
          ),
          // Вырезы по бокам (билет)
          Positioned(
            left: -12,
            top: 108, // По центру (200 + 40) / 2 = 120, примерно тут
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.bgDark, // Цвет фона экрана
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -12,
            top: 108,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.bgDark,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );

  Widget _codeCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(
          coupon.code,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: AppColors.textOnDark,
          ),
        ),
      );

  Widget _dateLine(GameProvider p) => Text(
        p.t(
          'Сатып алынды: ${_formatDate(coupon.purchasedAt)}',
          'Куплено: ${_formatDate(coupon.purchasedAt)}',
        ),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textOnDarkSecondary,
        ),
      );

  Widget _instructions(GameProvider p) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                p.t(
                  'QR-кодты дүкенде көрсетіңіз',
                  'Покажите QR-код в магазине Баян Сулу',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _closeButton(BuildContext context, GameProvider p) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            p.t('Жабу', 'Закрыть'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
}
