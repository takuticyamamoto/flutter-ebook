import 'package:flutter/services.dart';
import 'package:flutter_ebook/Pages/EBookListPage.dart';
import 'package:flutter_ebook/Pages/EPubScreen.dart';
import 'package:flutter_ebook/Pages/EmailVerificationPage.dart';
import 'package:flutter_ebook/Pages/PDFScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ebook/Pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook/Services/audio_download.dart';
import 'package:flutter_ebook/Services/percent_indigator.dart';
import 'package:flutter_ebook/data/global.dart';
import 'package:flutter_ebook/widgets/animation.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:flutter_ebook/Pages/Qr_Code_Scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ebook/widgets/business.dart';
import 'package:flutter_ebook/widgets/custome.dart';
import 'package:flutter_ebook/widgets/mydrawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  AudioPlayer audioPlayer = AudioPlayer();

  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      postedText = '',
      uid = 'default';

  @override
  void initState() {
    super.initState();
    initiate();
  }

  initiate() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final fetchedEmail = auth.currentUser!.email ?? email;
    final fetechedUid = auth.currentUser!.uid;
    print('$fetchedEmail,  ${fetechedUid}===========');
    setState(() {
      globalData.updateUser(fetchedEmail, fetechedUid);
      // pdfFiles = globalData.pdfFiles;
    });
  }

  @override
  void dispose() {
    // Reset to default orientation when exiting
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // final MobileScannerController controller = MobileScannerController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16.0),
              //   child: Image.network(
              //     'https://geographical.co.uk/wp-content/uploads/somalaya-mountain-range-title.jpg',
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'オエシネン湖キャンプ場',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'カンデレステグ、アイスランド',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.red[500]),
                          const Text('41'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AudioDownloadScreen(),
                            // (context) => EpubReaderScreen(filePath: ''),
                          ),
                        );
                      },
                      child: Text('get my data'),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EmailVerificationPage(),
                              // builder: (context) => AttachDialogBusiness(),
                            ),
                          );
                        },
                        child: Text('data')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EBookListPage(),
                            ),
                          );
                        },
                        child: Text('go to book')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
