import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:withend/screens/choice_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:withend/screens/splash_screen.dart';
import 'package:withend/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  //플러터의 코어 위젯. 무언가를 화면에 띄워줌.
  //우리 앱의 시작점 root
  @override //부모 클래스에 이미 있는 메소드 오버라이딩
  Widget build(BuildContext context) {
    //위젯은 계약. build 메소드를 구현해야함.
    //1. material app(구글) or 2. cupertino app (ios)리턴
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Pretendard', useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const Menu();
          }
        },
      ), //쉼표로 포맷팅
    );
  }
}
