import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_screen.dart';
import 'screens/profile_page.dart';
import 'screens/about_page.dart';
import 'screens/signup_user_screen.dart';
import 'screens/signup_volunteer_screen.dart';
import 'screens/ambulance_page.dart';
import 'screens/disaster_recovery_page.dart';
import 'screens/fire_rescue_page.dart';
import 'screens/hazard_alert_page.dart';
import 'screens/hospital_page.dart';
import 'screens/police_page.dart';
import 'screens/wildlife_conservation_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const StartScreen(),
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/news': (context) => const NewsScreen(),
  '/profile': (context) => const ProfilePage(),
  '/about': (context) => const AboutPage(),
  '/signupUser': (context) => const SignupUserScreen(),
  '/signupVolunteer': (context) => const SignupVolunteerScreen(),
  '/fireRescue': (context) => const FireRescuePage(),
  '/ambulance': (context) => const AmbulancePage(),
  '/hospital': (context) => const HospitalPage(),
  '/police': (context) => const PolicePage(),
  '/wildlifeConservation': (context) => const WildlifeConservationPage(),
  '/hazardAlert': (context) => const HazardAlertPage(),
  '/disasterRecovery': (context) => const DisasterRecoveryPage(),
  '/settings': (context) => const SettingsScreen(),
};
