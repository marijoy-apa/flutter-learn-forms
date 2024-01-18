import 'package:expense_tracker/home_page.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

void main() {
  //ensure the locking of orientation and running of the app
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
  //   (value) {
  //     return runApp(
  //       const MyApp(),
  //     );
  //   },
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}
