import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import './providers/course_provider.dart';
import './providers/category_provider.dart';
import './providers/lesson_provider.dart';
import './providers/user_provider.dart';

// Screens
import './screens/home_screen.dart';
//import './screens/course_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'eLearning App',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.purpleAccent,
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'Roboto',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const HomePage(),
          //'/course-detail': (ctx) => CourseDetailScreen(),
          //'/lesson-list': (ctx) => LessonListScreen(),
        },
      ),
    );
  }
}
