import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;

class EpubReaderScreen extends StatefulWidget {
  final String filePath; // EPUB file path

  EpubReaderScreen({required this.filePath});

  @override
  _EpubReaderScreenState createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    _epubController = EpubController(
      document: EpubDocument.openAsset('assets/books/burroughs-lost-continent.epub'), // Open the EPUB file
    );
  }

  Brightness get platformBrightness =>
      MediaQueryData.fromView(WidgetsBinding.instance.window)
          .platformBrightness;
  @override
  void didChangePlatformBrightness() {
    _setSystemUIOverlayStyle();
  }

  @override
  void _setSystemUIOverlayStyle() {
    if (platformBrightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey[850],
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: _epubController,
          builder: (chapter) => Text(
            chapter?.chapter?.Title?.replaceAll('\n', '').trim() ??
                'EPUB Reader',
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: EpubView(
        controller: _epubController, // Display the EPUB content
      ),
    );
  }
}
