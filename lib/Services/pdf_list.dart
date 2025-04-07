import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, String>>> getPdfList() async {
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

Future<List<String>> getPurchedList(String uid) async {
  try {
    print('$uid====================');
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();

    if (docSnapshot.exists) {
      List<dynamic> dynamicList = docSnapshot.get('purchedlist');
      List<String> purchedlist = dynamicList.cast<String>();

      print(purchedlist);
      return purchedlist;
    }
    return [''];
  } catch (e) {
    print("Error checking purchase: $e");
    return [''];
  }
}

Future<List<String>> freeBookList() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("freebooklist").get();

    List<String> bookIds = querySnapshot.docs.map((doc) => doc.id).toList();
    print(bookIds);
    return bookIds;
  } catch (e) {
    print("Error fetching free book list: $e");
    return [];
  }
}
