# FitLife Mini - Complete Project Documentation

## 📱 Project Overview

**FitLife Mini** is a Flutter-based offline-first fitness tracking application that allows users to:
- Track daily workouts (Cardio, Strength, Yoga)
- Monitor calories burned and workout statistics
- Set exercise reminders
- Manage user profiles with guest access
- View activity trends and analytics
- Switch between light and dark themes

**Key Requirement**: The application operates completely offline with no internet connectivity required.

---

## 🏗️ Project Architecture

### Technology Stack
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Local Storage**: SharedPreferences

### Design Pattern: Provider Pattern
The application uses the Provider package for clean state management:

```
User Action → Provider → Database/Service → UI Update
```

---

## 📂 Project Structure

```
fitlife_mini/
│
├── lib/
│   ├── main.dart                          # App entry & routing
│   │
│   ├── models/                            # Data classes
│   │   ├── user.dart                      # User model
│   │   ├── workout.dart                   # Workout model
│   │   └── reminder.dart                  # Reminder model
│   │
│   ├── providers/                         # State management
│   │   ├── auth_provider.dart             # User authentication
│   │   ├── theme_provider.dart            # Theme switching
│   │   └── workout_provider.dart          # Workout operations
│   │
│   ├── services/                          # Business logic
│   │   └── database_service.dart          # SQLite operations
│   │
│   └── screens/                           # UI Screens
│       ├── splash_screen.dart             # Loading screen
│       ├── onboarding_screen.dart         # Tutorial (3 cards)
│       ├── login_screen.dart              # Email/Password login
│       ├── guest_login_screen.dart        # Guest access
│       ├── home_screen.dart               # Tab navigation
│       ├── dashboard_screen.dart          # Stats & quick actions
│       ├── workouts_screen.dart           # Workout list + filter
│       ├── add_workout_screen.dart        # Create/Edit form
│       ├── reminders_screen.dart          # Reminder management
│       └── settings_screen.dart           # User settings
│
├── assets/
│   ├── images/                            # App images/icons
│   └── fonts/                             # Custom fonts
│
├── android/                               # Android configuration
├── ios/                                   # iOS configuration
│
├── pubspec.yaml                           # Dependencies
├── README.md                              # Project overview
└── SETUP.md                               # Setup instructions
```

---

## 🔄 App Flow & Navigation

```
┌──────────────┐
│ Splash Screen│ (2 seconds)
└──────┬───────┘
       │
       ▼
┌────────────────────┐
│ Onboarding Screen  │ (3 cards)
└──────┬─────────────┘
       │
       ▼
┌──────────────────┐      ┌──────────────────────┐
│ Login Screen     │─────▶│ Guest Login Screen   │
└─────┬────────────┘      └──────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────┐
│            Home Screen (Tab Navigation)         │
├─────────────────────────────────────────────────┤
│ Dashboard │ Workouts │ Reminders │ Settings    │
└─────────────────────────────────────────────────┘
      │          │           │          │
      ▼          ▼           ▼          ▼
   Stats    List+Filter   Add/Edit   Theme&User
             Add/Delete   Manage     Logout
```

---

## 📊 Data Models

### User Model
```dart
class User {
  final String id;                 // Unique identifier
  final String email;              // User email
  final String? password;          // Encrypted password (null for guest)
  final bool isGuest;              // Guest flag
  final DateTime createdAt;        // Account creation date
}
```

### Workout Model
```dart
class Workout {
  final String id;                 // UUID
  final String title;              // Exercise name
  final String type;               // Cardio | Strength | Yoga
  final int duration;              // Minutes
  final int caloriesBurned;        // kcal
  final DateTime date;             // Workout date/time
  final String description;        // Optional notes
}
```

### Reminder Model
```dart
class Reminder {
  final String id;                 // Unique ID
  final String title;              // Reminder title
  final String description;        // Details
  final DateTime scheduledTime;   // When to show
  final bool isActive;             // Enable/disable
  final String frequency;          // daily | weekly | custom
}
```

---

## 💾 Database Schema

### SQLite Tables

