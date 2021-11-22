import 'package:flutter/material.dart';
import 'package:rentalz_flutter/screens/main/index.dart';
import 'package:rentalz_flutter/screens/main/search/search_screen.dart';
import 'package:rentalz_flutter/screens/onboarding/login_screen.dart';
import 'package:rentalz_flutter/screens/property/detail_screen.dart';

Route controller(RouteSettings settings) {
  switch (settings.name) {
    case "/search":
      return MaterialPageRoute(
          builder: (context) => SearchScreen(destination: settings.arguments));
    case "/property":
      return MaterialPageRoute(
          builder: (context) => DetailPropertyScreen(
              property:
                  settings.arguments)); // Sending property from click's context
    case '/home':
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    default:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
  }
}
