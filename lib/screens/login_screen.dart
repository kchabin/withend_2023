//로그인 페이지
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:withend/screens/matching_screen.dart';
import 'package:withend/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
//import 'package:withend/main.dart';

final _firebase = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showSpinner = false;

  final formKey = GlobalKey<FormState>();
  var enteredEmail = '';
  var enteredPassword = '';
  var enteredName = '';
  var enteredIntro = '';
  var friendList = <String>['4s5FR2vQBMet6RhgDRxxkEZMGpm1'];
  var _isLogin = true;
  var matchList = <String>[]; //매칭된 사람 리스트
  var requestList = <String>[]; //친구 요청 온 리스트
  var profile = <dynamic>[]; //사용자의 48차원 벡터
  var sendRequestList = <dynamic>[]; // 친구요청 보낸 친구 리스트
  File? _selectedImage;
  bool _isAuthenticating = false; //로딩 중 표시

  void _submit() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        //log users in
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

        final storageRef = FirebaseStorage.instance //파이어 스토리지 접근
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        //성향 벡터 초기화 해주기
        // 15개의 0 값을 가진 리스트 생성
        List<double> zeros = List.generate(15, (index) => 0);

        // -0.5에서 0.5 사이의 소수값으로 채워진 33개의 요소를 가진 리스트 생성
        List<double> randoms =
            List.generate(33, (index) => Random().nextDouble() - 0.5);

        // 두 리스트를 합침
        profile = zeros + randoms;

        await FirebaseFirestore.instance //파이어스토어 접근
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredName,
          'email': enteredEmail,
          'image_url': imageUrl, //사진 업로드 -> 스토리지 -> 파이어스토어
          'self_intro': enteredIntro,
          'friend_list': friendList,
          'match_list': matchList,
          'request_list': requestList,
          'profile': profile, //사용자 성향벡터 저장
          'userId': userCredentials.user!.uid,
          'send_request': sendRequestList,
          //프로필 사진 업데이트 되는지는 아직 모름. => 23.08.08 .01:15
        });
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //인증 실패 시 하단에 스낵바가 뜸.
          content: Text(error.message ?? '인증 실패.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: const Color.fromRGBO(30, 209, 166, 1),
        ),
      );

      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //스크린 배경화면
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(30, 209, 166, 1),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: 35,
        ),
      ),
      body: Padding(
        //화면 양 옆 패딩 설정
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Color.fromRGBO(30, 209, 166, 1),
                          fontSize: 45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '나만의 소울메이트 찾기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            onPickImage: ((pickedImage) {
                              _selectedImage = pickedImage;
                            }),
                          ),
                        if (!_isLogin)
                          TextFormField(
                            //이름 입력칸
                            cursorColor: const Color.fromRGBO(53, 231, 189, 1),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 247, 247, 247),
                              prefixIcon: const Icon(
                                Icons.abc_rounded,
                                color: Color.fromRGBO(30, 209, 166, 1),
                              ),
                              hintText: "Name",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(53, 231, 189, 1),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            onSaved: (value) {
                              enteredName = value!;
                            },
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          //이메일
                          cursorColor: const Color.fromRGBO(53, 231, 189, 1),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 247, 247, 247),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color.fromRGBO(30, 209, 166, 1),
                            ),
                            hintText: "E-mail",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(53, 231, 189, 1),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return '유효한 이메일이 아닙니다.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredEmail = value!;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          //password

                          obscureText: true,
                          //showCursor: false,
                          cursorColor: const Color.fromRGBO(53, 231, 189, 1),

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 247, 247, 247),
                            prefixIcon: const Icon(
                              Icons.password_rounded,
                              color: Color.fromRGBO(30, 209, 166, 1),
                            ),
                            hintText: "Password",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(53, 231, 189, 1),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 8) {
                              return '비밀번호는 8자 이상이어야 합니다.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredPassword = value!;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (!_isLogin)
                          TextFormField(
                            //selfIntro

                            obscureText: false,
                            //showCursor: false,
                            cursorColor: const Color.fromRGBO(53, 231, 189, 1),

                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 247, 247, 247),
                              prefixIcon: const Icon(
                                Icons.password_rounded,
                                color: Color.fromRGBO(30, 209, 166, 1),
                              ),
                              hintText: "self-intro",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(53, 231, 189, 1),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '한 줄 소개를 입력해주세요.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredIntro = value!;
                            },
                          ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: () => {_submit()},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(53, 231, 189, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                            ),
                            child: Text(_isLogin ? '로그인' : '회원가입'),
                          ),
                        const SizedBox(
                          height: 1,
                        ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  const Color.fromRGBO(30, 209, 166, 1),
                            ),
                            child: Text(
                              _isLogin ? '계정 만들기' : '계정이 있습니다.',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
