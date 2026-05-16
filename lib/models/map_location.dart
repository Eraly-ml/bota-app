import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MapLocation {
  final String id;
  final String nameKz;
  final String nameRu;
  final String descriptionKz;
  final String descriptionRu;
  final IconData iconData;
  final Color color;
  final List<String> gameIds;
  final int requiredLevel;
  final int order;

  const MapLocation({
    required this.id,
    required this.nameKz,
    required this.nameRu,
    required this.descriptionKz,
    required this.descriptionRu,
    required this.iconData,
    required this.color,
    required this.gameIds,
    required this.order,
    this.requiredLevel = 1,
  });

  static const List<MapLocation> allLocations = [
    MapLocation(
      id: 'almaty',
      nameKz: 'Алматы',
      nameRu: 'Алматы',
      descriptionKz: 'Тау бөктеріндегі алма бақтары',
      descriptionRu: 'Яблоневые сады у подножия гор',
      iconData: Icons.landscape_rounded,
      color: AppColors.almaty,
      gameIds: ['memory', 'math', 'catch'],
      order: 0,
    ),
    MapLocation(
      id: 'astana',
      nameKz: 'Астана',
      nameRu: 'Астана',
      descriptionKz: 'Бәйтерек - өмір ағашы',
      descriptionRu: 'Байтерек - дерево жизни',
      iconData: Icons.account_balance_rounded,
      color: AppColors.astana,
      gameIds: ['words', 'quiz'],
      order: 1,
    ),
    MapLocation(
      id: 'turkestan',
      nameKz: 'Түркістан',
      nameRu: 'Туркестан',
      descriptionKz: 'Қожа Ахмет Яссауи кесенесі',
      descriptionRu: 'Мавзолей Ходжи Ахмеда Яссауи',
      iconData: Icons.mosque_rounded,
      color: AppColors.turkestan,
      gameIds: ['puzzle', 'words'],
      order: 2,
      requiredLevel: 2,
    ),
    MapLocation(
      id: 'charyn',
      nameKz: 'Шарын',
      nameRu: 'Чарын',
      descriptionKz: 'Шарын шатқалы - табиғат кереметі',
      descriptionRu: 'Чарынский каньон - чудо природы',
      iconData: Icons.terrain_rounded,
      color: AppColors.charyn,
      gameIds: ['quest', 'catch'],
      order: 3,
      requiredLevel: 3,
    ),
    MapLocation(
      id: 'steppe',
      nameKz: 'Ұлы Дала',
      nameRu: 'Великая Степь',
      descriptionKz: 'Қазақ даласының сұлулығы',
      descriptionRu: 'Казахская Великая Степь',
      iconData: Icons.grass_rounded,
      color: AppColors.steppe,
      gameIds: ['memory', 'math', 'puzzle', 'yurt'],
      order: 4,
      requiredLevel: 2,
    ),
  ];
}
