import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:withend/firebase.dart';
import 'package:withend/screens/result_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

//변수 모음
final db = FirebaseFirestore.instance;
late String userName = ''; //유저이름
late String selfIntro = ''; //유저 한줄소개
late String userUid = ''; //current user uid
late Reference _ref; //유저 사진 받아올 reference
late String userUrl = ''; //유저 사진 url

List<dynamic> matchList = []; //매칭된 유저id 리스트
List<dynamic> matchName = []; //매칭된 유저 이름리스트
late Reference _matchRef; //매칭된 유저 사진 url받아올 reference
late String matchUrl = ''; //매칭된 유저 사진 url
List<dynamic> matchIntro = []; //매칭된 유저 한줄소개 리스트
List<dynamic> matchImage = []; //요청 사진 url 목록

List<dynamic> requestList = []; //친구요청 중인 유저의 리스트
List<dynamic> requestName = []; //요청 이름 리스트
List<dynamic> requestIntro = []; //요청 한줄소개 리스트
late String requestUrl = ''; //요청 사진 url input
List<dynamic> requestImage = []; //요청 사진 url 목록
late Reference _requestRef; //요청 사진 url 받아올 reference

//json에 들어갈 데이터를 만들기 위한 변수
var matchJson = {};
late QuerySnapshot profileSnapshot;

