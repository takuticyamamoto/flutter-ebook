import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebook/data/global.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PDFXPage extends StatefulWidget {
  final String pdfURL;
  final String pdfName;
  const PDFXPage({super.key, required this.pdfURL, required this.pdfName});

  @override
  State<PDFXPage> createState() => _PdfxpageState();
}

class _PdfxpageState extends State<PDFXPage> {
  //=================================================================              pdf              ============================================================

  String pdfPath = "";
  int totalPage = 1;
  int currentPage = 1;
  PdfControllerPinch pdfControllerPinch = PdfControllerPinch(
    document: PdfDocument.openAsset('assets/books/pdf.pdf'),
  );
  PDFViewController? pdfViewController;

  //=================================================================             audio             ============================================================

  bool isRecording = false;
  bool isRecordingPasued = false;
  bool isRecordPlaying = false;
  bool isRecordPaused = false;
  bool isMyRecordPlaying = false;
  bool isMyRecordPaused = false;
  bool isRecorderInitialized = false;
  // bool get _isRecording => audioRecorder!.isRecording;
  String recordingPath = '';

  // final player = CacheAudioPlayerPlus();
  // FlutterSoundRecorder? audioRecorder;
  // late final RecorderControll  er recorderController;

  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

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

    await loadPdf(widget.pdfURL);
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // throw RecordingPermissionException('Micorphone permission');
    }

    //------------------------------------------------------------------------------------------------

    // audioRecorder = FlutterSoundRecorder();
    // await audioRecorder!.openRecorder();
    isRecorderInitialized = true;
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

  //=================================================================             record             ============================================================
  _recordStart() async {
    if (await audioRecorder.hasPermission()) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, 'recording.wav');
      await audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav, // Ensure high-quality recording
          sampleRate: 44100, // Increase sample rate
          numChannels: 2, // Use stereo for better quality
          bitRate: 128000, // Increase bit rate
        ),
        path: filePath,
      );
      setState(() {
        isRecording = true;
        isRecordingPasued = false;
      });
    }
  }

  _recordStop() async {
    String? filePath = await audioRecorder.stop();
    if (filePath != null) {
      setState(() {
        isRecording = false;
        recordingPath = filePath;
        print(recordingPath);
      });
    }
  }

  _recordPause() async {
    if (!isRecorderInitialized) return;
    // await audioRecorder!.pauseRecorder();
  }

  //=================================================================             my audio             ============================================================

  _myAudioStart() async {
    await audioPlayer.setVolume(1.0);
    await audioPlayer.setFilePath(recordingPath);
    audioPlayer.play();
    setState(() {
      isMyRecordPlaying = true;
      isMyRecordPaused = false;
    });
  }

  Future _myAudioStop() async {
    if (!isRecorderInitialized) return;
    String? filePath = await audioRecorder.stop();
    if (filePath != null) {
      setState(() {
        isRecording = false;
        recordingPath = filePath;
      });
    }
  }

  Future _myAudioPause() async {
    if (!isRecorderInitialized) return;
    audioPlayer.pause();
    setState(() {
      isMyRecordPaused = true;
      isMyRecordPlaying = true;
    });
  }

  //=================================================================             my audio             ============================================================

  Future _bookAudioStart() async {
    if (await audioRecorder.hasPermission()) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, 'recording.wav');
      // await audioRecorder.start(const RecordConfig(), path: filepath);
      await audioRecorder.start(
        const RecordConfig(),
        path: 'assets/audios/audio4.mp3',
      );
      setState(() {
        isRecording = true;
        isRecordingPasued = false;
      });
    }
  }

  Future _bookAudioStop() async {
    if (!isRecorderInitialized) return;
    String? filePath = await audioRecorder.stop();
    if (filePath != null) {
      setState(() {
        isRecording = false;
        recordingPath = filePath;
      });
    }
  }

  Future _bookAudioPause() async {
    if (!isRecorderInitialized) return;
    // await audioRecorder!.pauseRecorder();
  }

  //=================================================================             dispose             ============================================================

  @override
  void dispose() {
    if (!isRecorderInitialized) return;
    // Reset to default orientation when exiting
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);

    // audioRecorder!.closeRecorder();
    isRecorderInitialized = false;
    super.dispose();
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 50 - 45,
            child: pdfPath == ''
                ? const Center(child: CircularProgressIndicator())
                : pdfView(),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: playRecord(),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: myRecode(),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: recordMe(),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget playRecord() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            setState(() {
              isMyRecordPaused = true;
              isRecordingPasued = true;
            });
            if (isRecordPaused && isRecordPlaying) {
              setState(() {
                isRecordPaused = false;
                isRecordPlaying = true;
              });
            } else if (!isRecordPaused && isRecordPlaying) {
              setState(() {
                isRecordPaused = true;
                isRecordPlaying = true;
              });
            } else {
              setState(() {
                isRecordPlaying = true;
                isRecordPaused = false;
              });
            }
          },
          padding: EdgeInsets.zero,
          icon: Icon(
            isRecordPlaying
                ? !isRecordPaused
                    ? Icons.pause
                    : Icons.play_arrow
                : Icons.play_arrow,
          ),
        ),
        isRecordPlaying
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isRecordPlaying = false;
                  });
                },
                padding: EdgeInsets.zero,
                icon: Icon(isRecordPlaying ? Icons.stop : Icons.pause),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  // icon: Image.asset('assets/icons/reading.png', width: 24, height: 24),
  Widget myRecode() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            setState(() {
              isRecordPaused = true;
              isRecordingPasued = true;
            });
            if (isMyRecordPaused && isMyRecordPlaying) {
              setState(() {
                isMyRecordPaused = false;
                isMyRecordPlaying = true;
              });
            } else if (!isMyRecordPaused && isMyRecordPlaying) {
              await _myAudioPause();
              // setState(() {
              //   isMyRecordPaused = true;
              //   isMyRecordPlaying = true;
              // });
            } else {
              await _myAudioStart();
              // setState(() {
              //   isMyRecordPlaying = true;
              //   isMyRecordPaused = false;
              // });
            }
          },
          padding: EdgeInsets.zero,
          icon: isMyRecordPlaying
              ? !isMyRecordPaused
                  ? Icon(Icons.pause_circle, color: Colors.blue)
                  : Icon(Icons.play_arrow, color: Colors.blue)
              : Image.asset(
                  'assets/icons/reading.png',
                  width: 24,
                  height: 24,
                ),
        ),
        isMyRecordPlaying
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isMyRecordPlaying = false;
                  });
                },
                padding: EdgeInsets.zero,
                icon: Icon(isMyRecordPlaying ? Icons.stop : Icons.pause),
                color: Colors.blue,
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget recordMe() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            setState(() {
              isMyRecordPaused = true;
              isRecordPaused = true;
            });
            if (isRecordingPasued && isRecording) {
              setState(() {
                isRecordingPasued = false;
                isRecording = true;
              });
            } else if (!isRecordingPasued && isRecording) {
              setState(() {
                isRecordingPasued = true;
                isRecording = true;
              });
            } else {
              await _recordStart();
            }
          },
          padding: EdgeInsets.zero,
          icon: isRecording
              ? !isRecordingPasued
                  ? Image.asset('assets/icons/podcast.gif')
                  : Icon(Icons.play_arrow, color: Colors.red)
              : Icon(Icons.mic, color: Colors.red),
        ),
        isRecording
            ? IconButton(
                onPressed: () async {
                  await _recordStop();
                },
                padding: EdgeInsets.zero,
                icon: Icon(
                  isRecording ? Icons.stop : Icons.pause,
                  color: Colors.red,
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
