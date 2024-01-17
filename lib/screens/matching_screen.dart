import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:withend/firebase.dart';
import 'package:withend/screens/result_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

//변수 모음
final db = FirebaseFirestore.instance;
String userName = ''; //유저이름
String selfIntro = ''; //유저 한줄소개
String userUid = ''; //current user uid
late Reference _ref; //유저 사진 받아올 reference
String userUrl = ''; //유저 사진 url
List<dynamic> friendList = []; //유저 친구 리스트 불러오기

List<dynamic> matchList = []; //매칭된 유저id 리스트
List<dynamic> matchName = []; //매칭된 유저 이름리스트
late Reference _matchRef; //매칭된 유저 사진 url받아올 reference
String matchUrl = ''; //매칭된 유저 사진 url
List<dynamic> matchIntro = []; //매칭된 유저 한줄소개 리스트
List<dynamic> matchImage = []; //요청 사진 url 목록
List<dynamic> sendRequestList = []; // 요청한 사람 목록

List<dynamic> requestList = []; //친구요청 중인 유저의 리스트
List<dynamic> requestName = []; //요청 이름 리스트
List<dynamic> requestIntro = []; //요청 한줄소개 리스트
String requestUrl = ''; //요청 사진 url input
List<dynamic> requestImage = []; //요청 사진 url 목록
late Reference _requestRef; //요청 사진 url 받아올 reference

late QuerySnapshot usersSnapshot;
List<dynamic> allUserList = []; //모든 user의 uid를 담아줄 리스트

Map<String, List> userprofile = {}; //친구추천 모델 api에 넣을 json 생성

bool _isMatchLoading = true; //매칭 창이 로딩 중인지
bool _isrequestLoading = true; // request창이 로딩 중인지

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
    _loadAllUser();
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
        friendList = data['friend_list'];
        sendRequestList = data['send_request'];
      });
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
    setState(() {
      _isrequestLoading = true;
    });
    for (int i = 0; i < requestList.length; i++) {
      var id = requestList[i];
      await getRequestInfo(id);
    }
    setState(() {
      _isrequestLoading = false;
    });
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
    setState(() {
      _isMatchLoading = true;
    });
    for (int i = 0; i < matchList.length; i++) {
      var id = matchList[i];
      await getMatchInfo(id);
    }
    setState(() {
      _isMatchLoading = false;
    });
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

  //매칭하기 버튼을 눌렀을 때 실행되는 함수
  Future<void> _pressButton() async {
    await _renewProfile(); //성향벡터 갱신
    await _recommendFriend(); //친구 추천
    getUserInfo();
    loadMatchInfo();
    loadRequestInfo();
  }

  //성향벡터 갱신
  Future<void> _renewProfile() async {
    var it = friendList.iterator;
    while (it.moveNext()) {
      //친구 리스트를 순회하면서 각 채팅방에 있는 대화를 추출한다.
      String friendId = it.current;
      String chatroomId = createChatroomId(userUid, friendId);

      // 유저 채팅을 검색
      final uidQuery =
          db.collection(chatroomId).where("userId", isEqualTo: userUid);
      QuerySnapshot userSnapshot = await uidQuery.get();
      List<dynamic> userChatList =
          userSnapshot.docs.map((doc) => doc['text']).toList();
      //유저 성향벡터 가져오기
      var userdata = await db.collection('users').doc(userUid).get();
      var userprofile = userdata['profile'];

      // 친구 채팅을 검색
      final friendQuery =
          db.collection(chatroomId).where("userId", isEqualTo: friendId);
      QuerySnapshot friendSnapshot = await friendQuery.get();
      List<dynamic> friendChatList =
          friendSnapshot.docs.map((doc) => doc['text']).toList();
      // 친구 성향벡터 가져오기
      var frienddata = await db.collection('users').doc(userUid).get();
      var friendprofile = frienddata['profile'];

      //json 파일 생성
      Map<String, List> profile = {
        userUid: userprofile,
        friendId: friendprofile
      };
      Map<String, List> text = {
        userUid: userChatList,
        friendId: friendChatList
      };

      Map<String, Map> profilejson = {"profile": profile, 'text': text};

      print('profilejson: $profilejson');
      //성향벡터추출 ai모델 api에 json 파일 전달
      var url = Uri.parse(
        'https://c8c6-35-229-21-94.ngrok-free.app',
      );
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(profilejson));

      var data = json.decode(response.body);
      print('matching_screen profile data: $data');

      //body에서 profile의 userprofile과 friendprofile분리해주기
      var new_userprofile = data["profile"][userUid];
      var new_friendprofile = data["profile"][friendId];

      //firebase에 업데이트
      await db.collection('users').doc(uid).update({
        'profile': new_userprofile,
      });
      await db.collection('users').doc(friendId).update({
        'profile': new_friendprofile,
      });
    }

    //유저 성향벡터 다시 불러와주기
    getUserInfo();
  }

  String createChatroomId(String userId, String friendId) {
    if (userId.compareTo(friendId) > 0) {
      return (userId + friendId);
    } else {
      return (friendId + userId);
    }
  }

  //친구 추천
  Future<void> _recommendFriend() async {
    await _loadAllUser();
    await _exceptFriend();
    await _RecommendJson();
    await _callRecommendAPI(userprofile);
    await getUserInfo();
  }

  //모든 유저의 uid를 불러오기
  Future<void> _loadAllUser() async {
    usersSnapshot = await db.collection('users').get();
    allUserList = profileSnapshot.docs.map((doc) => doc['userId']).toList();
    print(allUserList);
  }

  //유저의 친구들은 리스트에서 삭제시켜준다. 챗봇도 삭제해줄 것.
  Future<void> _exceptFriend() async {
    allUserList.remove('4s5FR2vQBMet6RhgDRxxkEZMGpm1');
    allUserList.remove('c5mHHofLi5YwOwuQA6TJ0MdCrSS2'); // 챗봇 삭제
    for (int i = 0; i < friendList.length; i++) {
      allUserList.remove(friendList[i]);
    }
    for (int i = 0; i < matchList.length; i++) {
      // 매칭리스트에 있는 사람 삭제
      allUserList.remove(matchList[i]);
    }
    if (requestList.isNotEmpty) {
      for (int i = 0; i < sendRequestList.length; i++) {
        //이미 요청 보낸 사람 삭제
        allUserList.remove(matchList[i]);
      }
    }
    for (int i = 0; i < requestList.length; i++) {
      //요청 온 사람 삭제
      allUserList.remove(requestList[i]);
    }
    print("유저 삭제한 후: $allUserList");
  }

  //유저의 uid에 따른 성향벡터를 모두 불러온다. api에 넣을 map 자료 만들기
  Future<void> _RecommendJson() async {
    var it = allUserList.iterator;

    while (it.moveNext()) {
      var data = await db.collection('users').doc(it.current).get();
      userprofile[it.current] = data['profile'];
    }
    print('recommendjson: $userprofile');
    print({
      "target_id": userUid,
      "profile": userprofile,
    });
  }

  //추천 친구 받기
  Future<void> _callRecommendAPI(Map<String, List> userprofile) async {
    //친구추천 api
    var url = Uri.parse(
      'http://10.0.2.2:5000',
    );
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "target_id": userUid,
          "profile": userprofile,
        }));

    var data = json.decode(response.body);
    print('matching_screedn data: $data');
    var newmatchList = data["recommended_users"];

    await db.collection('users').doc(uid).update({
      'match_list': newmatchList,
    });

    await getUserInfo();
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
                    await _pressButton();
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
                  ? _isMatchLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
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
                  ? _isrequestLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
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
class RequestList extends StatefulWidget {
  final int index;

