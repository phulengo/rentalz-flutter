import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/services/auth.dart';
import 'routes/index.dart' as route;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    StreamProvider<User?>.value(value: AuthService().user, initialData: null)
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RentalZ',
      theme:
          ThemeData(primarySwatch: Colors.grey, fontFamily: 'Be Vietnam Pro'),
      onGenerateRoute: route.controller,
    );
  }
}
