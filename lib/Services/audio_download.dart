import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AudioDownloadScreen extends StatefulWidget {
  @override
  _AudioDownloadScreenState createState() => _AudioDownloadScreenState();
}

class _AudioDownloadScreenState extends State<AudioDownloadScreen> {
  final List<String> audioFiles = [
    "audio1.mp3",
    "audio2.mp3",
    "audio3.mp3",
    "audio4.mp3",
    "audio5.mp3",
    "audio6.mp3",
    // Add up to 30 file names
  ];

  double overallProgress = 0.0;
  int totalBytes = 0;
  int downloadedBytes = 0;
  Map<String, int> lastBytesTransferred = {}; // To track progress per file

  @override
  void initState() {
    super.initState();
    downloadAllAudioFiles(); // Auto-start download when screen loads
  }

  Future<void> downloadAllAudioFiles() async {
    setState(() {
      overallProgress = 0.0;
      totalBytes = 0;
      downloadedBytes = 0;
      lastBytesTransferred.clear();
    });

    // Preload total file sizes to calculate accurate total bytes
    await calculateTotalFileSize();

    // Start all downloads concurrently
    await Future.wait(audioFiles.map((file) => downloadSingleFile(file)));
  }

  Future<void> calculateTotalFileSize() async {
    int totalSize = 0;
    for (String fileName in audioFiles) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
          'audio/$fileName',
        );
        final metadata = await storageRef.getMetadata();
        totalSize += metadata.size ?? 0;
      } catch (e) {
        print("Error fetching metadata for $fileName: $e");
      }
    }
    setState(() {
      totalBytes = totalSize;
    });
  }

  Future<void> downloadSingleFile(String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'audio/$fileName',
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      final DownloadTask downloadTask = storageRef.writeToFile(file);

      lastBytesTransferred[fileName] = 0; // Initialize tracking

      downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        int currentTransferred = snapshot.bytesTransferred;
        int lastTransferred = lastBytesTransferred[fileName] ?? 0;

        // Only add the new bytes to avoid double-counting
        downloadedBytes += (currentTransferred - lastTransferred);
        lastBytesTransferred[fileName] = currentTransferred;

        setState(() {
          overallProgress =
              totalBytes == 0 ? 0.0 : downloadedBytes / totalBytes;
        });
      });

      await downloadTask; // Wait for file to fully download
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Downloading Audio Files")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 8.0,
              percent: overallProgress.clamp(
                0.0,
                1.0,
              ), // Ensures value is within 0-100%
              center: Text("${(overallProgress * 100).toStringAsFixed(1)}%"),
              progressColor: Colors.blue,
            ),
            SizedBox(height: 20),
            Text("Downloading ${audioFiles.length} files"),
          ],
        ),
      ),
    );
  }
}