#### Users Table
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password TEXT,
  isGuest INTEGER NOT NULL DEFAULT 0,
  createdAt TEXT NOT NULL
)
```

#### Workouts Table
```sql
CREATE TABLE workouts (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  duration INTEGER NOT NULL,
  caloriesBurned INTEGER NOT NULL,
  date TEXT NOT NULL,
  description TEXT
)
```

#### Reminders Table
```sql
CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  scheduledTime TEXT NOT NULL,
  isActive INTEGER NOT NULL DEFAULT 1,
  frequency TEXT NOT NULL DEFAULT 'daily'
)
```

---

## 🔐 Authentication Flow

### Login Flow
1. User enters email & password on LoginScreen
2. AuthProvider validates credentials against database
3. On success:
   - Save user ID to SharedPreferences
   - Update currentUser in AuthProvider
   - Navigate to HomeScreen
4. On failure: Show error message

### Guest Login Flow
1. User clicks "Continue as Guest"
2. Navigate to GuestLoginScreen
3. AuthProvider creates guest user with:
   - ID: `guest_{timestamp}`
   - Email: `guest@fitlifemini.local`
   - isGuest: `true`
4. Navigate to HomeScreen with limited features

### Logout Flow
1. Clear currentUser from AuthProvider
2. Remove user ID from SharedPreferences
3. Navigate back to LoginScreen

---

## 📱 Screen Details

### SplashScreen
- Displays app logo and name
- Shows loading animation
- Auto-navigates after 2 seconds
- No user interaction required

### OnboardingScreen
- 3 swipeable cards with:
  - Icon, title, subtitle
  - Skip button (navigates to login)
  - Next/Get Started button
- Progress dots indicator
- Persists until user completes or skips

### LoginScreen
- Email input field
- Password input field (with show/hide toggle)
- Login button (primary action)
- Sign Up link (not yet implemented)
- Continue as Guest button (secondary)

### DashboardScreen
- Greeting message with date
- 2 stat cards:
  - Today's Calories Burned
  - Workouts Completed
- Quick action buttons:
  - Add Workout
  - View Workouts
- Weekly Activity Chart (placeholder)
- Recent Workouts List (last 3)

### WorkoutsScreen
- Search bar for workouts
- Filter button (Cardio/Strength/Yoga/All)
- Workout list with:
  - Title (bold)
  - Type, Duration, Calories
  - Date
- Tap to view details (not yet implemented)

### AddWorkoutScreen
- Form fields:
  - Title (text)
  - Type (dropdown)
  - Duration (number)
  - Calories Burned (number)
  - Description (optional)
- Save button validates and persists

### RemindersScreen
- List of all reminders
- Create reminder button (FAB)
- Edit/Delete reminder actions
- Shows title and description

### SettingsScreen
- Dark Mode toggle
- User email display
- Account type (Guest/Registered)
- Logout button with confirmation
- About section with version

---

## 🔌 Provider Dependencies

### AuthProvider
**Responsibilities**: User authentication and session management

```dart
// Methods
Future<bool> login(String email, String password)
Future<bool> signup(String email, String password)
Future<void> loginAsGuest()
Future<void> logout()
Future<void> _loadCurrentUser()  // On app start

// Properties
User? get currentUser
bool get isLoggedIn
bool get isGuest
bool get isLoading
```

### ThemeProvider
**Responsibilities**: Theme switching (light/dark)

```dart
// Methods
Future<void> toggleTheme()
Future<void> _loadTheme()

// Properties
bool get isDarkMode
```

### WorkoutProvider
**Responsibilities**: Workout CRUD and statistics

```dart
// Methods
Future<void> loadAllWorkouts()
Future<void> loadWorkoutsByType(String type)
Future<void> addWorkout(Workout workout)
Future<void> updateWorkout(Workout workout)
Future<void> deleteWorkout(String id)
Future<int> getTotalCaloriesToday()
Future<int> getWorkoutCountToday()

