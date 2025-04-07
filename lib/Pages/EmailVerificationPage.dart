import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

// class EmailVerificationPage extends StatefulWidget {
//   @override
//   _EmailVerificationPageState createState() => _EmailVerificationPageState();
// }

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController emailController = TextEditingController();

  // Function to send confirmation code
  Future<void> sendConfirmationCode() async {
    try {
      final email = emailController.text.trim();

      // Call the Cloud Function
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'us-central1')
              .httpsCallable('sendConfirmationCode');
      final result = await callable.call(<String, dynamic>{
        'email': email,
      });
    } catch (e) {
      print("Error sending confirmation code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Email Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Enter Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            ElevatedButton(
              onPressed: () {
                sendConfirmationCode();
              },
              child: Text("Send Confirmation Code"),
            ),
          ],
        ),
      ),
    );
  }
}
