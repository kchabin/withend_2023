// import 'package:flutter/material.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final formKey = GlobalKey<FormState>();
//   var enteredEmail = '';
//   var enteredPassword = '';
//   var enteredName = '';

//   void _submit() {
//     final isValid = formKey.currentState!.validate();

//     if (isValid) {
//       formKey.currentState!.save();
//       //나중에 print하는 대신 firebase로 보낼 것
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(
//           color: Color.fromRGBO(30, 209, 166, 1),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           iconSize: 35,
//         ),
//       ),
//       body: Padding(
//         //화면 양 옆 패딩 설정
//         padding: const EdgeInsets.symmetric(
//           horizontal: 10,
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(
//                 height: 100,
//               ),
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     children: [
//                       Text(
//                         'Welcome!',
//                         style: TextStyle(
//                           color: Color.fromRGBO(30, 209, 166, 1),
//                           fontSize: 45,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         '나만의 소울메이트 찾기',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w300,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 70,
//               ),
//               SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Form(
//                     key: formKey,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         TextFormField(
//                           //name
//                           cursorColor: const Color.fromRGBO(53, 231, 189, 1),

//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: const Color.fromARGB(255, 247, 247, 247),
//                             prefixIcon: const Icon(
//                               Icons.text_format_rounded,
//                               color: Color.fromRGBO(30, 209, 166, 1),
//                             ),
//                             hintText: "Name",
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Color.fromRGBO(53, 231, 189, 1),
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return '필수 항목입니다.';
//                             }
//                             return null;
//                           },
//                           onSaved: (value) {
//                             enteredName = value!;
//                           },
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         TextFormField(
//                           //이메일
//                           cursorColor: const Color.fromRGBO(53, 231, 189, 1),
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: const Color.fromARGB(255, 247, 247, 247),
//                             prefixIcon: const Icon(
//                               Icons.person,
//                               color: Color.fromRGBO(30, 209, 166, 1),
//                             ),
//                             hintText: "E-mail",
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Color.fromRGBO(53, 231, 189, 1),
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null ||
//                                 value.trim().isEmpty ||
//                                 !value.contains('@')) {
//                               return '유효한 이메일이 아닙니다.';
//                             }
//                             return null;
//                           },
//                           onSaved: (value) {
//                             enteredEmail = value!;
//                           },
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         TextFormField(
//                           //password

//                           obscureText: true,

//                           cursorColor: const Color.fromRGBO(53, 231, 189, 1),

//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: const Color.fromARGB(255, 247, 247, 247),
//                             prefixIcon: const Icon(
//                               Icons.password_rounded,
//                               color: Color.fromRGBO(30, 209, 166, 1),
//                             ),
//                             hintText: "Password",
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Color.fromRGBO(53, 231, 189, 1),
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().length < 8) {
//                               return '비밀번호는 8자 이상이어야 합니다.';
//                             }
//                             return null;
//                           },
//                           onSaved: (value) {
//                             enteredPassword = value!;
//                           },
//                         ),
//                         const SizedBox(
//                           height: 50,
//                         ),
//                         ElevatedButton(
//                           onPressed: _submit,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 const Color.fromRGBO(53, 231, 189, 1),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 10, horizontal: 30),
//                           ),
//                           child: const Text(
//                             '회원가입',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
