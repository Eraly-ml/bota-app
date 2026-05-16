import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SupabaseService {
  static Future<void> initialize() async {}

  static String getImageUrl(String path) => '';

  static Future<List<Map<String, dynamic>>> getWords() async => [
    {'kz': 'Алма', 'ru': 'Яблоко', 'image_path': 'words/apple.jpeg'},
    {'kz': 'Жылқы', 'ru': 'Лошадь', 'image_path': 'words/horse.jpeg'},
    {'kz': 'Күн', 'ru': 'Солнце', 'image_path': 'words/sun.jpeg'},
    {'kz': 'Тау', 'ru': 'Гора', 'image_path': 'words/mountains.jpeg'},
    {'kz': 'Су', 'ru': 'Вода', 'image_path': 'words/water.jpeg'},
    {'kz': 'Ай', 'ru': 'Луна', 'image_path': 'words/moon.jpeg'},
    {'kz': 'Бүркіт', 'ru': 'Орёл', 'image_path': 'words/eagle.jpeg'},
    {'kz': 'Түйе', 'ru': 'Верблюд', 'image_path': 'words/camel.jpeg'},
    {'kz': 'Қой', 'ru': 'Овца', 'image_path': 'words/sheep.jpeg'},
    {'kz': 'Гүл', 'ru': 'Цветок', 'image_path': 'words/flower.jpeg'},
    {'kz': 'Аю', 'ru': 'Медведь', 'image_path': 'words/bear.jpeg'},
    {'kz': 'Жұлдыз', 'ru': 'Звезда', 'image_path': 'words/star.jpeg'},
  ];

  static Future<List<Map<String, dynamic>>> getQuizQuestions() async {
    try {
      final raw = await rootBundle.loadString('assets/data/quiz.json');
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getShopItems() async {
    try {
      final raw = await rootBundle.loadString('assets/data/prizes.json');
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<String>> getCandyImages() async => [
    'candies/candy0.jpeg', 'candies/candy1.jpeg', 'candies/candy2.jpeg',
    'candies/candy3.jpeg', 'candies/candy4.jpeg', 'candies/candy5.jpeg',
    'candies/candy6.jpeg', 'candies/candy7.jpeg', 'candies/candy8.jpeg',
    'candies/candy10.jpeg', 'candies/candy20.jpeg', 'candies/candy21.jpeg',
  ];

  static Future<List<String>> getObstacleImages() async => [
    'catchgame/pepper.png', 'catchgame/stone.png', 'catchgame/bomb.png',
  ];

  static Future<List<Map<String, dynamic>>> getQuestScenes() async => [
    {'bg_colors': ['#1a1a2e','#16213e'], 'title_kz': 'Шарын шатқалы', 'title_ru': 'Чарынский каньон', 'text_kz': 'КамБот Шарын шатқалына келді. Алдында екі жол бар. Қайсысын таңдайсың?', 'text_ru': 'КамБот пришёл к Чарынскому каньону. Впереди две дороги. Какую выберешь?', 'choices': [{'textKz': 'Жасыл орман жолы', 'textRu': 'Через зелёный лес', 'correct': true, 'replyKz': 'Жарайсың! Орманда сирек кездесетін ағаштар бар!', 'replyRu': 'Молодец! В лесу растут редкие деревья!'}, {'textKz': 'Құм жолы', 'textRu': 'Через пустыню', 'correct': false, 'replyKz': 'Құмда ыстық! Бірақ КамБот шыдамды', 'replyRu': 'В пустыне жарко! Но КамБот выносливый'}]},
    {'bg_colors': ['#0f3460','#533483'], 'title_kz': 'Бүркіт кездесті!', 'title_ru': 'Встреча с орлом!', 'text_kz': 'Жолда КамБот бүркіт кездестірді. Қазақтардың ұлттық құсы кім?', 'text_ru': 'КамБот встретил орла-беркута. Какая птица - символ казахов?', 'choices': [{'textKz': 'Бүркіт (Беркут)', 'textRu': 'Беркут', 'correct': true, 'replyKz': 'Дұрыс! Бүркіт - қазақтардың құрметті құсы!', 'replyRu': 'Верно! Беркут - символ свободы!'}, {'textKz': 'Тоты құс', 'textRu': 'Попугай', 'correct': false, 'replyKz': 'Жоқ, бірақ тоты құс та керемет!', 'replyRu': 'Нет, но попугаи тоже классные!'}]},
    {'bg_colors': ['#533483','#e94560'], 'title_kz': 'Тау шыңы', 'title_ru': 'Горная вершина', 'text_kz': 'КамБот тау шыңына жетті! Не істейсің?', 'text_ru': 'КамБот добрался до вершины! Что делаешь?', 'choices': [{'textKz': 'Фото түсіру', 'textRu': 'Сделать фото', 'correct': true, 'replyKz': 'Тамаша! Шарын 12 миллион жыл бұрын пайда болған!', 'replyRu': 'Отлично! Каньону 12 миллионов лет!'}, {'textKz': 'Тынығу', 'textRu': 'Отдохнуть', 'correct': false, 'replyKz': 'Дұрыс, демалу да маңызды!', 'replyRu': 'Правильно, отдых тоже важен!'}]},
    {'bg_colors': ['#e94560','#FF8C00'], 'title_kz': 'Қазына!', 'title_ru': 'Сокровище!', 'text_kz': 'КамБот үңгірде жасырылған қазына тапты! Саяхат аяқталды!', 'text_ru': 'КамБот нашёл спрятанное сокровище! Путешествие завершено!', 'choices': [{'textKz': 'Ботакоиндерді жинау!', 'textRu': 'Собрать ботакоины!', 'correct': true, 'replyKz': 'Сен батыл саяхатшысың!', 'replyRu': 'Ты настоящий путешественник!'}, {'textKz': 'Шоколадты алу!', 'textRu': 'Взять шоколад!', 'correct': true, 'replyKz': 'Баян Сулу шоколады - ең дәмді!', 'replyRu': 'Шоколад Баян Сулу - самый вкусный!'}]},
  ];

  static Future<List<Map<String, String>>> getLearningMaterials() async => [
    {
      'titleKz': 'Қазақстанның астанасы',
      'titleRu': 'Столица Казахстана',
      'contentKz': 'Қазақстанның астанасы - Астана қаласы. Ол 1997 жылы астана мәртебесін алды. Бұрын астана Алматы қаласы болған.',
      'contentRu': 'Столица Казахстана - город Астана. Он получил статус столицы в 1997 году. Раньше столицей был город Алматы.',
      'category': 'geography',
    },
    {
      'titleKz': 'Ең биік тау',
      'titleRu': 'Самая высокая гора',
      'contentKz': 'Қазақстандағы ең биік тау - Хан-Тәңірі. Оның биіктігі 6995 метр. Ол Тянь-Шань тау жүйесінде орналасқан.',
      'contentRu': 'Самая высокая гора Казахстана - Хан-Тенгри. Её высота 6995 метров. Она расположена в горной системе Тянь-Шань.',
      'category': 'geography',
    },
    {
      'titleKz': 'Қазақстан жалауы',
      'titleRu': 'Флаг Казахстана',
      'contentKz': 'Қазақстан жалауы - көгілдір түсті. Көгілдір түс бейбітшілік пен бірлікті білдіреді. Жалауда алтын күн мен бүркіт бейнеленген.',
      'contentRu': 'Флаг Казахстана голубого цвета. Голубой цвет символизирует мир и единство. На флаге изображены золотое солнце и степной орёл.',
      'category': 'symbols',
    },
    {
      'titleKz': 'Ұлттық символ - Барыс',
      'titleRu': 'Национальный символ - Барс',
      'contentKz': 'Қазақстанның ұлттық символы - қар барысы (ирбис). Ол күш пен мақтаныштың символы. Қар барысы тауларда тұрады.',
      'contentRu': 'Национальный символ Казахстана - снежный барс (ирбис). Он символ силы и гордости. Снежный барс живёт высоко в горах.',
      'category': 'symbols',
    },
    {
      'titleKz': 'Бәйтерек монументі',
      'titleRu': 'Монумент Байтерек',
      'contentKz': 'Бәйтерек монументі Астана қаласында орналасқан. Оның биіктігі 97 метр. Бәйтерек - өмір ағашы дегенді білдіреді.',
      'contentRu': 'Монумент Байтерек находится в городе Астана. Его высота 97 метров. Байтерек означает дерево жизни.',
      'category': 'landmarks',
    },
    {
      'titleKz': 'Балқаш көлі',
      'titleRu': 'Озеро Балхаш',
      'contentKz': 'Балқаш - Қазақстандағы ең үлкен көл. Оның бірегей ерекшелігі: бір жағы тұщы су, екінші жағы тұзды су.',
      'contentRu': 'Балхаш - самое большое озеро Казахстана. Его уникальная особенность: одна половина пресная, а другая - солёная.',
      'category': 'geography',
    },
    {
      'titleKz': 'Көкпар ойыны',
      'titleRu': 'Игра Кокпар',
      'contentKz': 'Көкпар - қазақтардың ұлттық спорт ойыны. Бұл ат үстінде ойналатын ойын. Оған 1000 жылдан астам тарих бар.',
      'contentRu': 'Кокпар - национальный вид спорта казахов. Это конная игра. Ей более 1000 лет.',
      'category': 'culture',
    },
    {
      'titleKz': 'Яссауи кесенесі',
      'titleRu': 'Мавзолей Яссауи',
      'contentKz': 'Қожа Ахмет Яссауи кесенесі Түркістан қаласында орналасқан. Ол XIV ғасырда Әмір Темір бұйрығымен салынған.',
      'contentRu': 'Мавзолей Ходжи Ахмеда Яссауи находится в городе Туркестан. Он был построен по приказу Тамерлана в XIV веке.',
      'category': 'landmarks',
    },
    {
      'titleKz': 'Баян Сұлу фабрикасы',
      'titleRu': 'Фабрика Баян Сулу',
      'contentKz': 'Баян Сұлу фабрикасы Қостанай қаласында орналасқан. Ол Қазақстандағы ең ірі тәттілер өндірушісі.',
      'contentRu': 'Фабрика Баян Сулу находится в городе Костанай. Она является крупнейшим производителем сладостей в Казахстане.',
      'category': 'culture',
    },
    {
      'titleKz': 'Қымыз ішімдігі',
      'titleRu': 'Напиток Кумыс',
      'contentKz': 'Қымыз - қазақтардың ұлттық ішімдігі. Ол бие сүтінен жасалады. Қымыз өте пайдалы ішімдік.',
      'contentRu': 'Кумыс - национальный напиток казахов. Его делают из кобыльего молока. Кумыс очень полезный напиток.',
      'category': 'culture',
    },
    {
      'titleKz': 'Шарын шатқалы',
      'titleRu': 'Чарынский каньон',
      'contentKz': 'Шарын шатқалын Гранд-Каньонның кіші бауыры деп атайды. Оған 12 миллион жыл. Ол өте әдемі табиғат кереметі.',
      'contentRu': 'Чарынский каньон называют младшим братом Гранд-Каньона. Ему 12 миллионов лет. Это удивительное чудо природы.',
      'category': 'geography',
    },
    {
      'titleKz': 'Қазақстанның орны',
      'titleRu': 'Расположение Казахстана',
      'contentKz': 'Қазақстан Еуразия құрлығында орналасқан. Ол Еуропа мен Азияның екеуінде де бар. Әлемдегі 9-шы үлкен ел.',
      'contentRu': 'Казахстан расположен на континенте Евразия. Он находится и в Европе, и в Азии. 9-я по величине страна в мире.',
      'category': 'geography',
    },
  ];

  static Future<void> syncProfile({required String deviceId, required Map<String, dynamic> profileData}) async {}
  static Future<Map<String, dynamic>?> loadProfile(String deviceId) async => null;
  static Future<void> refreshCache() async {}
}
