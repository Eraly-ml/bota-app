import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/game_provider.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';
import '../theme/app_colors.dart';

class _KzPlace {
  final String id, nameRu, nameKz, descRu, descKz, categoryRu, categoryKz;
  final String infoRu, infoKz, aiPromptRu, aiPromptKz;
  final IconData icon;
  final Color color;
  final double lat, lng;
  final int zoom;
  final String? population, yearFounded;
  final List<String> funFactsRu, funFactsKz;

  const _KzPlace({
    required this.id, required this.nameRu, required this.nameKz,
    required this.descRu, required this.descKz,
    required this.categoryRu, required this.categoryKz,
    required this.icon, required this.color,
    required this.lat, required this.lng, this.zoom = 11,
    this.population, this.yearFounded,
    required this.funFactsRu, required this.funFactsKz,
    required this.infoRu, required this.infoKz,
    required this.aiPromptRu, required this.aiPromptKz,
  });
}

const _places = <_KzPlace>[
  _KzPlace(
    id: 'astana', nameRu: 'Астана', nameKz: 'Астана',
    descRu: 'Столица Казахстана', descKz: 'Қазақстан астанасы',
    categoryRu: 'Город', categoryKz: 'Қала',
    icon: Icons.location_city_rounded, color: Color(0xFF3498DB),
    lat: 51.1694, lng: 71.4491, population: '1.3 млн', yearFounded: '1830',
    funFactsRu: ['Байтерек - символ города высотой 97 метров', 'Хан Шатыр - самый большой шатёр в мире', 'Стала столицей в 1997 году'],
    funFactsKz: ['Бәйтерек - биіктігі 97 метр қала символы', 'Хан Шатыр - әлемдегі ең үлкен шатыр', '1997 жылы астана болды'],
    infoRu: 'Астана - столица Казахстана с 1997 года. Здесь находятся знаменитый Байтерек, огромный торговый центр Хан Шатыр в форме шатра и красивая мечеть Хазрет Султан. Город очень современный с необычной архитектурой.',
    infoKz: 'Астана - 1997 жылдан бері Қазақстанның астанасы. Мұнда атақты Бәйтерек, шатыр тәрізді Хан Шатыр және Хазірет Сұлтан мешіті орналасқан. Қала өте заманауи сәулетімен ерекшеленеді.',
    aiPromptRu: 'Расскажи ребенку 6-10 лет интересные факты про Астану. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Астана туралы қызықты фактілер айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'almaty', nameRu: 'Алматы', nameKz: 'Алматы',
    descRu: 'Южная столица, город яблок', descKz: 'Оңтүстік астана, алма қаласы',
    categoryRu: 'Город', categoryKz: 'Қала',
    icon: Icons.park_rounded, color: Color(0xFF27AE60),
    lat: 43.2380, lng: 76.9450, population: '2.2 млн', yearFounded: '1854',
    funFactsRu: ['Медеу - самый высокогорный каток в мире', 'Кок-Тобе - гора с канатной дорогой', 'Название означает "отец яблок"'],
    funFactsKz: ['Медеу - әлемдегі ең биік тау мұз айдыны', 'Көк-Төбе - арқан жолы бар тау', 'Аты "алмалы" дегенді білдіреді'],
    infoRu: 'Алматы - самый большой город Казахстана у подножия гор Заилийского Алатау. Здесь находится высокогорный каток Медеу на высоте 1691 метр, горнолыжный курорт Шымбулак и канатная дорога на Кок-Тобе.',
    infoKz: 'Алматы - Іле Алатауы тау етегіндегі Қазақстанның ең үлкен қаласы. Мұнда 1691 метр биіктіктегі Медеу мұз айдыны, Шымбұлақ тау шаңғысы курорты және Көк-Төбеге арқан жолы бар.',
    aiPromptRu: 'Расскажи ребенку про Алматы. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Алматы туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'shymkent', nameRu: 'Шымкент', nameKz: 'Шымкент',
    descRu: 'Третий город Казахстана', descKz: 'Қазақстанның үшінші қаласы',
    categoryRu: 'Город', categoryKz: 'Қала',
    icon: Icons.wb_sunny_rounded, color: Color(0xFFF39C12),
    lat: 42.3417, lng: 69.5969, population: '1.1 млн', yearFounded: '12 век',
    funFactsRu: ['Один из самых солнечных городов', 'Возраст более 2000 лет', 'Знаменит своими базарами'],
    funFactsKz: ['Ең күнді қалалардың бірі', 'Жасы 2000 жылдан асады', 'Базарларымен атақты'],
    infoRu: 'Шымкент - один из древнейших городов Казахстана с 2000-летней историей. Это третий по величине город страны, знаменитый солнечной погодой, восточными базарами и гостеприимством жителей.',
    infoKz: 'Шымкент - 2000 жылдық тарихы бар Қазақстанның ең көне қалаларының бірі. Бұл елдің үшінші үлкен қаласы, күнді ауа райы, шығыс базарлары мен тұрғындардың қонақжайлылығымен атақты.',
    aiPromptRu: 'Расскажи ребенку про Шымкент. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Шымкент туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'turkestan', nameRu: 'Туркестан', nameKz: 'Түркістан',
    descRu: 'Древний город, мавзолей Яссауи', descKz: 'Ежелгі қала, Яссауи кесенесі',
    categoryRu: 'История', categoryKz: 'Тарих',
    icon: Icons.mosque_rounded, color: Color(0xFFE67E22),
    lat: 43.3017, lng: 68.2556, zoom: 13,
    yearFounded: '500 г. н.э.',
    funFactsRu: ['Мавзолей Яссауи - объект ЮНЕСКО', 'Городу более 1500 лет', 'Духовная столица тюркского мира'],
    funFactsKz: ['Яссауи кесенесі - ЮНЕСКО нысаны', 'Қалаға 1500 жылдан асады', 'Түркі әлемінің рухани астанасы'],
    infoRu: 'Туркестан - древний город возрастом более 1500 лет. Главная достопримечательность - мавзолей Ходжи Ахмеда Яссауи, построенный по приказу Тамерлана. Это объект Всемирного наследия ЮНЕСКО.',
    infoKz: 'Түркістан - жасы 1500 жылдан асатын ежелгі қала. Басты көрнекті жері - Темірлан бұйрығымен салынған Қожа Ахмет Яссауи кесенесі. Бұл ЮНЕСКО Дүниежүзілік мұра нысаны.',
    aiPromptRu: 'Расскажи ребенку про Туркестан. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Түркістан туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'baikonur', nameRu: 'Байконур', nameKz: 'Байқоңыр',
    descRu: 'Космодром - дорога в космос', descKz: 'Ғарыш айлағы - ғарышқа жол',
    categoryRu: 'Космос', categoryKz: 'Ғарыш',
    icon: Icons.rocket_launch_rounded, color: Color(0xFF9B59B6),
    lat: 45.9646, lng: 63.3052, zoom: 10,
    yearFounded: '1955',
    funFactsRu: ['Юрий Гагарин полетел отсюда в космос', 'Первый и крупнейший космодром мира', 'Более 1500 запусков ракет'],
    funFactsKz: ['Юрий Гагарин осы жерден ғарышқа ұшты', 'Әлемдегі бірінші және ең үлкен ғарыш айлағы', '1500-ден астам зымыран ұшырылды'],
    infoRu: 'Байконур - первый и крупнейший космодром в мире. Именно отсюда 12 апреля 1961 года Юрий Гагарин стал первым человеком в космосе. Здесь запускают ракеты и космические корабли.',
    infoKz: 'Байқоңыр - әлемдегі бірінші және ең үлкен ғарыш айлағы. 1961 жылы 12 сәуірде Юрий Гагарин осы жерден ғарышқа ұшып, ғарыштағы тұңғыш адам болды.',
    aiPromptRu: 'Расскажи ребенку про космодром Байконур. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Байқоңыр ғарыш айлағы туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'charyn', nameRu: 'Чарынский каньон', nameKz: 'Шарын шатқалы',
    descRu: 'Каньон возрастом 12 млн лет', descKz: '12 миллион жасты шатқал',
    categoryRu: 'Природа', categoryKz: 'Табиғат',
    icon: Icons.terrain_rounded, color: Color(0xFFE74C3C),
    lat: 43.3509, lng: 78.9822, zoom: 12,
    funFactsRu: ['Возраст 12 миллионов лет', 'Длина 154 километра', 'Называют "младшим братом Гранд-Каньона"'],
    funFactsKz: ['Жасы 12 миллион жыл', 'Ұзындығы 154 километр', '"Гранд-Каньонның кіші бауыры" деп атайды'],
    infoRu: 'Чарынский каньон - удивительное творение природы возрастом 12 миллионов лет. Его длина 154 км, а глубина до 300 метров. Самая красивая часть - "Долина замков" с причудливыми скалами.',
    infoKz: 'Шарын шатқалы - жасы 12 миллион жыл табиғаттың таңғажайып туындысы. Ұзындығы 154 км, тереңдігі 300 метрге дейін. Ең әдемі бөлігі - ғажайып жартастары бар "Сарайлар аңғары".',
    aiPromptRu: 'Расскажи ребенку про Чарынский каньон. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Шарын шатқалы туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'caspian', nameRu: 'Каспийское море', nameKz: 'Каспий теңізі',
    descRu: 'Самое большое озеро в мире', descKz: 'Әлемдегі ең үлкен көл',
    categoryRu: 'Природа', categoryKz: 'Табиғат',
    icon: Icons.water_rounded, color: Color(0xFF1ABC9C),
    lat: 42.0, lng: 51.5, zoom: 7,
    funFactsRu: ['На самом деле это озеро, а не море', 'Здесь живут каспийские тюлени', 'Площадь 371 000 кв.км'],
    funFactsKz: ['Шынында бұл теңіз емес, көл', 'Мұнда каспий тюлеңдері тұрады', 'Ауданы 371 000 шаршы км'],
    infoRu: 'Каспийское море - самое большое озеро в мире. Хотя его называют морем, на самом деле это гигантское озеро. Здесь живут каспийские тюлени и водится осетровая рыба, из которой делают чёрную икру.',
    infoKz: 'Каспий теңізі - әлемдегі ең үлкен көл. Оны теңіз десе де, шынында бұл алып көл. Мұнда каспий тюлеңдері мен қара уылдырық жасалатын бекіре балығы мекендейді.',
    aiPromptRu: 'Расскажи ребенку про Каспийское море. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Каспий теңізі туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'burabay', nameRu: 'Бурабай', nameKz: 'Бурабай',
    descRu: 'Казахстанская Швейцария', descKz: 'Қазақстандық Швейцария',
    categoryRu: 'Природа', categoryKz: 'Табиғат',
    icon: Icons.forest_rounded, color: Color(0xFF2ECC71),
    lat: 52.9833, lng: 70.3167, zoom: 11,
    funFactsRu: ['Называют "Казахстанской Швейцарией"', '14 красивейших озёр', 'Скала Жумбактас похожа на Сфинкса'],
    funFactsKz: ['"Қазақстандық Швейцария" деп аталады', '14 әдемі көл бар', 'Жұмбақтас жартасы Сфинксқа ұқсайды'],
    infoRu: 'Бурабай (Боровое) - курортная зона в сосновом бору с кристально чистыми озёрами. Скала Жумбактас, напоминающая сфинкса, и голубые озёра делают это место волшебным.',
    infoKz: 'Бурабай - қарағай орманындағы мөлдір көлдері бар курорттық аймақ. Сфинксқа ұқсайтын Жұмбақтас жартасы мен көгілдір көлдер бұл жерді ғажайып етеді.',
    aiPromptRu: 'Расскажи ребенку про Бурабай. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Бурабай туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'balkhash', nameRu: 'Озеро Балхаш', nameKz: 'Балқаш көлі',
    descRu: 'Полупресное-полусолёное озеро', descKz: 'Жартылай тұщы-жартылай тұзды көл',
    categoryRu: 'Природа', categoryKz: 'Табиғат',
    icon: Icons.water_drop_rounded, color: Color(0xFF2980B9),
    lat: 46.8, lng: 74.9, zoom: 8,
    funFactsRu: ['Одна половина пресная, другая солёная!', 'Длина 614 км - как от Алматы до Астаны', '13-е по величине озеро мира'],
    funFactsKz: ['Бір жартысы тұщы, екіншісі тұзды!', 'Ұзындығы 614 км', 'Әлемдегі 13-ші үлкен көл'],
    infoRu: 'Озеро Балхаш - уникальное озеро, у которого одна половина пресная, а другая солёная! Это 13-е по величине озеро мира длиной 614 километров.',
    infoKz: 'Балқаш көлі - бір жартысы тұщы, екінші жартысы тұзды бірегей көл! Бұл ұзындығы 614 км әлемдегі 13-ші үлкен көл.',
    aiPromptRu: 'Расскажи ребенку про озеро Балхаш. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Балқаш көлі туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'altai', nameRu: 'Алтайские горы', nameKz: 'Алтай таулары',
    descRu: 'Золотые горы востока', descKz: 'Шығыстың алтын таулары',
    categoryRu: 'Природа', categoryKz: 'Табиғат',
    icon: Icons.landscape_rounded, color: Color(0xFF34495E),
    lat: 48.8, lng: 86.5, zoom: 9,
    funFactsRu: ['Алтай означает "золотые горы"', 'Здесь живут снежные барсы', 'Объект ЮНЕСКО'],
    funFactsKz: ['Алтай "алтын таулар" дегенді білдіреді', 'Мұнда барыстар мекендейді', 'ЮНЕСКО нысаны'],
    infoRu: 'Алтайские горы - величественные горы на востоке Казахстана. Название "Алтай" означает "золотые горы". Здесь живут редкие снежные барсы, маралы и орлы.',
    infoKz: 'Алтай таулары - Қазақстанның шығысындағы сұлу таулар. "Алтай" - "алтын таулар" дегенді білдіреді. Мұнда сирек кездесетін барыстар, бұғылар мен бүркіттер мекендейді.',
    aiPromptRu: 'Расскажи ребенку про Алтайские горы. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Алтай таулары туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'aral', nameRu: 'Аральское море', nameKz: 'Арал теңізі',
    descRu: 'История об экологии', descKz: 'Экология тарихы',
    categoryRu: 'Экология', categoryKz: 'Экология',
    icon: Icons.eco_rounded, color: Color(0xFF16A085),
    lat: 45.0, lng: 59.5, zoom: 8,
    funFactsRu: ['Было 4-м по величине озером мира', 'Высохло из-за забора воды', 'Сейчас активно восстанавливается!'],
    funFactsKz: ['Әлемдегі 4-ші үлкен көл болған', 'Су алу салдарынан құрғады', 'Қазір белсенді қалпына келтірілуде!'],
    infoRu: 'Аральское море когда-то было 4-м крупнейшим озером мира. Оно начало высыхать, когда реки стали забирать для полива хлопка. Но люди учатся на ошибках - сейчас северная часть Арала восстанавливается!',
    infoKz: 'Арал теңізі бір кезде әлемдегі 4-ші үлкен көл болған. Мақта суаруға өзен суын алғанда құрғай бастады. Бірақ адамдар қателіктен сабақ алады - қазір Аралдың солтүстік бөлігі қалпына келуде!',
    aiPromptRu: 'Расскажи ребенку про Аральское море. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Арал теңізі туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'mangistau', nameRu: 'Мангистау', nameKz: 'Маңғыстау',
    descRu: 'Марсианские пейзажи Казахстана', descKz: 'Қазақстанның Марс пейзаждары',
    categoryRu: 'Природа', categoryKz: 'Табиғат',
    icon: Icons.auto_awesome_rounded, color: Color(0xFFD35400),
    lat: 43.35, lng: 51.85, zoom: 9,
    funFactsRu: ['Пейзажи похожи на Марс!', 'Впадина Карагие - 132 м ниже уровня моря', 'Тысячи лет назад здесь было море'],
    funFactsKz: ['Пейзаждары Марсқа ұқсайды!', 'Қарағие ойпаты - теңіз деңгейінен 132 м төмен', 'Мың жыл бұрын мұнда теңіз болған'],
    infoRu: 'Мангистау - удивительный край на западе Казахстана с ландшафтами, похожими на другие планеты. Здесь есть каменные шары, подземные мечети и впадина Карагие - одна из самых низких точек на Земле.',
    infoKz: 'Маңғыстау - басқа ғаламшарларға ұқсас пейзаждары бар Қазақстанның батысындағы ғажайып өлке. Мұнда тас шарлар, жер асты мешіттері мен Жер бетіндегі ең төменгі нүктелердің бірі Қарағие ойпаты бар.',
    aiPromptRu: 'Расскажи ребенку про Мангистау. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Маңғыстау туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'taraz', nameRu: 'Тараз', nameKz: 'Тараз',
    descRu: 'Город 2000-летней истории', descKz: '2000 жылдық тарихы бар қала',
    categoryRu: 'История', categoryKz: 'Тарих',
    icon: Icons.account_balance_rounded, color: Color(0xFF8E44AD),
    lat: 42.9000, lng: 71.3667, zoom: 12,
    yearFounded: '1 век до н.э.',
    funFactsRu: ['Один из древнейших городов Великого Шёлкового пути', 'Возраст более 2000 лет', 'Мавзолеи Айша-Биби и Карахана'],
    funFactsKz: ['Ұлы Жібек жолының ең көне қалаларының бірі', 'Жасы 2000 жылдан асады', 'Айша-Бибі мен Қарахан кесенелері'],
    infoRu: 'Тараз - один из древнейших городов Великого Шёлкового пути. Ему более 2000 лет. Здесь сохранились древние мавзолеи Айша-Биби и Карахана - памятники средневекового зодчества.',
    infoKz: 'Тараз - Ұлы Жібек жолының ең көне қалаларының бірі. Оған 2000 жылдан асады. Мұнда ежелгі Айша-Бибі мен Қарахан кесенелері - ортағасырлық сәулет ескерткіштері сақталған.',
    aiPromptRu: 'Расскажи ребенку про Тараз. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Тараз туралы айтып бер. Максимум 4 сөйлем.',
  ),
  _KzPlace(
    id: 'aktau', nameRu: 'Актау', nameKz: 'Ақтау',
    descRu: 'Город у Каспийского моря', descKz: 'Каспий теңізі жағасындағы қала',
    categoryRu: 'Город', categoryKz: 'Қала',
    icon: Icons.beach_access_rounded, color: Color(0xFF0984E3),
    lat: 43.6500, lng: 51.1500, zoom: 12,
    population: '300 тыс', yearFounded: '1961',
    funFactsRu: ['Улицы имеют номера вместо названий', 'Вода в городе опреснённая из моря', 'Стоит на белых скалах'],
    funFactsKz: ['Көшелердің аттары емес, нөмірлері бар', 'Қаладағы су теңізден тұщыландырылған', 'Ақ жартастарда тұр'],
    infoRu: 'Актау - единственный крупный город Казахстана на берегу Каспия. Уникально то, что улицы здесь не имеют названий, а обозначены номерами. Город стоит на белых скалах.',
    infoKz: 'Ақтау - Каспий жағасындағы Қазақстанның жалғыз ірі қаласы. Ерекшелігі - көшелердің аттары жоқ, нөмірлермен белгіленген. Қала ақ жартастар үстінде тұр.',
    aiPromptRu: 'Расскажи ребенку про Актау. Максимум 4 предложения.',
    aiPromptKz: 'Балаға Ақтау туралы айтып бер. Максимум 4 сөйлем.',
  ),
];

