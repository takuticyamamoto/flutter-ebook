import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

void sendVerificationEmail() async {
  User? user = auth.currentUser;
  if (user != null) {
    String verificationCode = generateCode();

    // Store the verification code in Firestore
    await firestore.collection('Users').doc(user.uid).set({
      'verificationCode': verificationCode,
      'email': user.email,
      'verified': false,
    }, SetOptions(merge: true));

    // Trigger a Cloud Function to send an email
    await FirebaseFirestore.instance.collection('mailQueue').add({
      'to': user.email,
      'subject': 'Email Verification Code',
      'text': 'Your verification code is: $verificationCode',
    });

    print("Verification email sent.");
  }
}

// Generate a 6-digit random code
String generateCode() {
  Random random = Random();
  return (100000 + random.nextInt(900000)).toString();
}
