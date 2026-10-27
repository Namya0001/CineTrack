# CineTrack 🎬

A modern, cinematic Movie Watchlist app built with Flutter and Dart. Discover movies, build your watchlist, track what you've watched, and rate your favorites — all with real data from [The Movie Database (TMDB)](https://www.themoviedb.org/).

---

## ✨ Features

| Feature | Details |
|---|---|
| 🏠 **Home Screen** | Featured movie, Popular, Top Rated, and Coming Soon sections |
| 🔍 **Search** | Debounced real-time search across the TMDB catalog |
| 🎬 **Movie Details** | Poster, backdrop, genres, runtime, synopsis, production info |
| 🔖 **Watchlist** | Add/remove movies, filter (All / To Watch / Watched), sort by title, date, or rating |
| ⭐ **Personal Ratings** | Rate any movie in your watchlist with a 0.5–5 star scale |
| 📊 **Profile & Stats** | Total, watched, and remaining movie counts, average personal rating |
| 🌙 **Dark/Light Mode** | Toggle from the Profile screen — dark mode is default |
| 💾 **Persistent Storage** | Watchlist survives app restarts using SharedPreferences |
| 🚀 **Caching** | API responses cached for 10 minutes to avoid redundant requests |

---

## 📁 Project Structure

```
lib/
├── main.dart                   # App entry point, theme, navigation shell
├── models/
│   └── movie.dart              # Movie & Genre data models
├── services/
│   ├── movie_api_service.dart  # TMDB API client with in-memory cache
│   └── storage_service.dart    # SharedPreferences wrapper
├── providers/
│   └── watchlist_provider.dart # State management (ChangeNotifier)
├── screens/
│   ├── home_screen.dart        # Home with featured & section carousels
│   ├── search_screen.dart      # Debounced search + grid results
│   ├── movie_details_screen.dart # Full detail view + ratings
│   ├── watchlist_screen.dart   # Filterable/sortable watchlist grid
│   └── profile_screen.dart     # Stats, theme toggle, API key settings
├── widgets/
│   ├── movie_card.dart         # Reusable card with poster + info + bookmark
│   ├── movie_grid.dart         # 2-column movie grid
│   ├── loading_indicator.dart  # Spinner + shimmer placeholders
│   └── empty_state.dart        # Empty/error state widget
└── theme/
    └── app_theme.dart          # Material 3 dark & light themes
```

---

## 🔑 TMDB API Key Setup

CineTrack requires a free TMDB API key to fetch real movie data.

### 1. Obtain an API key
1. Sign up at [themoviedb.org](https://www.themoviedb.org/signup)
2. Go to **Settings → API** and request a free API key (v3 auth)
3. Copy your **API Key (v3 auth)**

### 2. Configure the key (choose one method)

#### Method A — In-app (Recommended for development)
1. Run the app
2. Navigate to the **Profile** tab
3. Paste your key in the **TMDB API Key** field and tap **Save API Key**
4. The key is saved to device storage and persists across launches

#### Method B — Build-time (via `--dart-define`)
```bash
flutter run --dart-define=TMDB_API_KEY=your_api_key_here
```

> **Security note:** An API key embedded in a mobile app binary can be extracted by a determined user. For production deployments, route API calls through a backend proxy that holds the secret.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Android SDK / Xcode (for device/emulator)

### Install & Run

```bash
# 1. Navigate to the project folder
cd cinetrack

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# Or run with your API key inline (Method B)
flutter run --dart-define=TMDB_API_KEY=your_key_here
```

### Run Tests
```bash
flutter test
```

### Build a Release APK
```bash
flutter build apk --release
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `shared_preferences` | Local watchlist persistence |
| `http` | TMDB API requests |
| `cached_network_image` | Efficient image loading & caching |
| `flutter_rating_bar` | Star rating widget |
| `shimmer` | Skeleton loading animations |

---

## 🎨 Design

- **Theme:** Dark cinematic (charcoal `#0A0A0F` background, red `#E50914` accent)
- **UI:** Material 3 with rounded cards, smooth FadeTransition animations
- **Typography:** Clean Material text theme with high contrast on dark backgrounds
- **Images:** TMDB image CDN with graceful fallback placeholders

---

## 🧪 Testing

Tests live in `test/widget_test.dart` and cover:

- `Movie.fromJson` parsing (including missing/malformed fields)
- `Movie.toJson` to `Movie.fromStorageJson` round-trip
- `Movie.copyWith` field preservation
- Watchlist add, duplicate rejection, remove, and multi-movie scenarios
- `Genre` model serialization

---

## 🛣️ Roadmap

- [ ] Paginated loading (infinite scroll)
- [ ] Movie trailers via YouTube embed
- [ ] Cast & crew section
- [ ] Similar movie recommendations
- [ ] Offline-first mode with local SQLite cache
- [ ] Share watchlist with friends

---

Built with Flutter and TMDB API
