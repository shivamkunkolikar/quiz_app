import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_app/dashboard_page.dart';
import 'package:quiz_app/home_page.dart';
import 'package:quiz_app/result_page.dart';
import 'package:quiz_app/signup_page.dart';
import 'package:quiz_app/testadmin_page.dart';
import 'firebase_options.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:quiz_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await updateHomeInfo();

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 148, 255)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // home: const MyHomePage(title: 'Flutter Demo Home Page')
      home: username == '' ? LoginPage() : HomePage(),
      // home: const ResultPage()
      // home: SuccessSignupPage(),
      // home: TestadminPage(testId: 'XHQih2i0lZ6LsdePiKtx'),
      // home: HomePage(),
      // home: const DashboardPage(),

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }
}
