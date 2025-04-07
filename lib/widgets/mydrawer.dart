import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook/EtcPages/cookie.dart';
import 'package:flutter_ebook/EtcPages/termofuse.dart';
import 'package:flutter_ebook/Services/send_verification.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    super.key,
  });
  @override
  _MyDrawer createState() => _MyDrawer();
}

class _MyDrawer extends State<MyDrawer> {
  @override
  Future<void> deleteFileWithConfirmation(
    BuildContext context,
  ) async {
    bool isMounted = mounted;
    User? user = FirebaseAuth.instance.currentUser;
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: const Text('本当にこのアカウントを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User pressed Cancel
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User pressed Delete
              },
              child: const Text(
                '削除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      try {
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
        if (user != null) {
          await user.delete();
          print("Account deleted successfully");
        } else {
          print("No user is currently signed in.");
        }
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Drawer(
            width: MediaQuery.of(context).size.width * 0.4,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "設定",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    child: Text("利用規約"), //terms of service
                    onPressed: () async {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TermsOfUsePage(),
                        ),
                      );
                    },
                  ),

                  // ),
                  SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    child: Text("プライバシーポリシー"), //privacy policy
                    onPressed: () async {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CookieScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("get my data"),
                          const SizedBox(width: 10),
                          Icon(Icons.get_app_rounded)
                        ]),
                    onPressed: () async {
                      // Navigator.pop(context);
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => EtcScreen(),
                      //   ),
                      // );
                    },
                  ),
                  TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("ログアウト", style: TextStyle(color: Colors.red)),
                          const SizedBox(width: 10),
                          Icon(Icons.logout_outlined, color: Colors.red)
                        ],
                      ),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        await auth.signOut();
                        Navigator.pop(context);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                ]))));
  }
}
