# FitLife Mini - Setup Guide

## Project Overview

FitLife Mini is a Flutter-based offline-first fitness tracking application designed to track workouts, monitor calorie burn, and manage exercise reminders without requiring internet connectivity.

## Architecture Overview

### State Management (Provider Pattern)
- **AuthProvider**: Handles user login/signup and session management
- **ThemeProvider**: Manages light/dark theme preference
- **WorkoutProvider**: Manages workout CRUD operations and statistics

### Data Persistence
- **SQLite Database**: Local storage for users, workouts, and reminders
- **SharedPreferences**: Stores user preferences (theme, last login user ID)

### Navigation
- Route-based navigation using named routes
- Splash Screen → Onboarding → Login → Dashboard

## Screens Implemented

1. **SplashScreen** - Initial app loading screen
2. **OnboardingScreen** - Swipeable introduction cards
3. **LoginScreen** - Email/password authentication
4. **GuestLoginScreen** - Guest access option
5. **HomeScreen** - Tab-based navigation
6. **DashboardScreen** - Daily stats and quick actions
7. **WorkoutsScreen** - Workout list with filtering
8. **AddWorkoutScreen** - Form to create/edit workouts
9. **RemindersScreen** - Reminder management
10. **SettingsScreen** - User preferences and logout

## Key Features

✅ Offline-first design
✅ SQLite database with complete CRUD operations
✅ User authentication (registered & guest)
✅ Workout tracking with multiple categories
✅ Daily statistics calculation
✅ Theme switching (light/dark mode)
✅ Persistent user sessions
✅ Reminder management

## Next Steps to Complete

1. **Enhance UI/UX**
   - Add more polished designs matching the wireframe
   - Implement custom icons and imagery
   - Add animations and transitions

2. **Complete Features**
   - Implement weekly activity charts
   - Add data export functionality
   - Create backup and restore options

3. **Testing**
   - Add unit tests for providers
   - Add widget tests for screens
   - Add integration tests

4. **Build Configuration**
   - Update AndroidManifest.xml
   - Update iOS build configurations
   - Configure app signing

5. **Optimization**
   - Implement lazy loading for workout lists
   - Add pagination for large datasets
   - Optimize database queries

## Running the Application

### Prerequisites
```bash
# Ensure Flutter is installed
flutter --version

# Check environment
flutter doctor
```

### Build & Run
```bash
# Navigate to project directory
cd fitlife_mini

# Get dependencies
flutter pub get

# Run on emulator/device
flutter run
```

## File Structure

```
lib/
├── main.dart                          # Application entry point
├── models/
│   ├── user.dart                     # User model
│   ├── workout.dart                  # Workout model
│   └── reminder.dart                 # Reminder model
├── providers/
│   ├── auth_provider.dart            # Authentication logic
│   ├── theme_provider.dart           # Theme management
│   └── workout_provider.dart         # Workout operations
├── services/
│   └── database_service.dart         # SQLite operations
└── screens/
    ├── splash_screen.dart
    ├── onboarding_screen.dart
    ├── login_screen.dart
    ├── guest_login_screen.dart
    ├── home_screen.dart
    ├── dashboard_screen.dart
    ├── workouts_screen.dart
    ├── add_workout_screen.dart
    ├── reminders_screen.dart
    └── settings_screen.dart
```

## Dependencies

All dependencies are defined in `pubspec.yaml`:

- **flutter**: Core framework
- **sqflite**: Local database
- **provider**: State management
- **shared_preferences**: User preferences
- **intl**: Date/time formatting
- **uuid**: ID generation
- **charts_flutter**: Data visualization

## Database Operations

The DatabaseService class handles all SQLite operations:

```dart
// Example: Add workout
final workout = Workout(...);
await _databaseService.addWorkout(workout);

// Example: Get all workouts
final workouts = await _databaseService.getAllWorkouts();

// Example: Get daily stats
final calories = await _databaseService.getTotalCaloriesToday();
```

## Customization Points

1. **Colors**: Update the theme colors in `main.dart`
2. **Typography**: Configure text styles in MaterialApp
3. **Database**: Modify schema in `_createDb()` method
4. **Routes**: Add new routes in `main.dart`
5. **Icons**: Replace Material icons with custom assets

## Common Issues & Solutions

### Issue: Database already exists error
**Solution**: Clear app data through Settings or uninstall and reinstall

### Issue: Migrations needed
**Solution**: Increment `_databaseVersion` in DatabaseService and implement migration logic in `onCreate`

### Issue: Hot reload doesn't work
**Solution**: Stop and restart the app with `flutter run`

## Performance Optimization Tips

1. Use `const` constructors where possible
2. Implement pagination for large lists
3. Cache expensive database queries
4. Use `ListView.builder()` for dynamic lists
5. Minimize widget rebuilds with Consumer blocks

## Testing

To add tests create a `test/` directory:

```bash
flutter test
```

## Deployment Checklist

- [ ] Update version number in pubspec.yaml
- [ ] Update app icon and splash screen
- [ ] Test on multiple devices
- [ ] Configure release signing
- [ ] Test all features work offline
- [ ] Verify database persistence
- [ ] Check memory leaks with DevTools
- [ ] Test theme switching
- [ ] Verify navigation works correctly

## Support & Documentation

- Flutter Documentation: https://flutter.dev/docs
- SQLite Documentation: https://www.sqlite.org/docs.html
- Provider Documentation: https://pub.dev/packages/provider
