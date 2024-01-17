import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final db = FirebaseFirestore.instance;
String uid = FirebaseAuth.instance.currentUser!.uid;
final userDB = FirebaseFirestore.instance.collection('users');
