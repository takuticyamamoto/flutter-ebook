import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFPreviewScreen extends StatefulWidget {
  @override
  _PDFPreviewScreenState createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends State<PDFPreviewScreen> {
  String pathPDF = "";
  String landscapePathPdf = "";
  String remotePDFpath = "";
  String corruptedPathPDF = "";

  @override
  void initState() {
    super.initState();
    fromAsset(
      'assets/books/Shigoto_no_nihongo_IT_Gyoumuhen.pdf',
      'pdf.pdf',
    ).then((f) {
      setState(() {
        corruptedPathPDF = f.path;
      });
    });
    fromAsset(
      'assets/books/Shigoto_no_nihongo_IT_Gyoumuhen.pdf',
      'pdf.pdf',
    ).then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
    fromAsset(
      'assets/books/Shigoto_no_nihongo_IT_Gyoumuhen.pdf',
      'pdf.pdf',
    ).then((f) {
      setState(() {
        landscapePathPdf = f.path;
      });
    });

    createFileOfPdfUrl('').then((f) {
      setState(() {
        remotePDFpath = f.path;
      });
    });
  }

  Future<File> createFileOfPdfUrl(String pdfURL) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = pdfURL;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF View',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Builder(
            builder: (BuildContext context) {
              return Column(
                children: <Widget>[
                  TextButton(
                    child: Text("Open PDF"),
                    onPressed: () {
                      if (pathPDF.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFScreen(pdfURL: pathPDF),
                          ),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: Text("Open Landscape PDF"),
                    onPressed: () {
                      if (landscapePathPdf.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PDFScreen(pdfURL: landscapePathPdf),
                          ),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: Text("Remote PDF"),
                    onPressed: () {
                      if (remotePDFpath.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PDFScreen(pdfURL: remotePDFpath),
                          ),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: Text("Open Corrupted PDF"),
                    onPressed: () {
                      if (pathPDF.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PDFScreen(pdfURL: corruptedPathPDF),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String pdfURL;

  PDFScreen({super.key, required this.pdfURL});

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    print(widget.pdfURL);
    return Scaffold(
      appBar: AppBar(
        title: Text("Document"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            // filePath: widget.path,
            filePath: widget.pdfURL,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            backgroundColor: Colors.black,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: ${page ?? 0 + 1}/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(child: CircularProgressIndicator())
                  : Container()
              : Center(child: Text(errorMessage)),
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              label: Text("Go to ${pages! ~/ 2}"),
              onPressed: () async {
                await snapshot.data!.setPage(pages! ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
