import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook/data/global.dart';
import 'package:path_provider/path_provider.dart';
import '../data/global.dart';
import 'package:path/path.dart';

Future<String> getFilePath(String title) async {
  String uid = globalData.myUid;
  Directory? directory =
      // await getExternalStorageDirectory(); // Use external storage
      await getApplicationDocumentsDirectory(); // Use external storage
  if (directory == null) throw Exception("No external storage available");
  String fullPath = "${directory.path}/$uid/${globalData.currentPDFName}";

  Directory(fullPath).create(recursive: true);
  return "$fullPath/$title.mp3";
}

Future<void> saveAudioFile(
    List<int> audioData, String title, DateTime datetime) async {
  try {
    String filePath = await getFilePath(title);
    File file = File(filePath);
    Directory fileDir = file.parent;
    if (!await fileDir.exists()) {
      await fileDir.create(
          recursive: true); // Create the directory if it doesn't exist
    }

    // saveMetadataToMP3(filePath, title, datetime);
    // Write in chunks to avoid memory overflow
    var sink = file.openWrite();
    sink.add(audioData);
    await sink.close();
    print("File saved at: $filePath");
  } catch (e) {
    print("Error saving file: $e");
  }
}

// void saveMetadataToMP3(String filePath, String title, DateTime datetime) async {
//   Tag tag = Tag(title: title, genre: datetime.toIso8601String(), pictures: [
//     Picture(
//         bytes: Uint8List.fromList([0, 0, 0, 0]),
//         mimeType: null,
//         pictureType: PictureType.other)
//   ]);
//   AudioTags.write(filePath, tag);

//   print("Metadata saved successfully to $filePath");
// }

Future<List<String>> getAudioFiles() async {
  try {
    String uid = globalData.myUid;
    String currentPDFName = globalData.currentPDFName;

    // Get the external storage directory
    // Directory? directory = await getExternalStorageDirectory();
    Directory? directory = await getApplicationDocumentsDirectory();
    // Directory? directory = await getApplicationDocumentsDirectory();
    if (directory == null) throw Exception("No external storage available");

    // Build the path to the specific folder
    Directory targetDir = Directory('${directory.path}/$uid/$currentPDFName');

    // Check if the directory exists
    if (!await targetDir.exists()) {
      throw Exception("Target directory does not exist.");
    }

    // List all files in the directory
    List<FileSystemEntity> files = targetDir.listSync();

    // Filter to only include audio files (e.g., .wav, .mp3, etc.)
    List<String> audioFiles = files
        .where((file) => file is File
            // && (file.path.endsWith('.wav') || file.path.endsWith('.mp3'))
            )
        .map((file) => basenameWithoutExtension(file.path))
        .toList();

    return audioFiles;
  } catch (e) {
    print("Error retrieving audio files: $e");
    return [];
  }
}

Future<void> deleteFile(String path) async {
  File file = File(path);

  if (await file.exists()) {
    await file.delete();
    print("File deleted: $path");
  } else {
    print("File not found: $path");
  }
}

// Call the function with your file path




