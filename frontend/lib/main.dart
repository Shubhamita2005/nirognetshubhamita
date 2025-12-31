/// In main.dart
library;

// 1. Import flutter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 2. Import ONLY your login/onboarding screens
import 'screens/get_started.dart';
import 'screens/login_page.dart';
import 'screens/login_as.dart';
import 'screens/profile_page.dart';
import 'screens/signup_page.dart';

// 3. Import the AI screen (since it's a separate route)
import 'screens/ai_symptom_checker_two.dart';

//4. Import the emergency screens
import 'screens/emergency_assistant.dart';
import 'screens/emergency_assistance_offline.dart';

// 5. Import the NEW main_scaffold.dart file (we will create this)
//    (Assuming you create it in the 'lib/' folder)
import 'main_scaffold.dart';

// 6. REMOVE imports for homepage.dart and book_consultation_page.dart
//    (main_scaffold.dart will import them)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NirogNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3ECFCF),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),

      // Set your starting page
      initialRoute: '/get_started',

      // Define all your app's routes
      routes: {
        // --- Login/Onboarding Flow ---
        '/get_started': (context) => WelcomeScreen(),
        '/login': (context) => LoginPage(),
        '/login_as': (context) => LoginScreen(),
        '/signup': (context) => SignUpPage(),

        // --- Main App Shell ---
        // This is the new route for your entire logged-in experience
        '/main': (context) => const MainScaffold(),

        // --- Separate Pages (no nav bar) ---
        '/ai_symptom': (context) => AISymptomChecker(),
        '/profile': (context) => ProfilePage(),
        '/emergency_assistant': (context) => EmergencyAssistantPage(),
        'emergency_assistance_offline': (context) => EmergencyAssessmentPage(),
        // --- REMOVED ---
        // '/homepage': (context) => HomeScreen(),
        // '/book_consultation': (context) => BookConsultationScreen(),
      },
    );
  }
}
