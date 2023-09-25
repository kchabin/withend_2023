//프로필 설정
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:withend/screens/matching_screen.dart';

//유저 프로필 수정 화면
class FriendProfileScreen extends StatefulWidget {
  final String data;

  const FriendProfileScreen(this.data);

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  // final _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  late String userUid = '';
  late String userName = '';
  String userIntro = '';
  String userImage = '';
  late Reference _ref; //유저 사진 받아올 reference
  late String userUrl = ''; //유저 사진 url

  TextEditingController nameController = TextEditingController();
  TextEditingController introController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser!.uid;
    _ref =
        FirebaseStorage.instance.ref().child('user_images/${widget.data}.jpg');
    getUserInfo(widget.data);
  }

  Future<void> getUserInfo(id) async {
    var result = await db.collection('users').doc(id).get();
    String url = await _ref.getDownloadURL();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        userName = data['username'];
        userIntro = data['self_intro'];
        userImage = data['image_url'];
        userUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Color.fromRGBO(53, 231, 189, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromRGBO(53, 231, 189, 1),
      ),
      body: Center(
        // Center 위젯으로 전체 Column을 감싸줍니다.
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 주 축 (세로 방향) 중앙 정렬
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // 가로 방향 중앙 정렬
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20.0,
                            spreadRadius: 5.0,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(userUrl),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      selfIntro,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
