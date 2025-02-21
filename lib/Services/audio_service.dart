import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ebook/data/global.dart';
import 'package:path_provider/path_provider.dart';
import '../data/global.dart';

Future<String> getFilePath(String fileName) async {
  String uid = globalData.myUid;
  Directory? directory =
      await getExternalStorageDirectory(); // Use external storage
  if (directory == null) throw Exception("No external storage available");

  return "${directory.path}/$uid/${globalData.currentPDFName}/$fileName";
}

Future<void> saveAudioFile(
  List<int> audioData,
  String fileName,
) async {
  try {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);

    // Write in chunks to avoid memory overflow
    var sink = file.openWrite();
    sink.add(audioData);
    await sink.close();

    print("File saved at: $filePath");
  } catch (e) {
    print("Error saving file: $e");
  }

  Future<List<String>> getAudioFiles() async {
    try {
      String uid = globalData.myUid;
      String currentPDFName = globalData.currentPDFName;

      // Get the external storage directory
      Directory? directory = await getExternalStorageDirectory();
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
          .where((file) =>
              file is File &&
              (file.path.endsWith('.wav') || file.path.endsWith('.mp3')))
          .map((file) => file.path)
          .toList();

      return audioFiles;
    } catch (e) {
      print("Error retrieving audio files: $e");
      return [];
    }
  }
}
