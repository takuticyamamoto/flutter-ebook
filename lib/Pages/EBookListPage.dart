import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebook/Pages/PDFScreen.dart';
import 'package:flutter_ebook/Pages/PDFXPage.dart';
import 'package:flutter_ebook/Services/pdf_list.dart';
import 'package:flutter_ebook/data/global.dart';
import 'package:badges/badges.dart' as badges;
import 'package:path/path.dart' as path;

class EBookListPage extends StatefulWidget {
  const EBookListPage({super.key});

  @override
  State<EBookListPage> createState() => _EbooklistpageState();
}

class _EbooklistpageState extends State<EBookListPage> {
  List<Map<String, String>> pdfFiles = [];
  List<String> purchedList = [];
  @override
  void initState() {
    super.initState();
    initiate();
    fetchPDFFiles();
    fetchPurchedList();
  }

  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> fetchPDFFiles() async {
    try {
      final fetchedPdfFiles = await getPdfList();
      setState(() {
        globalData.updatePDFFiles(fetchedPdfFiles);
        pdfFiles = fetchedPdfFiles;
      });
    } catch (e) {}
  }

  Future<void> fetchPurchedList() async {
    try {
      globalData.updateFreeBookList(await freeBookList());
      final fetchedPdfFiles = await getPurchedList(globalData.myUid);
      setState(() {
        purchedList = fetchedPdfFiles;
      });
    } catch (e) {}
  }

  initiate() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() {
      // pdfFiles = globalData.pdfFiles;
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
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width - 150,
                            child: TextButton(
                              style:
                                  ButtonStyle(alignment: Alignment.centerLeft),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(path.basenameWithoutExtension(
                                      pdfFiles[index]["name"] ?? "Unknown"))),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Pdfscreen(
                                        pdfName: pdfFiles[index]['name'] ?? '',
                                        pdfURL: pdfFiles[index]['url'] ?? '',
                                      );
                                    },
                                  ),
                                );
                              },
                            )),
                        SizedBox(
                            width: 60,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                  minimumSize: Size(10, 20),
                                  backgroundColor: globalData.freeBookList
                                          .contains(pdfFiles[index]["name"])
                                      ? Colors.green
                                      : purchedList
                                              .contains(pdfFiles[index]["name"])
                                          ? Colors.yellow
                                          : Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {},
                                child: Text(
                                  globalData.freeBookList
                                          .contains(pdfFiles[index]["name"])
                                      ? '無料'
                                      : purchedList
                                              .contains(pdfFiles[index]["name"])
                                          ? '購入済み'
                                          : '購入',
                                  style: TextStyle(fontSize: 10),
                                )))
                      ]),
                  // subtitle: Text(pdfFiles[index]["url"] ?? ""),
                );
              },
            ),
    );
  }
}
