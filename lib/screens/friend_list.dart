import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withend/screens/matching_screen.dart';
import 'package:withend/screens/profile_screen.dart';
import 'package:withend/screens/friend_profile_screen.dart';

class FriendList extends StatefulWidget {
  const FriendList({Key? key}) : super(key: key);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final db = FirebaseFirestore.instance;
  late String userName = ''; //유저이름
  late String selfIntro = ''; //유저 한줄소개
  List<dynamic> friendList = []; //유저 친구리스트
  List<String> friendName = []; //친구 이름 리스트
  List<String> friendIntro = []; //친구 한줄소개 리스트
  late String friendUrl = ''; //친구 사진 url input
  List<String> friendImage = []; //친구 사진 url 목록
  late String userUid = ''; //current user uid
  late Reference _ref; //유저 사진 받아올 reference
  late Reference _friendRef; //친구 사진 url 받아올 reference
  late String userUrl = ''; //유저 사진 url

  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser!.uid;
    _ref = FirebaseStorage.instance.ref().child('user_images/$userUid.jpg');
    userUrl = ''; // userUrl 초기화 추가
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var result = await db.collection('users').doc(uid).get();
    String url = await _ref.getDownloadURL();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        userName = data['username'];
        selfIntro = data['self_intro'];
        friendList = data['friend_list'];
        userUrl = url;
      });
      await loadFriendInfo(); // await 추가
    } else {
      setState(() {
        userName = '사용자 이름 없음';
        selfIntro = '';
      });
    }
  }

  Future<void> loadFriendInfo() async {
    for (int i = 0; i < friendList.length; i++) {
      var id = friendList[i];
      await getFriendInfo(id);
    }
  }

  Future<void> getFriendInfo(String id) async {
    var result = await db.collection("users").doc(id.trim()).get();
    _friendRef = FirebaseStorage.instance.ref().child('user_images/$id.jpg');
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      friendUrl = await _friendRef.getDownloadURL();
      setState(() {
        friendName.add(data['username']);
        friendIntro.add(data['self_intro']);
        friendImage.add(friendUrl);
      });
    } else {
      print("변수에 존재하는 값이 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromARGB(255, 240, 240, 240),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userUrl),
                  radius: 35,
                ),
                //const SizedBox(width: 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                          color: Color.fromRGBO(53, 231, 189, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selfIntro,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                //수정하기
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(53, 231, 189, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                  ),
                  child: const Text(
                    '수정하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Friends',
                style: TextStyle(
                  color: Color.fromRGBO(30, 209, 166, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade200, thickness: 1.0), //구분선
          if (friendList.isNotEmpty) //friednList 비어있는지
            Expanded(
              child: ListView.builder(
                itemCount: friendList.length,
                itemBuilder: (context, int index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FriendProfileScreen(friendList[index]),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(friendImage[index]),
                    ),
                    title: Text(friendName[index]),
                    subtitle: Text(friendIntro[index]),
                  );
                },
                scrollDirection: Axis.vertical,
              ),
            ),

          const SizedBox(
            height: 150,
          ),
          if (friendList.isEmpty) Image.asset('assets/images/puzzle100.png'),

          const SizedBox(
            height: 30,
          ),
          if (friendList.isEmpty)
            const Expanded(
              child: Text(
                "새로운 친구를 만나보세요",
                style: TextStyle(
                    color: Color.fromRGBO(30, 209, 166, 1),
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
