//챗봇하고만 연결될 스크린
//유저 연결만 고쳐주면 됨.
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:withend/widgets/new_message.dart';
import 'package:withend/widgets/chat_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:withend/widgets/chatbot_new_message.dart';

class ChatbotScreen extends StatefulWidget {
  final String data;

  const ChatbotScreen(this.data, {super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final db = FirebaseFirestore.instance;
  String friendName = '';
  String userId = '';
  String friendId = '4s5FR2vQBMet6RhgDRxxkEZMGpm1';

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
    createChatroomId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("챗봇"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // endDrawer: sideMenu(context),
      body: Column(
        children: [
          Expanded(child: ChatMessages(chatroomId)),
          ChatbotNewMessage(chatroomId),
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
