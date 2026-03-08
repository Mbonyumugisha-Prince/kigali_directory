# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure locations across the city. The app is fully integrated with Firebase Authentication and Cloud Firestore for real-time data persistence.

---

## Features

- **Authentication** — Sign up, log in, and log out using Firebase Auth. Email verification is enforced before a user can access the app.
- **Directory** — Browse all listings in real time with search by name and category filter chips.
- **CRUD Listings** — Authenticated users can create, read, update, and delete their own listings stored in Firestore.
- **Map View** — An interactive OpenStreetMap showing all listings that have geographic coordinates as tappable pins.
- **Detail Page** — Full listing details with an embedded map marker and a one-tap button to launch Google Maps turn-by-turn directions.
- **My Listings** — A personal screen showing only the listings created by the logged-in user.
- **Settings** — Displays the authenticated user's profile and a location notification toggle.

---

## App Architecture

The project follows a clean separation of concerns:

```
lib/
├── firebase_options.dart       # Auto-generated Firebase config
├── main.dart                   # App entry point, Provider setup
├── models/
│   └── listing_model.dart      # Listing data class, fromMap / toMap
├── providers/
│   ├── auth_providers.dart     # Auth state management (ChangeNotifier)
│   └── listing_provider.dart  # Listing CRUD + stream state (ChangeNotifier)
├── services/
│   ├── auth_services.dart      # Firebase Auth + Firestore user profile
│   ├── listing_service.dart    # Firestore CRUD for listings
│   └── otp_services.dart       # Email verification helpers
├── screens/
│   ├── auth/                   # Login, Sign-up, OTP/verification screens
│   ├── directory/              # Directory, Detail, Add/Edit screens
│   ├── map/                    # Map View screen
│   ├── my_listings/            # My Listings screen
│   ├── settings/               # Settings screen
│   └── home_screen.dart        # BottomNavigationBar shell
└── utils/
    └── app_theme.dart          # Colors, theme, category icons
```

---

## State Management

The app uses the **Provider** package (`ChangeNotifier`).

- `AuthProvider` — listens to `FirebaseAuth.authStateChanges()` and exposes login, signup, logout, and email-verification status to the entire widget tree.
- `ListingProvider` — opens a **real-time Firestore stream** via `snapshots()` so every screen (Directory, My Listings, Map View, Detail) automatically rebuilds when data changes in the cloud. All Firestore operations are delegated to `ListingService` — no Firebase calls exist inside UI widgets.

Data flow:

```
Firestore  →  ListingService  →  ListingProvider (stream)  →  UI widgets
UI action  →  ListingProvider  →  ListingService  →  Firestore
```

---

## Firestore Database Structure

### Collection: `listings`

Each document represents one place or service listing.

| Field | Type | Description |
|---|---|---|
| `name` | String | Place or service name |
| `category` | String | One of: Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction |
| `address` | String | Street address in Kigali |
| `contactNumber` | String | Phone number |
| `description` | String | Description of the place |
| `createdBy` | String | UID of the user who created the listing |
| `createdAt` | Timestamp | Server timestamp of creation |

### Collection: `users`

Each document is keyed by the user's Firebase UID.

| Field | Type | Description |
|---|---|---|
| `uid` | String | Firebase Auth UID |
| `email` | String | User email address |
| `displayName` | String | Full name entered at signup |
| `createdAt` | Timestamp | Account creation timestamp |
| `notificationsEnabled` | Boolean | Notification preference |

### Firestore Security Rules

```
match /listings/{listingId} {
  allow read, create : if request.auth != null;
  allow update, delete : if request.auth != null
                       && request.auth.uid == resource.data.createdBy;
}
match /users/{email} {
  allow read, write : if true;
}
```

---

## Prerequisites

Before running the app, make sure you have the following installed:

| Tool | Version |
|---|---|
| Flutter SDK | 3.10.x or later |
| Dart SDK | 3.x (bundled with Flutter) |
| Android Studio / Xcode | Latest stable |
| Firebase CLI | Latest (`npm install -g firebase-tools`) |
| A physical device or emulator | Android API 21+ or iOS 12+ |

---

## Environment Setup & Running the App

### 1. Clone the repository

```bash
git clone git@github.com:Mbonyumugisha-Prince/kigali_directory.git
cd kigali_directory
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

This app requires a Firebase project with **Authentication** and **Firestore** enabled.

**a. Create a Firebase project**

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project** and follow the steps
3. Enable **Authentication** → Sign-in method → **Email/Password**
4. Enable **Cloud Firestore** → Start in production mode → choose a region

**b. Add your Android app to Firebase**

1. In the Firebase Console, go to **Project Settings** → Kigali Directory → Add Android app
2. Use the package name `com.example.kigaliDirectory`
3. Download `google-services.json` and place it at:
   ```
   android/app/google-services.json
   ```

**c. Add your iOS app to Firebase**

1. Add an iOS app with bundle ID `com.example.kigaliDirectory`
2. Download `GoogleService-Info.plist` and place it at:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

**d. Generate `firebase_options.dart` (FlutterFire CLI)**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will regenerate `lib/firebase_options.dart` with your project's keys.

### 4. Create the `.env` file

Create a `.env` file in the **root** of the project (same level as `pubspec.yaml`):

```
# .env
# Add any environment-specific variables here.
# Currently this file is required by flutter_dotenv at startup.
# Example:
SOME_KEY=your_value
```

> The `.env` file is already listed in `pubspec.yaml` under `flutter: assets:` so Flutter can bundle it. If you have no extra keys, an empty file (or a comment line) is enough.

### 5. Deploy Firestore security rules

```bash
firebase login
firebase deploy --only firestore:rules
```

### 6. Run the app

```bash
# Check connected devices
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Or simply run on the first available device
flutter run
```

---

## Navigation Structure

| Tab | Screen | Description |
|---|---|---|
| Directory | `DirectoryScreen` | Browse, search, and filter all listings |
| My Listings | `MyListingsScreen` | Listings created by the logged-in user |
| Map View | `MapViewScreen` | Interactive map with listing pins |
| Settings | `SettingsScreen` | User profile and notification toggle |

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Real-time cloud database |
| `provider` | State management |
| `flutter_map` | OpenStreetMap tiles (no API key needed) |
| `latlong2` | Geographic coordinates |
| `url_launcher` | Launch Google Maps directions |
| `flutter_dotenv` | Load `.env` environment variables |
