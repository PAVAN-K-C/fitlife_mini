# FitLife Mini - Complete Project Documentation

## 📱 Project Overview

**FitLife Mini** is a Flutter-based offline-first fitness tracking application that allows users to:
- Track daily workouts (Cardio, Strength, Yoga)
- Monitor calories burned and workout statistics
- Set exercise reminders
- Manage user profiles with guest access
- View activity trends and analytics
- Switch between light and dark themes

### Technology Stack
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Local Storage**: SharedPreferences


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

## Getting Started

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


