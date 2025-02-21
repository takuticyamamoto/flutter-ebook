import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ebook/Services/save_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ebook/data/global.dart';

class AudioRecordScreen extends StatefulWidget {
  const AudioRecordScreen({super.key});

  @override
  State<AudioRecordScreen> createState() => _AudioRecordScreenState();
}

class _AudioRecordScreenState extends State<AudioRecordScreen> {
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
  List<int> audioData = [];
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

    //------------------------------------------------------------------------------------------------

    // audioRecorder = FlutterSoundRecorder();
    // await audioRecorder!.openRecorder();
    isRecorderInitialized = true;
    setState(() {});
  }

  //=================================================================             record             ============================================================

  _recordStart() async {
    if (await audioRecorder.hasPermission()) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, 'recording.wav');
      await audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        isRecording = true;
        isRecordingPasued = false;
      });
    }
  }

  Future<List<int>> _recordStop() async {
    String? filePath = await audioRecorder.stop();
    if (filePath != null) {
      File file = File(filePath);

      setState(() {
        isRecording = false;
        recordingPath = filePath;
      });
      return await file.readAsBytes(); // Converts file into byte data
    }
    return [];
  }

  _recordPause() async {
    await audioPlayer.pause();
    setState(() {
      isRecordingPasued = true;
      isRecording = true;
    });
    // await audioRecorder!.pauseRecorder();
  }

  //=================================================================             my audio             ============================================================

  _myAudioStart() async {
    print('play is called ');
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
      await audioRecorder.start(const RecordConfig(), path: filePath);
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
    if (!mounted) return;
    // Reset to default orientation when exiting
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);
    audioRecorder.stop();
    audioPlayer.stop();
    isRecorderInitialized = false;
    super.dispose();
  }

  //=================================================================             stop record confirmation             ============================================================

  Future<void> showStopConfirmation(BuildContext context) async {
    _recordPause();
    bool? shouldStop = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Stop Recording?'),
          content: const Text('Are you sure you want to stop the recording?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Stop', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldStop == true) {
      await showSaveConfirmation(context);
      List<int> _audioData = await _recordStop();
      setState(() {
        audioData = _audioData;
      });
      // await saveAudioFile(_audioData,  "my_audio.mp3");
    }
  }

  //=================================================================             save file confirmation             ============================================================

  Future<void> showSaveConfirmation(BuildContext context) async {
    bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Save Confirmation'),
          content: const Text('Do you want to save this recording?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      await showTitleDescriptionModal(context);
    }
  }

  //=================================================================             title and description          ============================================================

  Future<void> showTitleDescriptionModal(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    bool hasError = false;

    bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Save Recording'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      errorText: hasError ? 'Title is required' : null,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      setState(() => hasError = true); // Show error
                    } else {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  child:
                      const Text('Save', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      await saveAudioFile(
          audioData, '${titleController.text}-.-${new DateTime.timestamp()}');
      print('${new DateTime.timestamp()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Expanded(
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
    );
  }

  Widget playRecord() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            setState(() {
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
              // isRecordPaused = true;
              // isRecordingPasued = true;
            });
            if (isMyRecordPaused && isMyRecordPlaying) {
              setState(() {
                isMyRecordPaused = false;
                isMyRecordPlaying = true;
              });
            } else if (!isMyRecordPaused && isMyRecordPlaying) {
              await _myAudioPause();
            } else {
              await _myAudioStart();
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
              await _recordPause();
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
                  // ? Image.asset('assets/icons/podcast.gif')
                  : Icon(Icons.play_arrow, color: Colors.red)
              : Icon(Icons.mic, color: Colors.red),
        ),
        isRecording
            ? IconButton(
                onPressed: () async {
                  showStopConfirmation(context);
                  // await _recordStop();
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
