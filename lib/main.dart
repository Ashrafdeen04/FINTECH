import 'package:flutter/material.dart';
import 'package:knowfin/landing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:knowfin/pages/videos_page.dart';
import 'auth/login.dart';
import 'landing.dart';
import 'generate.dart';
import 'budget_generator.dart';
import 'pages/quiz_page_pages/quiz.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomePage();
            } else {
              return SignInPage();
            }
            // return VideosPage();
            // return ChatbotPage();
            //return HomeScreen();
            //return QuizPage();
          },
        ));
  }
}
