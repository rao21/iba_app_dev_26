// ConnectionCheckPage talks to the real Firebase project the moment it
// builds (Firebase.initializeApp, then a Firestore read/write), so a plain
// `flutter test` can't drive it — there is no platform channel for Firebase
// in that environment. Until there's a CRUD screen with its own repository
// to inject a fake into (the same pattern as the other lectures), verifying
// the connection means running the app for real: `flutter run`.

void main() {}
