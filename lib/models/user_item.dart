//유저 정보에서 무엇이 필요한지
//아이디, 비밀번호, 이름, 자기소개

class UserItem {
  const UserItem({
    //어떤 요소를 데이터베이스에 저장할지
    required this.id,
    required this.password,
    required this.name,
    required this.selfIntro,
  });

  //각 요소의 데이터 타입
  final String id;
  final String password;
  final String name;
  final String selfIntro;
}