  const RequestList({Key? key, required this.index}) : super(key: key);

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  // 여기에 필요한 변수를 추가하세요.
  // 예를 들면, matchList, matchImage, matchName, matchIntro 등이 있을 것입니다.

  @override
  void initState() {
    super.initState();
    // 필요한 초기화를 수행합니다.
  }

  // 친구요청 보내는 함수
  void sendFriendRequest(id) async {
    // matchList는 이제 _RequestListState의 상태로 가져와야 합니다.
    if (mounted) {
      setState(() {
        matchList.remove(id);
        sendRequestList.add(id);
      });
    }
    ;

    await db.collection('users').doc(userUid).update({
      'match_list': matchList,
    });

    List<dynamic> requestFriend = [];

    var result = await db.collection('users').doc(id).get();

    var data = result.data() as Map<String, dynamic>;
    requestFriend = data['request_list'];

    requestFriend.add(userUid);

    await db.collection('users').doc(id).update({
      'request_list': requestFriend,
    });

    // 필요하다면 여기에서 UI 업데이트를 위해 setState를 호출할 수 있습니다.
    var res = await db.collection('users').doc(userUid).get();
    if (res.exists) {
      var data = res.data() as Map<String, dynamic>;
      setState(() {
        matchList = data['match_list'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 아래의 matchImage, matchName, matchIntro는 해당 데이터를 가져올 수 있는 방법을 구현해야 합니다.
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(matchImage[widget.index]),
        radius: 30,
      ),
      title: Text(matchName[widget.index]),
      subtitle: Text(matchIntro[widget.index]),
      trailing: ElevatedButton(
        onPressed: () {
          sendFriendRequest(matchList[widget.index]);
          setState(() {
            sendRequestList.add(widget.index);
            matchList.remove(widget.index);
          });
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
