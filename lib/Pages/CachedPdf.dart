// import 'package:flutter/material.dart';

// import 'package:pdfviewerplugin/pdfviewerplugin.dart';

// import 'package:pathprovider/pathprovider.dart';

// import 'package:path/path.dart';

// import 'package:http/http.dart' as http;

// class PdfViewerScreen extends StatefulWidget {

// @override

// PdfViewerScreen createState() => PdfViewerScreen();

// }

// class _PdfViewerScreen extends State {

// String _pdfUrl = 'https://example.com/example.pdf';

// String _cachedPdfPath;

// @override

// void initState() {

// super.initState();

// _loadCachedPdf();

// }

// _loadCachedPdf() async {

// final directory = await getApplicationDocumentsDirectory();

// final filePath = join(directory.path, 'example.pdf');

// final file = File(filePath);

// if (await file.exists()) {

// setState(() {

// _cachedPdfPath = filePath;

// });

// } else {

// final response = await http.get(Uri.parse(_pdfUrl));

// await file.writeAsBytes(response.bodyBytes);

// setState(() {

// _cachedPdfPath = filePath;

// });

// }

// }

// @override

// Widget build(BuildContext context) {

// return Scaffold(

// appBar: AppBar(

// title: Text('PDF Viewer'),

// ),

// body: _cachedPdfPath != null

// ? PdfViewer(

// filePath: _cachedPdfPath,

// )

// : Center(

// child: CircularProgressIndicator(),

// ),

// );

// }

// }