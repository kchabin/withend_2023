import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final String data;

  const NewMessage(this.data);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    //컨트롤러가 차지한 메모리 리소스가 자유로워지도록
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!; //현재 로그인 된 유저에게 권한을 줌

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    //파이어스토어에 http 요청 -> users 컬렉션, user.uid 문서에 저장된 데이터를 검색하게 됨.
    
    FirebaseFirestore.instance.collection('${widget.data}').add(
      {
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,

        //firestore에 저장된 데이터들. DocumentSnapshot
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
      },
    );
    //send to Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: '메시지 입력'),
              keyboardType: TextInputType.text,
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            color: const Color.fromRGBO(30, 209, 166, 1),
            icon: const Icon(Icons.near_me_rounded),
          ),
        ],
      ),
    );
  }
}
