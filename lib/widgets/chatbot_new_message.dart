//챗봇 쪽으로 이어지는 채팅화면
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class ChatbotNewMessage extends StatefulWidget {
  final String data;

  const ChatbotNewMessage(this.data);

  @override
  State<ChatbotNewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<ChatbotNewMessage> {
  final _messageController = TextEditingController();

  // void test() {
  //   // runApp(const MyApp());
  //   print("챗봇화면");
  //   String prompt = "What is elephant?";
  //   Future<String> data = generateText(prompt);
  //   data.then((value) {
  //     print(value);
  //   });
  // }

  //api 불러오기
  static const apiKey = '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';
  static const apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> generateText(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        'messages': [
          {
            "role": "assistant",
            "content":
                "너는 사람의 특성을 알아내기 위해 질문을 해야 해. 말은 3줄이 넘어가지 않아야 하고, 질문을 하면서 말을 끝내야 해. 친한 친구하고 채팅하듯이 편안한 분위기로 대화했으면 좋겠어. 최대한 많은 특성을 알아낼 수 있도록 대화의 화제를 빠르게 바꾸어야 해. 예를 들어서, 평소에 어떤 일을 많이 하는지 물어본 다음, 취미는 무엇이고, 좋아하는 음식은 무엇인지 바로바로 화제를 돌려주어야 해. 사람처럼 자연스럽게 이야기해 줘. '저는 인공지능입니다'이런 류의 이야기는 하지 않았으면 좋겠어."
          },
          {"role": "user", "content": prompt},
        ],
        'max_tokens': 1000,
        'temperature': 0,
        'top_p': 1,
        'frequency_penalty': 0,
        'presence_penalty': 0
      }),
    );

    Map<String, dynamic> newresponse =
        await jsonDecode(utf8.decode(response.bodyBytes));
    print('newresponse: $newresponse');

    // messages 배열의 마지막 항목의 content 키를 반환합니다.
    return newresponse['choices'][0]['message']['content'];
  }

  //chatgpt 호출하기
  Future<String> userChat(String userchat) async {
    String response = await generateText(userchat);
    print("Chatbot: $response");
    return response;
  }

  Future<void> saveChatbot(String response) async {
    await FirebaseFirestore.instance.collection('${widget.data}').add(
      {
        'text': response,
        'createdAt': Timestamp.now(),
        'userId': '4s5FR2vQBMet6RhgDRxxkEZMGpm1',

        //firestore에 저장된 데이터들. DocumentSnapshot
        'username': "챗봇",
        'userImage':
            'https://firebasestorage.googleapis.com/v0/b/withend-test.appspot.com/o/user_images%2F4s5FR2vQBMet6RhgDRxxkEZMGpm1.jpg?alt=media&token=26fda1fb-4c74-404b-b0bd-6d8a1c9d1ea9',
      },
    );
  }

  @override
  void dispose() {
    //컨트롤러가 차지한 메모리 리소스가 자유로워지도록
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    // 15개의 0 값을 가진 리스트 생성
    List<double> zeros = List.generate(15, (index) => 0);

    // -0.5에서 0.5 사이의 소수값으로 채워진 33개의 요소를 가진 리스트 생성
    List<double> randoms =
        List.generate(33, (index) => Random().nextDouble() - 0.5);

    // 두 리스트를 합침
    var profile = zeros + randoms;

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

    await FirebaseFirestore.instance.collection('${widget.data}').add(
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
    String response = await userChat(enteredMessage);
    await saveChatbot(response);
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
