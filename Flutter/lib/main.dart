import 'package:anticairapp/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/create_annonce_screen.dart';
import 'screens/details_screen.dart';
import 'screens/edit_annonce_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AnticairApp(),
    ),
  );
}

class AnticairApp extends StatelessWidget {
  const AnticairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anticair App',
      theme: ThemeData(
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/create': (context) => const CreateAnnonceScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final annonceId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => DetailScreen(annonceId: annonceId),
          );
        }
        if (settings.name == '/update') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null) return null;

          final annonce = args['annonce'];
          return MaterialPageRoute(
            builder: (context) => EditAnnonceScreen(annonce: annonce),
          );
        }
        return null;
      },
    );
  }
}
