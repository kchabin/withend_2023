//개인 프로필& 친구 관리 탭

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withend/screens/chat_list.dart';
import 'package:withend/screens/friend_list.dart';
import 'package:withend/screens/matching_screen.dart';
import 'package:withend/screens/setting_screen.dart';

//import 'package:image_picker/image_picker.dart';
//친구 관리 O
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  // ignore: unused_field
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: 친구',
      style: optionStyle,
    ),
    Text(
      'Index 1: 채팅',
      style: optionStyle,
    ),
    Text(
      'Index 2: 매칭',
      style: optionStyle,
    ),
    Text(
      'Index 3: 환경설정',
      style: optionStyle,
    )
  ];

  static List<Widget> pages = <Widget>[
    const FriendList(), //친구관리탭
    const ChatList(), //채팅방
    const MatchingScreen(), //친구매칭탭
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'WITHEND',
          style: TextStyle(
              color: Color.fromRGBO(30, 209, 166, 1),
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          //로그아웃 버튼
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Color.fromRGBO(30, 209, 166, 1),
            ),
          ),
        ],
      ),
      //화면 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '친구',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.public,
            ),
            label: '친구 찾기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: '환경설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(30, 209, 166, 1),
        onTap: _onItemTapped,
      ),
      body: pages[_selectedIndex],
    );
  }
}
