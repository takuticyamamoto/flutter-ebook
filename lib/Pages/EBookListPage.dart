import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebook/Pages/PDFScreen.dart';
import 'package:flutter_ebook/Pages/PDFXPage.dart';
import 'package:flutter_ebook/Services/pdf_list.dart';
import 'package:flutter_ebook/data/global.dart';

class EBookListPage extends StatefulWidget {
  const EBookListPage({super.key});

  @override
  State<EBookListPage> createState() => _EbooklistpageState();
}

class _EbooklistpageState extends State<EBookListPage> {
  List<Map<String, String>> pdfFiles = [];
  @override
  void initState() {
    super.initState();
    fetchPDFFiles();
    initiate();
  }

  void dispose() {
    // Reset to default orientation when exiting
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> fetchPDFFiles() async {
    try {
      final fetchedPdfFiles = await listPDFFiles();
      setState(() {
        globalData.pdfFiles = fetchedPdfFiles;
        pdfFiles = fetchedPdfFiles;
      });
    } catch (e) {}
  }

  initiate() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() {
      pdfFiles = globalData.pdfFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("PDF Files"),
        backgroundColor: const Color.fromARGB(255, 54, 200, 244),
      ),
      body: pdfFiles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pdfFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(pdfFiles[index]["name"] ?? "Unknown"),
                  // subtitle: Text(pdfFiles[index]["url"] ?? ""),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          // return PDFXPage(
                          //   pdfName: pdfFiles[index]['name'] ?? '',
                          //   pdfURL: pdfFiles[index]['url'] ?? '',
                          // );

                          return Pdfscreen(
                            pdfName: pdfFiles[index]['name'] ?? '',
                            pdfURL: pdfFiles[index]['url'] ?? '',
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
