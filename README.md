# FitLife Mini - Flutter Fitness Tracking Application

A mobile fitness tracking application designed for offline-first experience. The application allows users to monitor their daily workouts, calories burned, and set reminders for exercise sessions completely offline.

## Features

- 🏃 **Workout Tracking**: Log your workouts with type, duration, and calories burned
- 📊 **Statistics**: View daily calories burned and workout count
- ⏰ **Reminders**: Set exercise reminders with flexible scheduling
- 🌙 **Dark Mode**: Theme support with light and dark modes
- 📱 **Offline First**: All data stored locally, no internet required
- 👤 **User Authentication**: Support for registered users and guest access
- 💾 **Local Database**: SQLite for reliable offline data persistence


## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for emulator)

### Installation

1. Clone the repository:
```bash
cd fitlife_mini
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Dependencies

- **sqflite** (^2.3.0) - SQLite database
- **provider** (^6.0.0) - State management
- **shared_preferences** (^2.2.0) - User preferences
- **intl** (^0.19.0) - Internationalization
- **uuid** (^4.0.0) - Unique ID generation
- **charts_flutter** (^0.12.0) - Data visualization (optional)

## Screens & Navigation

### Splash Screen
- Logo display
- Loading animation
- 2-second delay before navigation

### Onboarding Flow
- 3 educational cards
- Progress indicators
- Skip and Next buttons

### Authentication
- **Login Screen**: Email and password login
- **Guest Login**: Limited access without data backup

### Dashboard
- Daily stats (calories, workouts)
- Quick actions
- Recent workouts list
- Weekly activity chart

### Workouts Management
- List all workouts
- Filter by type (Cardio, Strength, Yoga)
- Add/Edit workouts
- Delete workouts

### Reminders
- Create exercise reminders
- List active reminders
- Delete reminders
- Frequency options (Daily, Weekly, Custom)

### Settings
- Theme toggle (Light/Dark)
- User information
- Account type display
- Logout functionality

## Offline-First Architecture

All data is stored locally using SQLite. The application does not require internet connectivity for any core functionality:

- Workouts are persisted locally
- User data is stored on device
- Reminders are managed locally
- No API calls or network requests

## State Management

The application uses Provider for state management:

- **AuthProvider**: Manages user authentication and sessions
- **ThemeProvider**: Manages light/dark mode preference
- **WorkoutProvider**: Manages workout operations and statistics

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Create a feature branch
2. Commit changes
3. Push to branch
4. Create a pull request

## License

This project is licensed under the MIT License.

## Support

For issues or questions, please create an issue in the repository.