class _MatchingScreenState extends State<MatchingScreen> {
  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser!.uid;
    _ref = FirebaseStorage.instance.ref().child('user_images/$userUid.jpg');
    userUrl = ''; // userUrl 초기화 추가
    getUserInfo();
    loadMatchInfo();
    loadRequestInfo();
    loadProfile();
  }

  Future<void> getUserInfo() async {
    var result = await db.collection('users').doc(userUid).get();
    String url = await _ref.getDownloadURL();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      setState(() {
        userName = data['username'];
        matchList = data['match_list'];
        requestList = data['request_list'];
      });
      print(requestList);
      // await loadMatchInfo();
      // await loadRequestInfo();
    } else {
      setState(() {
        userName = '사용자 이름 없음';
        selfIntro = '';
      });
    }
  }

  Future<void> loadRequestInfo() async {
    for (int i = 0; i < requestList.length; i++) {
      var id = requestList[i];
      await getRequestInfo(id);
    }
  }

  Future<void> getRequestInfo(String id) async {
    var result = await db.collection("users").doc(id.trim()).get();
    _requestRef = FirebaseStorage.instance.ref().child('user_images/$id.jpg');
    requestUrl = await _requestRef.getDownloadURL();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      requestUrl = await _requestRef.getDownloadURL();
      setState(() {
        requestName.add(data['username']);
        requestIntro.add(data['self_intro']);
        requestImage.add(requestUrl);
      });
    } else {
      print("변수에 존재하는 값이 없습니다.");
    }
  }

  Future<void> loadMatchInfo() async {
    for (int i = 0; i < matchList.length; i++) {
      var id = matchList[i];
      await getMatchInfo(id);
    }
  }

  Future<void> getMatchInfo(String id) async {
    var result = await db.collection("users").doc(id.trim()).get();
    _matchRef = FirebaseStorage.instance.ref().child('user_images/$id.jpg');
    matchUrl = await _matchRef.getDownloadURL();
    if (result.exists) {
      var data = result.data() as Map<String, dynamic>;
      matchUrl = await _matchRef.getDownloadURL();
      setState(() {
        matchName.add(data['username']);
        matchIntro.add(data['self_intro']);
        matchImage.add(matchUrl);
      });
    } else {
      print("변수에 존재하는 값이 없습니다.");
    }
  }

  Future<void> loadProfile() async {
    try {
      profileSnapshot = await db.collection('users').get();
      List<dynamic> profiles =
          profileSnapshot.docs.map((doc) => doc['profile']).toList();
    } catch (e) {
      print("Error fetching profiles: $e");
    }
  }

  Future<void> _callRecommendAPI() async {
    var url = Uri.parse(
      'http://10.0.2.2:5000',
    );
    var response = await http.get(url);
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    url = Uri.parse('http://10.0.2.2:5000');
    response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "target_id": userUid,
          "profile": {
            "Ayw2wcuID3QOJrUB2teGVXFEz0g2": [
              0.34,
              0.89,
              0.52,
              0.11,
              0.96,
              0.47,
              0.82,
              0.66,
              0.44,
              0.29,
              0.65,
              0.99,
              0.49,
              0.78,
              0.68,
              0.39,
              0.70,
              0.57,
              0.22,
              0.87,
              0.35,
              0.26,
              0.61,
              0.14,
              0.73,
              0.92,
              0.04,
              0.31,
              0.58,
              0.17,
              0.88,
              0.74,
              0.15,
              0.90,
              0.27,
              0.50,
              0.83,
              0.06,
              0.59,
              0.81,
              0.72,
              0.55,
              0.13,
              0.94,
              0.76,
              0.07,
              0.93,
              0.41
            ],
            "goIqwojKWKbdAtt94ijtWSuxdY42": [
              0.28,
              0.63,
              0.32,
              0.45,
              0.19,
              0.37,
              0.12,
              0.86,
              0.05,
              0.67,
              0.85,
              0.43,
              0.60,
              0.64,
              0.21,
              0.02,
              0.71,
              0.97,
              0.80,
              0.20,
              0.42,
              0.54,
              0.01,
              0.77,
              0.53,
              0.03,
              0.95,
              0.84,
              0.10,
              0.25,
              0.98,
              0.91,
              0.69,
              0.24,
              0.79,
              0.18,
              0.33,
              0.51,
              0.36,
              0.56,
              0.46,
              0.75,
              0.09,
              0.38,
              0.16,
              0.23,
              0.62,
              0.40
            ],
            "jdy47UGlf9OWzWKwP79qZWGSaed2": [
              0.30,
              0.08,
              0.34,
              0.48,
              0.57,
              0.13,
              0.27,
              0.15,
              0.52,
              0.65,
              0.93,
              0.60,
              0.29,
              0.46,
              0.36,
              0.17,
              0.55,
              0.78,
              0.32,
              0.47,
              0.58,
              0.28,
              0.41,
              0.21,
              0.44,
              0.31,
              0.37,
              0.63,
              0.25,
              0.70,
              0.56,
              0.54,
              0.19,
              0.53,
              0.14,
              0.64,
              0.79,
              0.20,
              0.73,
              0.50,
              0.24,
              0.12,
              0.69,
              0.67,
              0.35,
              0.10,
              0.49,
              0.42
            ],
            "k3gtdy8zR8dzDg4J1qPfcrVrxYz1": [
              0.04,
              0.18,
              0.09,
              0.39,
              0.72,
              0.33,
              0.22,
              0.76,
              0.81,
              0.38,
              0.45,
              0.66,
              0.74,
              0.59,
              0.11,
              0.03,
              0.77,
              0.43,
              0.51,
              0.68,
              0.40,
              0.23,
              0.75,
              0.61,
              0.80,
              0.16,
              0.26,
              0.71,
              0.05,
              0.06,
              0.07,
              0.08,
              0.82,
              0.62,
              0.89,
              0.87,
              0.02,
              0.01,
              0.96,
              0.92,
              0.94,
              0.84,
              0.88,
              0.86,
              0.90,
              0.85,
              0.83,
              0.95
            ],
            "xXfED21vBxdCiOIV3VoXh3lFxZZ2": [
              0.99,
              0.00,
              0.91,
              0.34,
              0.35,
              0.36,
              0.31,
              0.32,
              0.33,
              0.25,
              0.26,
              0.27,
              0.21,
              0.22,
              0.23,
              0.15,
              0.16,
              0.17,
              0.10,
              0.11,
              0.12,
              0.05,
              0.06,
              0.07,
              0.98,
              0.96,
              0.97,
              0.90,
              0.88,
              0.89,
              0.80,
              0.82,
              0.83,
              0.75,
              0.76,
              0.77,
              0.69,
              0.70,
              0.71,
              0.60,
              0.62,
              0.63,
              0.55,
              0.56,
              0.57,
              0.45,
              0.46,
              0.47
            ],
          }
        }));

    var data = json.decode(response.body);
    matchList = data["recommended_users"];
    print('api안에서 matchlist: $matchList');

    await db.collection('users').doc(uid).update({
      'match_list': matchList,
    });

    getUserInfo();
    print('추천리스트: $matchList');
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width * 0.07;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/puzzle80.png',
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.08,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 42,
                    ),
                    Text(
                      'With Friend',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(53, 231, 189, 1),
                      ),
                    ),
                    const Text('관심사가 비슷한 새로운 친구를 만나보세요')
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _callRecommendAPI();
                    List<dynamic> data = matchList;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(data),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(53, 231, 189, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0.5,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                  ),
                  child: const Text(
                    '친구 매칭하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(
              children: [
                Text(
                  'Request',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(53, 231, 189, 1),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade200, thickness: 1.0),
            Expanded(
              child: matchList.isNotEmpty
                  ? ListView.builder(
                      itemCount: matchList.length,
                      itemBuilder: (context, index) {
                        return RequestList(index: index);
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 50.0,
                            color: Color.fromRGBO(53, 231, 189, 1),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "친구를 매칭해주세요!",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(53, 231, 189, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(color: Colors.grey.shade200, thickness: 1.0),
            const Row(
              children: [
                Text(
                  'Accept',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(53, 231, 189, 1),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade200, thickness: 1.0),
            Expanded(
              child: requestList.isNotEmpty
                  ? ListView.builder(
                      itemCount: requestList.length,
                      itemBuilder: (context, index) {
                        return AcceptList(index: index);
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 50.0,
                            color: Color.fromRGBO(53, 231, 189, 1),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "아직 친구 요청이 없어요",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(53, 231, 189, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

//다른 사람한테 친구 요청하는 리스트
class RequestList extends StatelessWidget {
  final int index;

  const RequestList({Key? key, required this.index}) : super(key: key);

  //친구요청 보내는 함수
  void sendFriendRequest(id) async {
    matchList.remove(id);

    await db.collection('users').doc(userUid).update({
      'match_list': matchList,
    });

    List<dynamic> requestFreind = [];

    var result = await db.collection('users').doc(id).get();

    var data = result.data() as Map<String, dynamic>;
    requestFreind = data['request_list'];

    requestFreind.add(userUid);

    //파이어베이스 업데이트할 때 리스트에 붙여넣는거 있는지 알아보기
    await db.collection('users').doc(id).update({
      'request_list': requestFreind,
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        'request에서 \n matchlist: $matchList \n matchname: $matchName \n matchintro: $matchIntro \n matchImage: $matchImage');

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(matchImage[index]),
        radius: 30,
      ),
      title: Text(matchName[index]),
      subtitle: Text(matchIntro[index]),
      trailing: ElevatedButton(
        onPressed: () {
          sendFriendRequest(matchList[index]);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(53, 231, 189, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0.5,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
        child: const Text(
          '요청하기',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

//다른 사람한테 친구 요청받는 list
class AcceptList extends StatelessWidget {
  final int index;

  const AcceptList({Key? key, required this.index}) : super(key: key);

  void acceptRequest(id) async {
    requestList.remove(id);

    List<dynamic> userFriend = [];
    List<dynamic> idFriend = [];

    var idresult = await db.collection('users').doc(id).get(); //상대방의 친구리스트
    var userresult =
        await db.collection('users').doc(userUid).get(); //유저의 친구리스트

    var iddata = idresult.data() as Map<String, dynamic>;
    var userdata = userresult.data() as Map<String, dynamic>;

    idFriend = iddata['friend_list'];
    userFriend = userdata['friend_list'];

    userFriend.add(id);
    idFriend.add(userUid);

    await db.collection('users').doc(id).update({
      'friend_list': idFriend,
    });
    await db.collection('users').doc(userUid).update({
      'friend_list': userFriend,
      'request_list': requestList,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(requestImage[index]),
        radius: 30,
      ),
      title: Text(requestName[index]),
      subtitle: Text(requestIntro[index]),
      trailing: ElevatedButton(
        onPressed: () {
          acceptRequest(requestList[index]);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(53, 231, 189, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0.5,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
        child: const Text(
          '수락하기',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
