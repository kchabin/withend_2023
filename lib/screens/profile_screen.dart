//프로필 설정
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

//유저 프로필 수정 화면
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class changedProfile {
  String username = '';
  List<String> friend_list = [];
  String image_url = '';
  String self_intro = '';
  String email = '';

  changedProfile(this.username, this.friend_list, this.image_url, this.email,
      this.self_intro);
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  late String userUid = '';
  File? _pickedImageFile;
  late String userName = '';
  String userIntro = '';
  String changedName = '';
  String changedIntro = '';
  File? _selectedImage;
  String userImage = '';
  String test = '안녕';

  TextEditingController nameController = TextEditingController();
  TextEditingController introController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser!.uid;
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    var result = await db.collection('users').doc(userUid).get();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        userName = data['username'];
        userIntro = data['self_intro'];
        userImage = data['image_url'];
      });
    }
  }

  //유저정보 업데이트
  void update() async {
    if (changedName.isNotEmpty) {
      userName = changedName;
    }
    if (changedIntro.isNotEmpty) {
      userIntro = changedIntro;
    }

    final storageRef = FirebaseStorage.instance //파이어 스토리지 접근
        .ref()
        .child('user_images')
        .child('$userUid.jpg');

    await storageRef.putFile(_pickedImageFile!);
    final imageUrl = await storageRef.getDownloadURL();

    final previousImageRef =
        FirebaseStorage.instance.ref().child('user_images/$userImage.jpg');
    await previousImageRef.delete();

    db.collection('users').doc(userUid).update({
      'username': userName,
      'self_intro': userIntro,
      'image_url': imageUrl,
    });
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
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
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromRGBO(53, 231, 189, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    foregroundImage: _pickedImageFile != null
                        ? FileImage(_pickedImageFile!)
                        : null,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text(
                      '프로필 이미지 선택',
                      style: TextStyle(
                        color: Color.fromRGBO(53, 231, 189, 1),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  //자기 이름 변경 칸
                  TextFormField(
                    cursorColor: const Color.fromRGBO(53, 231, 189, 1),
                    decoration: InputDecoration(
                      labelText: '변경할 이름을 작성해주세요.',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 247, 247, 247),
                      hintText: '$userName',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        // borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(53, 231, 189, 1),
                        ),
                        // borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    //onsaved는 잠깐 저장해주는 역할로 변화를 감지하지 못한다.
                    //따라서 TextEditingController와 onchanged를 이용
                    controller: nameController,
                    onChanged: (value) {
                      changedName = value;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //자기 소개 변경 칸
                  TextFormField(
                    cursorColor: const Color.fromRGBO(53, 231, 189, 1),
                    decoration: InputDecoration(
                      labelText: '변경할 한 줄 소개를 작성해주세요.',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 247, 247, 247),
                      hintText: '$userIntro',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        // borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(53, 231, 189, 1),
                        ),
                        // borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    controller: introController,
                    onChanged: (value) {
                      changedIntro = value;
                    },
                  ),
                  ButtonBar(
                    // 버튼 바
                    alignment: MainAxisAlignment.center, // 중앙 정렬
                    buttonPadding: EdgeInsets.all(20), // 버튼의 패딩 주기
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            '취소',
                            style: TextStyle(
                                color: Color.fromARGB(255, 30, 30, 30)),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                          )),
                      ElevatedButton(
                        onPressed: () {
                          update();
                          Navigator.pop(context);
                        },
                        child: Text(
                          '적용하기',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(53, 231, 189, 1)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
