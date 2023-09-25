import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:withend/widgets/new_message.dart';
import 'package:withend/widgets/chat_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String data;

  const ChatScreen(this.data, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final db = FirebaseFirestore.instance;
  String friendName = '';
  String userId = '';
  String friendId = '';

  Future<void> getFriendName() async {
    var result = await db.collection('users').doc(widget.data).get();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        friendName = data['username'];
      });
    }
  }

  var chatroomId = '';

  void createChatroomId() {
    userId = FirebaseAuth.instance.currentUser!.uid;
    friendId = widget.data;
    if (userId.compareTo(friendId) > 0) {
      chatroomId = userId + friendId;
    } else {
      chatroomId = friendId + userId;
    }
  }

  @override
  void initState() {
    super.initState();
    getFriendName();
    createChatroomId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friendName),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      endDrawer: sideMenu(context),
      body: Column(
        children: [
          Expanded(child: ChatMessages(chatroomId)),
          NewMessage(chatroomId),
        ],
      ),
    );
  }

  Drawer sideMenu(BuildContext context) {
    return Drawer(
      surfaceTintColor: const Color.fromRGBO(30, 209, 166, 1),
      child: ListView(
        children: [
          const SizedBox(
            height: 100,
          ),
          ListTile(
            leading: const Icon(
              Icons.favorite_rounded,
              size: 40,
            ),
            iconColor: const Color.fromRGBO(30, 209, 166, 1),
            focusColor: const Color.fromRGBO(30, 209, 166, 1),
            title: const Text(
              '만족도 평가하기',
              style: TextStyle(
                  color: Color.fromRGBO(30, 209, 166, 1),
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
            onTap: () {
              _showDialog(context);
            },
            trailing: const Icon(
              Icons.navigate_next_rounded,
              size: 40,
            ),
          ),
          Divider(
            color: Colors.grey.shade200,
            thickness: 1.0,
          ),
          ListTile(
            leading: const Icon(
              Icons.block_rounded,
              size: 40,
            ),
            iconColor: const Color.fromRGBO(30, 209, 166, 1),
            focusColor: const Color.fromRGBO(30, 209, 166, 1),
            title: const Text(
              '친구 차단하기',
              style: TextStyle(
                  color: Color.fromRGBO(30, 209, 166, 1),
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
            onTap: () {},
            trailing: const Icon(
              Icons.navigate_next_rounded,
              size: 40,
            ),
          ),
          Divider(color: Colors.grey.shade200, thickness: 1.0),
          ListTile(
            leading: const Icon(
              Icons.error_outline_rounded,
              size: 40,
            ),
            iconColor: const Color.fromRGBO(30, 209, 166, 1),
            focusColor: const Color.fromRGBO(30, 209, 166, 1),
            title: const Text(
              '신고하기',
              style: TextStyle(
                  color: Color.fromRGBO(30, 209, 166, 1),
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
            onTap: () {},
            trailing: const Icon(
              Icons.navigate_next_rounded,
              size: 40,
            ),
          ),
          Divider(color: Colors.grey.shade200, thickness: 1.0),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              size: 40,
            ),
            iconColor: const Color.fromRGBO(30, 209, 166, 1),
            focusColor: const Color.fromRGBO(30, 209, 166, 1),
            title: const Text(
              '채팅방 나가기',
              style: TextStyle(
                  color: Color.fromRGBO(30, 209, 166, 1),
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
            onTap: () {},
            trailing: const Icon(
              Icons.navigate_next_rounded,
              size: 40,
            ),
          ),
          const SizedBox(
            height: 400,
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "WITHEND",
                  style: TextStyle(
                    color: Color.fromRGBO(30, 209, 166, 1),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    late final ratingController;
    late double rating;

    const double initialRating = 3.0;
    IconData? selectedIcon;

    double userRating = 3.0;
    int ratingBarMode = 1;

    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  '대화는 어떠셨나요?',
                  style: TextStyle(
                      color: Color.fromRGBO(30, 209, 166, 1),
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 20,
                ),
                Image.asset("assets/images/star_struck.png"),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //별점 평가 ======================

                    RatingBar.builder(
                      initialRating: initialRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      unratedColor: const Color.fromRGBO(30, 209, 166, 0.1),
                      itemCount: 5,
                      itemSize: 40.0,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
                      itemBuilder: (context, _) => Icon(
                        selectedIcon ?? Icons.favorite_rounded,
                        color: const Color.fromRGBO(30, 209, 166, 1),
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          rating = rating;
                        });
                      },
                      updateOnDrag: true,
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text('하트를 눌러주세요'),
                const SizedBox(
                  height: 50,
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(53, 231, 189, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                  ),
                  child: const Text('OK'),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'WITHEND',
                  style: TextStyle(
                      color: Color.fromRGBO(30, 209, 166, 1),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
          );
        });
  }
}
