import 'package:flutter/material.dart';
import 'package:withend/screens/login_screen.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //구조
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 260,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: Column(
                    children: [
                      Text(
                        'WITHEND',
                        style: TextStyle(
                          color: Color.fromRGBO(30, 209, 166, 1),
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '나만의 소울메이트 찾기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 130,
            ),
            Flexible(
              flex: 2,
              child: Column(
                //로그인, 회원가입 버튼
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Container(
                      //로그인 버튼
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 231, 189, 1),
                        borderRadius: BorderRadius.circular(42),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 40,
                        ),
                        child: Text(
                          '시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
