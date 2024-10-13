import 'package:calm_lake_project/firebase_options.dart';
import 'package:calm_lake_project/view/login/login.dart';
import 'package:calm_lake_project/vm/app_lifecycle_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppLifecycleController lifecycleHandler=Get.put(AppLifecycleController());
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, 
      ),
      home: Login(),
      navigatorObservers: [
        AutoLogoutObserver(resetTimer: lifecycleHandler.resetTimer)
      ],
    );
  }  
}

class AutoLogoutObserver extends NavigatorObserver {
  final Function resetTimer;

  AutoLogoutObserver({required this.resetTimer});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    resetTimer();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    resetTimer();
  }
}