class ExploreKzScreen extends StatefulWidget {
  const ExploreKzScreen({super.key});
  @override
  State<ExploreKzScreen> createState() => _ExploreKzScreenState();
}

class _ExploreKzScreenState extends State<ExploreKzScreen> with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  late WebViewController _webCtrl;
  bool _mapLoaded = false;
  _KzPlace? _selectedPlace;
  String? _aiText;
  bool _isLoadingAi = false;
  late AnimationController _panelCtrl;
  late Animation<double> _panelAnim;

  String _buildMapHtml(double lat, double lng, int zoom) {
    return '''<!DOCTYPE html><html><head>
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
<style>*{margin:0;padding:0}html,body{width:100%;height:100%;overflow:hidden}
iframe{width:100%;height:100%;border:0}</style></head>
<body><iframe id="map" src="https://maps.google.com/maps?q=$lat,$lng&z=$zoom&output=embed&t=k" allowfullscreen loading="lazy"></iframe>
<script>function go(lat,lng,z){document.getElementById('map').src='https://maps.google.com/maps?q='+lat+','+lng+'&z='+z+'&output=embed&t=k';}</script>
</body></html>''';
  }

  @override
  void initState() {
    super.initState();
    _panelCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _panelAnim = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic);

    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) { if (mounted) setState(() => _mapLoaded = true); },
      ))
      ..loadHtmlString(_buildMapHtml(48.0196, 66.9237, 5));

    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ru-RU');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.15);
    _tts.setCompletionHandler(() { if (mounted) setState(() => _isSpeaking = false); });
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onPlaceTap(_KzPlace place) async {
    await _tts.stop();
    setState(() { _selectedPlace = place; _aiText = null; _isSpeaking = false; _isLoadingAi = false; });
    _panelCtrl.forward(from: 0);
    _webCtrl.runJavaScript('go(${place.lat},${place.lng},${place.zoom})');
  }

  void _closePanel() {
    _panelCtrl.reverse();
    _tts.stop();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() { _selectedPlace = null; _aiText = null; _isSpeaking = false; });
    });
  }

  Future<void> _askAi() async {
    if (_selectedPlace == null) return;
    final p = context.read<GameProvider>();
    setState(() { _isLoadingAi = true; _aiText = null; });
    await _tts.stop();
    setState(() => _isSpeaking = false);
    final prompt = p.isRussian ? _selectedPlace!.aiPromptRu : _selectedPlace!.aiPromptKz;
    final response = await AiService.sendMessage(prompt, []);
    if (!mounted) return;
    setState(() { _aiText = response; _isLoadingAi = false; });
    _speak(response, p.isRussian);
  }

  Future<void> _speak(String text, bool isRussian) async {
    setState(() => _isSpeaking = true);
    final apiKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      // Preferred path: live multilingual ElevenLabs voice.
      await VoiceService.speak(text);
    } else {
      // Safety net: robotic flutter_tts when no key is configured.
      await _tts.setLanguage(isRussian ? 'ru-RU' : 'kk-KZ');
      await _tts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _webCtrl)),
          if (!_mapLoaded) Positioned.fill(
            child: Container(
              color: const Color(0xFFF0F4FF),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(p.t('Карта жүктелуде...', 'Загрузка карты...'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ])),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: _buildTopBar(p))),
          Positioned(left: 0, right: 0, bottom: 0, child: SafeArea(child: _buildPlaceCarousel(p))),
          if (_selectedPlace != null) _buildInfoPanel(p),
        ],
      ),
    );
  }

  Widget _buildTopBar(GameProvider p) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.primary),
        ),
      ),
      const SizedBox(width: 12),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(
        p.t('Қазақстанды зерттеу', 'Исследуй Казахстан'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      )),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.accentGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.place_rounded, size: 14, color: AppColors.accentGreen),
          const SizedBox(width: 4),
          Text('${_places.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.accentGreen)),
        ]),
      ),
    ]),
  );

  Widget _buildPlaceCarousel(GameProvider p) => Container(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.3)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    ),
    child: SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _places.length,
        itemBuilder: (_, i) {
          final place = _places[i];
          final isSelected = _selectedPlace?.id == place.id;
          return GestureDetector(
            onTap: () => _onPlaceTap(place),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 90, margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? place.color : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? place.color : Colors.white.withValues(alpha: 0.4), width: 2),
                boxShadow: [BoxShadow(color: (isSelected ? place.color : Colors.black).withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.25) : place.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(place.icon, color: isSelected ? Colors.white : place.color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  p.isRussian ? place.nameRu : place.nameKz,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
                  textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildInfoPanel(GameProvider p) {
    final place = _selectedPlace!;
    final isRu = p.isRussian;
    return AnimatedBuilder(
      animation: _panelAnim,
      builder: (_, child) => Positioned(
        bottom: 120 + ((1 - _panelAnim.value) * 500),
        left: 12, right: 12,
        child: Opacity(opacity: _panelAnim.value.clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: place.color.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(color: place.color.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: place.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                child: Icon(place.icon, color: place.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: place.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(isRu ? place.categoryRu : place.categoryKz, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: place.color)),
                  ),
                  if (place.population != null) ...[
                    const SizedBox(width: 8),
                    Text('👥 ${place.population}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(isRu ? place.nameRu : place.nameKz, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                Text(isRu ? place.descRu : place.descKz, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ])),
              GestureDetector(
                onTap: _closePanel,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Container(height: 1.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [place.color.withValues(alpha: 0.3), place.color.withValues(alpha: 0.05)]))),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(16)),
              child: Text(isRu ? place.infoRu : place.infoKz, style: const TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 14),
            Text(isRu ? '✨ Интересные факты:' : '✨ Қызықты фактілер:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: place.color)),
            const SizedBox(height: 8),
            ...(isRu ? place.funFactsRu : place.funFactsKz).map((fact) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.star_rounded, size: 16, color: place.color.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Expanded(child: Text(fact, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
              ]),
            )),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () {
                  if (_isSpeaking) { _tts.stop(); VoiceService.stop(); setState(() => _isSpeaking = false); }
                  else { _speak(isRu ? place.infoRu : place.infoKz, isRu); }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: _isSpeaking
                      ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)])
                      : LinearGradient(colors: [place.color, place.color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(_isSpeaking ? (isRu ? 'Стоп' : 'Тоқтату') : (isRu ? 'Послушать' : 'Тыңдау'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: _isLoadingAi ? null : _askAi,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _isLoadingAi
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : ClipOval(child: Image.asset('assets/cumbot/glad.png', width: 20, height: 20, fit: BoxFit.cover)),
                    const SizedBox(width: 6),
                    Text(isRu ? 'Спроси Боту' : 'Ботадан сұра',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              )),
            ]),
            if (_aiText != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/cumbot/glad.png', fit: BoxFit.cover)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_aiText!, style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                ]),
              ),
            ],
            if (place.yearFounded != null) ...[
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: place.color),
                const SizedBox(width: 6),
                Text('${isRu ? "Основан: " : "Құрылған: "}${place.yearFounded}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: place.color)),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}
