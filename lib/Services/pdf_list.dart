import 'package:firebase_storage/firebase_storage.dart';

Future<List<Map<String, String>>> listPDFFiles() async {
  FirebaseStorage storage = FirebaseStorage.instance;
  List<Map<String, String>> pdfFiles = [];

  try {
    // Reference to the folder where PDFs are stored (e.g., 'pdfs/')

    final storageRef = storage.ref().child("books/");
    final result = await storageRef.listAll();

    for (var item in result.items) {
      // Get download URL for each file
      final url = await item.getDownloadURL();
      pdfFiles.add({"name": item.name, "url": url});
    }
  } catch (e) {
    print("Error fetching PDFs: $e");
  }
  return pdfFiles;
}
