import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebook/Pages/Audio_Record.dart';
import 'package:flutter_ebook/data/global.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Pdfscreen extends StatefulWidget {
  final String pdfURL;
  final String pdfName;
  const Pdfscreen({super.key, required this.pdfURL, required this.pdfName});

  @override
  State<Pdfscreen> createState() => _PdfxpageState();
}

class _PdfxpageState extends State<Pdfscreen> {
  //=================================================================              pdf              ============================================================

  String pdfPath = "";
  int totalPage = 1;
  int currentPage = 1;
  PdfControllerPinch pdfControllerPinch = PdfControllerPinch(
    document: PdfDocument.openAsset('assets/books/pdf.pdf'),
  );
  PDFViewController? pdfViewController;

  //=================================================================              initiate              ============================================================

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

    await loadPdf('http://192.168.133.183:5000/asdfas/audio_lesson_31_35.pdf');
    // await loadPdf(widget.pdfURL);
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {}

    setState(() {});
  }

  //=================================================================              pdf              ============================================================

  Future<String> createFileOfPdfUrl(String pdfURL) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final url = pdfURL;
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/${widget.pdfName}");
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
      return file.path;
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }

  Future<String?> cachePdf(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    return file.path; // Returns the cached file path
  }

  Future<void> loadPdf(String url) async {
    String? cachedPath = await cachePdf(url);
    if (cachedPath != null) {
      setState(() {
        pdfPath = cachedPath;
      });
      pdfControllerPinch = PdfControllerPinch(
        document: PdfDocument.openFile(cachedPath),
      );
    }
  }
  //=================================================================             widget             ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: Text(path.basenameWithoutExtension(widget.pdfName)),
            ),
            pageNavigation(),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 54, 200, 244),
        toolbarHeight: 40,
      ),
      body: Column(
        children: [
          Expanded(
              child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 50 - 70,
            child: pdfPath == ''
                ? const Center(child: CircularProgressIndicator())
                : pdfView(),
          )),
          AudioRecordScreen()
        ],
      ),
    );
  }

  Widget pdfView() {
    return
        //  Expanded(
        //   child:
        PdfViewPinch(
      scrollDirection: Axis.horizontal,
      controller: pdfControllerPinch,
      onDocumentLoaded: (doc) {
        setState(() {
          totalPage = doc.pagesCount;
        });
      },
      onPageChanged: (page) {
        setState(() {
          currentPage = page;
          globalData.currentPage = page;
        });
      },
      // ),
    );
  }

  Widget pageNavigation() {
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.2),
        IconButton(
          onPressed: () async {
            await pdfControllerPinch.previousPage(
              duration: Duration(microseconds: 200),
              curve: Curves.linear,
            );
            setState(() {
              currentPage = pdfControllerPinch.page;
            });
          },
          padding: EdgeInsets.zero,
          icon: Icon(Icons.skip_previous),
        ),
        Text('${currentPage.toString()}    /    ${totalPage}'),
        IconButton(
          onPressed: () async {
            await pdfControllerPinch.nextPage(
              duration: Duration(microseconds: 200),
              curve: Curves.linear,
            );
            setState(() {
              currentPage = pdfControllerPinch.page;
            });
          },
          padding: EdgeInsets.zero,
          icon: Icon(Icons.skip_next),
        ),
      ],
    );
  }
}
