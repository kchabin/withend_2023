// //채팅방 리스트///
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:withend/screens/chat_screen.dart';
import 'package:withend/screens/chatbot_screen.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final db = FirebaseFirestore.instance;
  late String userUid = '';
  var userName = ''; //유저 이름(친구 목록 가져오기 위해서)
  List<dynamic> friendList = []; //친구 목록
  List<String> friendName = []; //친구 이름 목록
  late Reference _friendRef; //친구 사진 url 가져올 reference
  late String friendUrl = '';
  List<String> friendImage = []; //친구 이미지 url 목록
  late Widget selectedScreen; //채팅방을 어디로 할 지 결정

  Future<void> getUserInfo() async {
    var result = await db.collection('users').doc(userUid).get();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        userName = data['username'];
        friendList = data['friend_list'];
      });
      await loadFriendInfo();
    } else {
      setState(() {
        userName = '사용자 이름 없음';
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
    print(id);
    var result = await db.collection("users").doc(id).get();
    _friendRef = FirebaseStorage.instance.ref().child('user_images/$id.jpg');
    friendUrl = await _friendRef.getDownloadURL();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        friendName.add(data['username']);
        friendImage.add(friendUrl);
      });
    } else {
      print("변수에 존재하는 값이 없습니다.");
    }
  }

  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser!.uid;
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    Widget chatListView = Container(); // 기본적으로 빈 컨테이너

    if (friendName.isNotEmpty) {
      chatListView = ListView.builder(
        itemCount: friendName.length, // friendName 배열 길이만큼 아이템 생성
        itemBuilder: (context, index) {
          return ListTile(
              leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(friendImage[index])),
              title: Text(friendName[index]),
              subtitle: const Text('메시지 내용'),
              onTap: () {
                String data = friendList[index];
                if (data == "4s5FR2vQBMet6RhgDRxxkEZMGpm1") {
                  selectedScreen = ChatbotScreen(data);
                } else {
                  selectedScreen = ChatScreen(data);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => selectedScreen,
                  ),
                );
              });
        },
        scrollDirection: Axis.vertical,
      );
    } else {
      const CircularProgressIndicator();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            InkWell(
              child: Image.asset("assets/images/banner.png"),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(30, 209, 166, 1),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade200, thickness: 1.0),
            if (friendName.isNotEmpty && friendImage.isNotEmpty)
              Expanded(
                child: chatListView, // chatListView 위젯 반환
              ),
            const SizedBox(
              height: 150,
            ),
            if (friendList.isEmpty) Image.asset('assets/images/chat.png'),
            if (friendList.isEmpty)
              const SizedBox(
                height: 20,
              ),
            if (friendList.isEmpty)
              const Text(
                '대화를 시작해보세요',
                style: TextStyle(
                    color: Color.fromRGBO(30, 209, 166, 1),
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