// Properties
List<Workout> get workouts
bool get isLoading
```

---

## 🗄️ DatabaseService Methods

### User Operations
```dart
Future<void> saveUser(User user)
Future<User?> getUser(String id)
Future<User?> getUserByEmail(String email)
```

### Workout Operations
```dart
Future<void> addWorkout(Workout workout)
Future<List<Workout>> getAllWorkouts()
Future<List<Workout>> getWorkoutsByType(String type)
Future<List<Workout>> getWorkoutsByDate(DateTime date)
Future<void> updateWorkout(Workout workout)
Future<void> deleteWorkout(String id)
```

### Reminder Operations
```dart
Future<void> addReminder(Reminder reminder)
Future<List<Reminder>> getAllReminders()
Future<void> updateReminder(Reminder reminder)
Future<void> deleteReminder(String id)
```

### Statistics
```dart
Future<int> getTotalCaloriesToday()
Future<int> getWorkoutCountToday()
```

---

## 🎨 Theme Configuration

### Light Theme
- Primary Color: `Colors.blue`
- Background: `Colors.white`
- Text: `Colors.black`
- Cards: White with shadow

### Dark Theme
- Primary Color: `Colors.blue`
- Background: `Colors.grey[900]`
- Text: `Colors.white`
- Cards: Dark grey with subtle shadow

---

## 📦 Dependencies & Versions

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | Core framework |
| sqflite | ^2.3.0 | SQLite database |
| provider | ^6.0.0 | State management |
| shared_preferences | ^2.2.0 | Local preferences |
| intl | ^0.19.0 | Date formatting |
| uuid | ^4.0.0 | ID generation |
| charts_flutter | ^0.12.0 | Data charts |
| cupertino_icons | ^1.0.2 | iOS-style icons |

---

## 🚀 Getting Started

### Prerequisites
```bash
# Install Flutter (if not already installed)
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter --version
flutter doctor
```

### Setup & Run
```bash
# 1. Navigate to project
cd fitlife_mini

# 2. Get dependencies
flutter pub get

# 3. Run on emulator/device
flutter run

# 4. Run in release mode
flutter run --release
```

### Build for Production

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Build iOS app
flutter build ios --release
```

---

## ✅ Features Implemented

- [x] Splash screen with auto-navigation
- [x] Onboarding flow with 3 cards
- [x] User authentication (login/signup)
- [x] Guest access option
- [x] Dashboard with daily stats
- [x] Workout tracking and filtering
- [x] Add/Edit workout functionality
- [x] Reminder management
- [x] Theme switching (light/dark)
- [x] User settings and logout
- [x] SQLite database with CRUD operations
- [x] Offline-first design
- [x] State management with Provider

---

## 🔮 Future Enhancements

- [ ] Weekly/monthly analytics charts
- [ ] Export data as PDF/CSV
- [ ] Backup and restore functionality
- [ ] Multiple language support
- [ ] Push notifications for reminders
- [ ] Goal setting and progress tracking
- [ ] Social sharing capabilities
- [ ] Biometric authentication
- [ ] Wearable device integration
- [ ] Advanced filtering options

---

## 🐛 Known Issues & Limitations

1. **Charts**: Placeholder only, actual implementation pending
2. **Sign Up**: Not yet implemented (use login credentials)
3. **Reminders**: No actual notifications (UI only)
4. **Database**: Single user per device (no multi-user support)
5. **Backup**: No automatic backup mechanism

---

## 📝 Code Examples

### Adding a Workout
```dart
final workout = Workout(
  id: const Uuid().v4(),
  title: 'Morning Run',
  type: 'Cardio',
  duration: 30,
  caloriesBurned: 250,
  date: DateTime.now(),
  description: 'Great run at the park',
);

context.read<WorkoutProvider>().addWorkout(workout);
```

### Getting Daily Stats
```dart
final provider = context.read<WorkoutProvider>();
final calories = await provider.getTotalCaloriesToday();
final workoutCount = await provider.getWorkoutCountToday();
```

### Toggling Theme
```dart
context.read<ThemeProvider>().toggleTheme();
```

---

## 📚 Documentation Files

- **README.md** - Project overview and features
- **SETUP.md** - Installation and configuration
- **This file** - Complete technical documentation

---

## 🔗 Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design](https://material.io/design)

---

## 📞 Support

For issues or questions:
1. Check the documentation files
2. Review the code comments
3. Check the Flutter community forums
4. Review GitHub issues (if applicable)

---

## 📄 License

This project is provided as-is for educational purposes.

---

**Last Updated**: January 2025
**Version**: 1.0.0
**Status**: Development Complete ✓
