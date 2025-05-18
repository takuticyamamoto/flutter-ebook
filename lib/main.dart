import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebook/Services/auth_gate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'package:flutter_ebook/data/global.dart';
import 'package:flutter_ebook/Services/pdf_list.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
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
        Locale('ja', 'JP'),
      ],
      path: 'assets/translations',
      startLocale: const Locale('en', 'US'),
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

    // fetchPDFFiles();
  }

  Future<void> fetchPDFFiles() async {
    try {
      final fetchedPdfFiles = await getPdfList();
      setState(() {
        globalData.pdfFiles = fetchedPdfFiles;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      localizationsDelegates: context.localizationDelegates,
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
