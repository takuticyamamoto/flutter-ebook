import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ebook_app/Services/auth_gate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
        Locale('ja', 'JP')
      ],
      path: 'assets/translations',
      startLocale: const Locale('ja', 'JP'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String pathPDF = "";
  String landscapePathPdf = "";
  String remotePDFpath = "";
  String corruptedPathPDF = "";
  @override
  void initState() {
    super.initState();
    // fromAsset('assets/books/Shigoto_no_nihongo_IT_Gyoumuhen.pdf', 'corrupted.pdf').then((f) {
    //   setState(() {
    //     corruptedPathPDF = f.path;
    //   });
    // });
    // fromAsset('assets/books/Shigoto_no_nihongo_IT_Gyoumuhen.pdf', 'demo.pdf').then((f) {
    //   setState(() {
    //     pathPDF = f.path;
    //   });
    // });
    // fromAsset('assets/books/Shigoto_no_nihongo_IT_Gyoumuhen.pdf', 'landscape.pdf').then((f) {
    //   setState(() {
    //     landscapePathPdf = f.path;
    //   });
    // });

    // createFileOfPdfUrl().then((f) {
    //   setState(() {
    //     remotePDFpath = f.path;
    //   });
    // });
  }

  // Future<File> createFileOfPdfUrl() async {
  //   Completer<File> completer = Completer();
  //   print("Start download file from internet!");
  //   try {
  //     // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
  //     // final url = "https://pdfkit.org/docs/guide.pdf";
  //     final url = "http://www.pdf995.com/samples/pdf.pdf";
  //     final filename = url.substring(url.lastIndexOf("/") + 1);
  //     var request = await HttpClient().getUrl(Uri.parse(url));
  //     var response = await request.close();
  //     var bytes = await consolidateHttpClientResponseBytes(response);
  //     var dir = await getApplicationDocumentsDirectory();
  //     print("Download files");
  //     print("${dir.path}/$filename");
  //     File file = File("${dir.path}/$filename");

  //     await file.writeAsBytes(bytes, flush: true);
  //     completer.complete(file);
  //   } catch (e) {
  //     throw Exception('Error parsing asset file!');
  //   }

  //   return completer.future;
  // }

  // Future<File> fromAsset(String asset, String filename) async {
  //   // To open from assets, you can copy them to the app storage folder, and the access them "locally"
  //   Completer<File> completer = Completer();

  //   try {
  //     var dir = await getApplicationDocumentsDirectory();
  //     File file = File("${dir.path}/$filename");
  //     var data = await rootBundle.load(asset);
  //     var bytes = data.buffer.asUint8List();
  //     await file.writeAsBytes(bytes, flush: true);
  //     completer.complete(file);
  //   } catch (e) {
  //     throw Exception('Error parsing asset file!');
  //   }

  //   return completer.future;
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates:
          context.localizationDelegates, // Now context is initialized properly
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: AuthGate(),
    );
  }
}
