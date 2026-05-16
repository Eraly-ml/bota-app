/// Locally-issued shop coupon redeemable in-store (offline-only).
///
/// Generated via the shop flow; persisted inside `ChildProfile`.
class Coupon {
  final String id;
  final String prizeId;
  final String code;
  final DateTime purchasedAt;
  final bool used;

  const Coupon({
    required this.id,
    required this.prizeId,
    required this.code,
    required this.purchasedAt,
    this.used = false,
  });

  Coupon copyWith({bool? used}) => Coupon(
        id: id,
        prizeId: prizeId,
        code: code,
        purchasedAt: purchasedAt,
        used: used ?? this.used,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'prizeId': prizeId,
        'code': code,
        'purchasedAt': purchasedAt.toIso8601String(),
        'used': used,
      };

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: (json['id'] ?? '').toString(),
        prizeId: (json['prizeId'] ?? '').toString(),
        code: (json['code'] ?? '').toString(),
        purchasedAt:
            DateTime.tryParse((json['purchasedAt'] ?? '').toString()) ??
                DateTime.now(),
        used: json['used'] == true,
      );
}
