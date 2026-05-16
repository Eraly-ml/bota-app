#!/bin/bash
set -e

SUPABASE_URL="https://nuacawcczjetqwgazemt.supabase.co"
SERVICE_KEY="YOUR_SUPABASE_SERVICE_KEY"
BUCKET="MyBucket"
ASSETS_DIR="/home/alikhan/bota/my_app/assets"

echo "=== Uploading assets to Supabase Storage ==="

upload_file() {
  local file_path="$1"
  local storage_path="$2"
  local content_type="$3"
  
  echo "  Uploading: $storage_path"
  curl -s -X POST \
    "$SUPABASE_URL/storage/v1/object/$BUCKET/$storage_path" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    -H "Content-Type: $content_type" \
    -H "x-upsert: true" \
    --data-binary "@$file_path" \
    -o /dev/null -w "%{http_code}"
  echo ""
}

for f in "$ASSETS_DIR"/candies/*.jpeg; do
  fname=$(basename "$f")
  upload_file "$f" "candies/$fname" "image/jpeg"
done

for f in "$ASSETS_DIR"/catchgame/*.png; do
  fname=$(basename "$f")
  upload_file "$f" "catchgame/$fname" "image/png"
done

for f in "$ASSETS_DIR"/coin/*.jpeg; do
  fname=$(basename "$f")
  upload_file "$f" "coin/$fname" "image/jpeg"
done

for f in "$ASSETS_DIR"/cumbot/*.png; do
  fname=$(basename "$f")
  upload_file "$f" "cumbot/$fname" "image/png"
done

for f in "$ASSETS_DIR"/quiz/*.png; do
  fname=$(basename "$f")
  upload_file "$f" "quiz/$fname" "image/png"
done

for f in "$ASSETS_DIR"/store/*.png; do
  fname=$(basename "$f")
  upload_file "$f" "store/$fname" "image/png"
done

for f in "$ASSETS_DIR"/words/*.jpeg; do
  fname=$(basename "$f")
  upload_file "$f" "words/$fname" "image/jpeg"
done

echo ""
echo "=== All assets uploaded! ==="
echo ""
echo "=== Creating database tables ==="

SQL=$(cat <<'EOSQL'
DROP TABLE IF EXISTS words CASCADE;
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS shop_items CASCADE;
DROP TABLE IF EXISTS candy_images CASCADE;
DROP TABLE IF EXISTS quest_scenes CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;

CREATE TABLE words (
  id SERIAL PRIMARY KEY,
  kz TEXT NOT NULL,
  ru TEXT NOT NULL,
  image_path TEXT NOT NULL
);

CREATE TABLE quiz_questions (
  id SERIAL PRIMARY KEY,
  question_kz TEXT NOT NULL,
  question_ru TEXT NOT NULL,
  answers JSONB NOT NULL,
  correct_index INT NOT NULL DEFAULT 0,
  fact TEXT
);

CREATE TABLE shop_items (
  id SERIAL PRIMARY KEY,
  name_kz TEXT NOT NULL,
  name_ru TEXT NOT NULL,
  image_path TEXT NOT NULL,
  price INT NOT NULL,
  description TEXT
);

CREATE TABLE candy_images (
  id SERIAL PRIMARY KEY,
  image_path TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'candy'
);

CREATE TABLE quest_scenes (
  id SERIAL PRIMARY KEY,
  scene_order INT NOT NULL,
  title_kz TEXT NOT NULL,
  title_ru TEXT NOT NULL,
  text_kz TEXT NOT NULL,
  text_ru TEXT NOT NULL,
  choices JSONB NOT NULL,
  bg_colors JSONB NOT NULL
);

CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT UNIQUE NOT NULL,
  name TEXT DEFAULT '',
  age INT DEFAULT 7,
  botakoins INT DEFAULT 0,
  total_games_played INT DEFAULT 0,
  total_correct_answers INT DEFAULT 0,
  achievements JSONB DEFAULT '[]'::jsonb,
  unlocked_locations JSONB DEFAULT '["almaty"]'::jsonb,
  screen_time_limit INT DEFAULT 30,
  game_best_scores JSONB DEFAULT '{}'::jsonb,
  daily_minutes_used INT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE words ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE candy_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE quest_scenes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read words" ON words FOR SELECT USING (true);
CREATE POLICY "Public read quiz" ON quiz_questions FOR SELECT USING (true);
CREATE POLICY "Public read shop" ON shop_items FOR SELECT USING (true);
CREATE POLICY "Public read candies" ON candy_images FOR SELECT USING (true);
CREATE POLICY "Public read quests" ON quest_scenes FOR SELECT USING (true);
CREATE POLICY "Users manage own profile" ON user_profiles FOR ALL USING (true);

INSERT INTO words (kz, ru, image_path) VALUES
  ('Алма', 'Яблоко', 'words/apple.jpeg'),
  ('Жылқы', 'Лошадь', 'words/horse.jpeg'),
  ('Күн', 'Солнце', 'words/sun.jpeg'),
  ('Тау', 'Гора', 'words/mountains.jpeg'),
  ('Су', 'Вода', 'words/water.jpeg'),
  ('Ай', 'Луна', 'words/moon.jpeg'),
  ('Бүркіт', 'Орёл', 'words/eagle.jpeg'),
  ('Түйе', 'Верблюд', 'words/camel.jpeg'),
  ('Қой', 'Овца', 'words/sheep.jpeg'),
  ('Гүл', 'Цветок', 'words/flower.jpeg'),
  ('Аю', 'Медведь', 'words/bear.jpeg'),
  ('Жұлдыз', 'Звезда', 'words/star.jpeg');

INSERT INTO quiz_questions (question_kz, question_ru, answers, correct_index, fact) VALUES
  ('Қазақстанның астанасы қай қала?', 'Какой город является столицей Казахстана?', '["Астана","Алматы","Шымкент","Караганда"]', 0, 'Астана стала столицей в 1997 году!'),
  ('Қазақстандағы ең биік тау?', 'Самая высокая гора Казахстана?', '["Хан-Тенгри","Белуха","Эльбрус","Монблан"]', 0, 'Хан-Тенгри - 6995 метров!'),
  ('Қазақстан жалауының түсі?', 'Какого цвета флаг Казахстана?', '["Голубой","Зелёный","Красный","Белый"]', 0, 'Голубой цвет символизирует мир и единство!'),
  ('Қазақстанда қандай жануар ұлттық символ?', 'Какое животное - национальный символ Казахстана?', '["Барс","Тигр","Медведь","Волк"]', 0, 'Снежный барс - ирбис - символ силы и гордости!'),
  ('Байтерек ескерткіші қай қалада?', 'В каком городе монумент Байтерек?', '["Астана","Алматы","Атырау","Актау"]', 0, 'Высота Байтерека - 97 метров!'),
  ('Қазақстандағы ең үлкен көл?', 'Самое большое озеро Казахстана?', '["Балхаш","Алаколь","Боровое","Иссык"]', 0, 'Балхаш уникален: одна половина пресная, другая солёная!'),
  ('Қазақтың ұлттық спорт ойыны?', 'Национальный вид спорта казахов?', '["Кокпар","Футбол","Хоккей","Теннис"]', 0, 'Кокпар - конная игра, которой более 1000 лет!'),
  ('Қожа Ахмет Яссауи кесенесі қай қалада?', 'Где находится мавзолей Ходжи Ахмеда Яссауи?', '["Туркестан","Шымкент","Тараз","Кызылорда"]', 0, 'Мавзолей построен по приказу Тамерлана в XIV веке!'),
  ('Баян Сулу фабрикасы қай қалада?', 'В каком городе фабрика Баян Сулу?', '["Костанай","Алматы","Астана","Караганда"]', 0, 'Баян Сулу - крупнейший производитель сладостей в Казахстане!'),
  ('Қазақстан қай құрлықта орналасқан?', 'На каком континенте расположен Казахстан?', '["Евразия","Европа","Азия","Африка"]', 0, 'Казахстан расположен и в Европе, и в Азии!'),
  ('Шарын шатқалын қалай атайды?', 'Как ещё называют Чарынский каньон?', '["Младший брат Гранд-Каньона","Золотой каньон","Великий каньон","Красный каньон"]', 0, 'Ему 12 миллионов лет!'),
  ('Қазақтың ұлттық ішімдігі?', 'Национальный напиток казахов?', '["Кумыс","Чай","Кофе","Айран"]', 0, 'Кумыс делают из кобыльего молока!');

INSERT INTO shop_items (name_kz, name_ru, image_path, price, description) VALUES
  ('Стикер-пак Бота', 'Стикер-пак Бота', 'store/stickers.png', 30, '5 стикеров'),
  ('Түсті жақтау', 'Цветная рамка', 'store/frame.png', 50, 'Для фото с Ботой'),
  ('10% жеңілдік', '10% скидка', 'store/discount.png', 100, 'На продукцию Бота'),
  ('Бота ойыншық', 'Игрушка Бота', 'store/camel.png', 200, 'Мягкая игрушка'),
  ('Сыйлық жинағы', 'Подарочный набор', 'store/sweets.png', 500, 'Набор сладостей'),
  ('VIP Саяхатшы', 'VIP Путешественник', 'store/crown.png', 1000, 'Эксклюзивный статус');

INSERT INTO candy_images (image_path, category) VALUES
  ('candies/candy0.jpeg', 'candy'),
  ('candies/candy1.jpeg', 'candy'),
  ('candies/candy2.jpeg', 'candy'),
  ('candies/candy3.jpeg', 'candy'),
  ('candies/candy4.jpeg', 'candy'),
  ('candies/candy5.jpeg', 'candy'),
  ('candies/candy6.jpeg', 'candy'),
  ('candies/candy7.jpeg', 'candy'),
  ('candies/candy8.jpeg', 'candy'),
  ('candies/candy10.jpeg', 'candy'),
  ('candies/candy20.jpeg', 'candy'),
  ('candies/candy21.jpeg', 'candy'),
  ('catchgame/pepper.png', 'obstacle'),
  ('catchgame/stone.png', 'obstacle'),
  ('catchgame/bomb.png', 'obstacle');

INSERT INTO quest_scenes (scene_order, title_kz, title_ru, text_kz, text_ru, choices, bg_colors) VALUES
  (1, 'Шарын шатқалы', 'Чарынский каньон',
   'КамБот Шарын шатқалына келді. Алдында екі жол бар. Қайсысын таңдайсың?',
   'КамБот пришёл к Чарынскому каньону. Впереди две дороги. Какую выберешь?',
   '[{"textKz":"Жасыл орман жолы","textRu":"Через зелёный лес","correct":true,"replyKz":"Жарайсың! Орманда сирек кездесетін ағаштар бар!","replyRu":"Молодец! В лесу растут редкие реликтовые деревья!"},{"textKz":"Құм жолы","textRu":"Через пустыню","correct":false,"replyKz":"Құмда ыстық! Бірақ КамБот шыдамды","replyRu":"В пустыне жарко! Но КамБот выносливый"}]',
   '["#1a1a2e","#16213e"]'),
  (2, 'Бүркіт кездесті!', 'Встреча с орлом!',
   'Жолда КамБот бүркіт кездестірді. Бүркіт: "Мен саған жол көрсетемін, бірақ алдымен сұраққа жауап бер!" Қазақтардың ұлттық құсы кім?',
   'На пути КамБот встретил орла-беркута. Орёл сказал: "Я покажу тебе дорогу, но сначала ответь! Какая птица - национальный символ казахов?"',
   '[{"textKz":"Бүркіт (Беркут)","textRu":"Беркут","correct":true,"replyKz":"Дұрыс! Бүркіт - қазақтардың құрметті құсы!","replyRu":"Верно! Беркут - символ свободы и гордости казахов!"},{"textKz":"Тоты құс","textRu":"Попугай","correct":false,"replyKz":"Жоқ, бірақ тоты құс та керемет!","replyRu":"Нет, но попугаи тоже классные!"}]',
   '["#0f3460","#533483"]'),
  (3, 'Тау шыңы', 'Горная вершина',
   'КамБот тау шыңына жетті! Алыстан Шарынның таңғажайып көрінісі. Бірақ тасты жол қиын. Не істейсің?',
   'КамБот добрался до вершины! Вдали видно весь каньон. Но каменистый путь труден. Что делаешь?',
   '[{"textKz":"Фото түсіру","textRu":"Сделать фото","correct":true,"replyKz":"Тамаша суретке түстің! Шарын 12 миллион жыл бұрын пайда болған!","replyRu":"Отличное фото! Чарынскому каньону 12 миллионов лет!"},{"textKz":"Тынығу","textRu":"Отдохнуть","correct":false,"replyKz":"Дұрыс, демалу да маңызды!","replyRu":"Правильно, отдых тоже важен!"}]',
   '["#533483","#e94560"]'),
  (4, 'Қазына!', 'Сокровище!',
   'КамБот үңгірде жасырылған қазына тапты! Ішінде Баян Сулу шоколадтары мен ботакоиндер! Саяхат аяқталды!',
   'КамБот нашёл спрятанное в пещере сокровище! Внутри шоколад Баян Сулу и ботакоины! Путешествие завершено!',
   '[{"textKz":"Ботакоиндерді жинау!","textRu":"Собрать ботакоины!","correct":true,"replyKz":"Сен батыл саяхатшысың, КамБот мақтаныш!","replyRu":"Ты настоящий путешественник, КамБот гордится!"},{"textKz":"Шоколадты алу!","textRu":"Взять шоколад!","correct":true,"replyKz":"Баян Сулу шоколады - ең дәмді!","replyRu":"Шоколад Баян Сулу - самый вкусный!"}]',
   '["#e94560","#FF8C00"]');
EOSQL
)

echo "Executing SQL via Supabase REST..."
RESULT=$(curl -s -X POST \
  "$SUPABASE_URL/rest/v1/rpc" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$SQL\"}" \
  -w "\n%{http_code}")

echo "REST RPC result: $RESULT"

echo ""
echo "=== Trying direct SQL endpoint ==="
RESULT2=$(curl -s -X POST \
  "$SUPABASE_URL/pg/query" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": $(echo "$SQL" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}" \
  -w "\n%{http_code}")

echo "PG query result: $RESULT2"

echo ""
echo "=== Done ==="
