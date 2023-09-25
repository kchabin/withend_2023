//매칭된 사람들 목록 보여주기
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withend/screens/friend_list.dart';
import 'package:withend/screens/matching_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<dynamic> data;

  const ResultScreen(this.data);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final db = FirebaseFirestore.instance;
  late String userUid = ''; //current user uid
  late String userName = ''; //유저이름

  List<dynamic> matchNameList = []; //매칭된 사람들의 이름
  List<dynamic> matchIntroList = []; //매칭된 사람들의 한줄소개
  List<dynamic> matchImage = []; //매칭된 사람들의 image url
  late Reference _matchRef;
  late String matchUrl = '';
  List<dynamic> matchId = []; //매칭된 사람들의 id

  @override
  void initState() {
    super.initState();
    matchId = widget.data;
    userUid = FirebaseAuth.instance.currentUser!.uid;
    loadMatchInfo();
    getUserName();
  }

  Future<void> getUserName() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var result = await db.collection('users').doc(uid).get();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        userName = data['username'];
      });
    } else {
      setState(() {
        userName = '사용자 이름 없음';
      });
    }
  }

  Future<void> loadMatchInfo() async {
    for (int i = 0; i < matchId.length; i++) {
      var id = matchId[i];
      await _getMatchData(id);
    }
  }

  //매칭된 사람들 데이터 가져와주기
  Future<void> _getMatchData(String id) async {
    var result = await db.collection("users").doc(id.trim()).get();
    _matchRef = FirebaseStorage.instance.ref().child('user_images/$id.jpg');
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      matchUrl = await _matchRef.getDownloadURL();
      setState(() {
        matchNameList.add(data['username']);
        matchIntroList.add(data['self_intro']);
        matchImage.add(matchUrl);
      });
    } else {
      print("변수에 존재하는 값이 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('data: ${widget.data}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromRGBO(30, 209, 166, 1),
        title: const Text(
          'WITHEND',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color.fromRGBO(30, 209, 166, 1),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AI 추천결과',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                    color: Color.fromRGBO(30, 209, 166, 1)),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$userName님의 추천 친구',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(30, 209, 166, 1),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 80,
          ),
          Expanded(
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color.fromRGBO(53, 231, 189, 1),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              matchNameList[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            CircleAvatar(
                              backgroundImage: NetworkImage(matchImage[index]),
                              radius: 65,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              //user.selfIntro,
                              matchIntroList[index],
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                      width: 40,
                    ),
                itemCount: 3),
          ),
        ],
      ),
    );
  }
}
