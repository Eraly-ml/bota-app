import 'package:flutter/material.dart';

class AvatarData {
  final IconData icon;
  final List<Color> gradientColors;
  final String nameRu;
  final String nameKz;

  const AvatarData({
    required this.icon,
    required this.gradientColors,
    required this.nameRu,
    required this.nameKz,
  });
}

const List<AvatarData> kAvatars = [
  AvatarData(
    icon: Icons.pets_rounded,
    gradientColors: [Color(0xFFFF9A56), Color(0xFFFF6B35)],
    nameRu: 'Лев',
    nameKz: 'Арыстан',
  ),
  AvatarData(
    icon: Icons.cruelty_free_rounded,
    gradientColors: [Color(0xFF7ED6DF), Color(0xFF22A6B3)],
    nameRu: 'Панда',
    nameKz: 'Панда',
  ),
  AvatarData(
    icon: Icons.emoji_nature_rounded,
    gradientColors: [Color(0xFFFF7979), Color(0xFFEB4D4B)],
    nameRu: 'Лиса',
    nameKz: 'Түлкі',
  ),
  AvatarData(
    icon: Icons.flutter_dash_rounded,
    gradientColors: [Color(0xFF686DE0), Color(0xFF4834D4)],
    nameRu: 'Птичка',
    nameKz: 'Құс',
  ),
  AvatarData(
    icon: Icons.ac_unit_rounded,
    gradientColors: [Color(0xFF82CCDD), Color(0xFF3C6382)],
    nameRu: 'Снежинка',
    nameKz: 'Қар',
  ),
  AvatarData(
    icon: Icons.star_rounded,
    gradientColors: [Color(0xFFFFD32A), Color(0xFFF6B93B)],
    nameRu: 'Звезда',
    nameKz: 'Жұлдыз',
  ),
  AvatarData(
    icon: Icons.local_florist_rounded,
    gradientColors: [Color(0xFFE056A0), Color(0xFFC44569)],
    nameRu: 'Цветок',
    nameKz: 'Гүл',
  ),
  AvatarData(
    icon: Icons.rocket_launch_rounded,
    gradientColors: [Color(0xFF786FA6), Color(0xFF574B90)],
    nameRu: 'Ракета',
    nameKz: 'Зымыран',
  ),
  AvatarData(
    icon: Icons.auto_awesome_rounded,
    gradientColors: [Color(0xFFF8C291), Color(0xFFE55039)],
    nameRu: 'Единорог',
    nameKz: 'Бірмүйіз',
  ),
  AvatarData(
    icon: Icons.forest_rounded,
    gradientColors: [Color(0xFF6AB04C), Color(0xFF27AE60)],
    nameRu: 'Дерево',
    nameKz: 'Ағаш',
  ),
  AvatarData(
    icon: Icons.catching_pokemon_rounded,
    gradientColors: [Color(0xFFFF6348), Color(0xFFFF4757)],
    nameRu: 'Дракон',
    nameKz: 'Айдаһар',
  ),
  AvatarData(
    icon: Icons.waves_rounded,
    gradientColors: [Color(0xFF70A1FF), Color(0xFF1E90FF)],
    nameRu: 'Дельфин',
    nameKz: 'Дельфин',
  ),
];

class ImageAvatarData {
  final String imagePath;
  final List<Color> gradientColors;
  final String nameRu;
  final String nameKz;
  const ImageAvatarData({
    required this.imagePath,
    required this.gradientColors,
    required this.nameRu,
    required this.nameKz,
  });
}

const List<ImageAvatarData> kImageAvatars = [
  ImageAvatarData(
    imagePath: 'assets/avatars/snow_leopard.png',
    gradientColors: [Color(0xFFB0C4DE), Color(0xFF4A90D9)],
    nameRu: 'Ирбис',
    nameKz: 'Ырбыс',
  ),
];

int get kTotalAvatars => kAvatars.length + kImageAvatars.length;

bool isImageAvatar(int index) => index >= kAvatars.length;

ImageAvatarData? getImageAvatar(int index) {
  if (!isImageAvatar(index)) return null;
  final imgIdx = index - kAvatars.length;
  if (imgIdx >= kImageAvatars.length) return null;
  return kImageAvatars[imgIdx];
}

class CartoonAvatar extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final bool showBorder;
  final bool isSelected;
  final Color? borderColor;

  const CartoonAvatar({
    super.key,
    required this.avatarIndex,
    this.size = 60,
    this.showBorder = false,
    this.isSelected = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedIndex = avatarIndex.clamp(0, kAvatars.length + kImageAvatars.length - 1);

    if (isImageAvatar(clampedIndex)) {
      final imgAvatar = getImageAvatar(clampedIndex)!;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: (showBorder || isSelected)
              ? Border.all(
                  color: borderColor ?? (isSelected ? Colors.white : imgAvatar.gradientColors.first),
                  width: isSelected ? 3.5 : 2.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: imgAvatar.gradientColors.first.withValues(alpha: isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            imgAvatar.imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final avatar = kAvatars[clampedIndex];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: avatar.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: (showBorder || isSelected)
            ? Border.all(
                color: borderColor ?? (isSelected ? Colors.white : avatar.gradientColors.first),
                width: isSelected ? 3.5 : 2.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: avatar.gradientColors.first.withValues(alpha: isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        avatar.icon,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
