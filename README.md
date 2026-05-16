# Bayan Sulu Kids

Bayan Sulu Kids is an interactive, educational mobile game for children, themed around the Bayan Sulu confectionery brand and Kazakh culture. The adventure features KamBot, a friendly camel who guides children through various mini-games spanning across Kazakhstan's iconic locations.

## Features

- **Interactive Map:** Explore various regions representing different mini-games (Astana, Almaty, Charyn Canyon, Turkestan, Aktau).
- **Mini-Games:**
  - **Memory:** Match adorable Bayan Sulu candy pairs.
  - **Catch:** Catch descending candies while avoiding obstacles to earn points.
  - **Puzzle:** Assemble images of delicious sweets.
  - **Math:** Solve basic arithmetic queries using candies as visual aids.
  - **Words:** Guess the corresponding image to the given Kazakh word.
  - **Quest:** A text-based adventure with choices in Charyn Canyon.
- **Botakoins System:** Earn virtual currency (Botakoins) by playing games and completing daily streaks.
- **Shop:** Spend Botakoins on virtual items like stickers, soft toys, and VIP status.
- **Parental Controls:** A secure section (default PIN: 1234) allowing parents to monitor screen time, review game statistics (games played, correct answers, achievements unlocked), and set daily time limits.
- **Bilingual Support:** Full game localization in Kazakh and Russian languages.
- **Daily Rewards:** Login daily to open chests and receive Botakoins to encourage retention.

## Architecture - Supabase Backend

The application uses **Supabase** as a scalable backend:

### Database Tables
| Table | Description |
|-------|-------------|
| `words` | Kazakh word game data (kz, ru, image_path) |
| `quiz_questions` | Quiz questions with answers (JSONB), correct index, facts |
| `shop_items` | Store items with prices and image paths |
| `candy_images` | Candy and obstacle image paths with categories |
| `quest_scenes` | Quest adventure scenes with choices (JSONB) |
| `user_profiles` | User progress synced from device |

### Storage (MyBucket)
All game assets are stored in Supabase Storage:
- `candies/` - 12 candy images
- `catchgame/` - obstacle images (pepper, stone, bomb)
- `coin/` - botakoin image
- `cumbot/` - mascot images
- `quiz/` - baiterek image
- `store/` - shop item images
- `words/` - word game images

### Supabase Configuration
- **URL:** `https://nuacawcczjetqwgazemt.supabase.co`
- **Dashboard:** `https://supabase.com/dashboard/project/nuacawcczjetqwgazemt`

## Build Requirements

- Flutter SDK (`^3.11.3`)
- Dart SDK
- Android SDK (for Android compilation)

Dependencies:
- `supabase_flutter` - Backend integration (database, storage, auth)
- `provider` - State management
- `shared_preferences` - Local storage and caching
- `google_fonts` - Custom typography (Nunito)

## How to Build Release APK

1. Clone the repository.
2. Navigate to the project directory:
   ```bash
   cd my_app
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Build the release APK:
   ```bash
   flutter build apk --release
   ```
5. Output APK: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
  main.dart                    - App initialization + Supabase setup
  services/
    supabase_service.dart      - Supabase client, data fetching, caching
  providers/
    game_provider.dart         - State management + cloud sync
  models/
    child_profile.dart         - User profile model
    map_location.dart          - Map location data
  screens/                     - All game and UI screens
  widgets/
    game_widgets.dart          - Reusable UI components
  theme/
    app_colors.dart            - Color palette
assets/                        - Local copies of game images
scripts/                       - Database setup and migration scripts
```

## Managing Content

All game content (words, quiz questions, shop items, quest scenes) is managed through the Supabase Dashboard. To update content:

1. Go to **Table Editor** in the Supabase Dashboard
2. Select the table you want to update
3. Add/edit/delete rows directly
4. Changes appear in the app after cache refresh

To add new images:
1. Go to **Storage** > **MyBucket** in the Dashboard
2. Upload images to the appropriate folder
3. Update the corresponding table with the new `image_path`

## Hackathon Notice
This project is prepared for the **Bayan Sulu Hackathon 2026**.
