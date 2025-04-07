import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ebook/Services/audio_service.dart';
import 'package:flutter_ebook/data/global.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'dart:math';

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
  String recordingPath = '';
  List<int> audioData = [];
  List<String> audioFiles = [];
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  //=================================================================              initiateState              ============================================================

  @override
  void initState() {
    super.initState();
    initiateState();
  }

  initiateState() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final fetchedAudioFiles = await getAudioFiles();
    setState(() {
      audioFiles = fetchedAudioFiles;
      print('$audioFiles=============');
    });
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
      List<int> _audioData = await _recordStop();
      setState(() {
        audioData = _audioData;
      });
      await showSaveConfirmation(context);
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
      bool fileExists = await doesFileExistWithTitle(titleController.text);
      if (fileExists) {
        _showOverwriteConfirmation(context, titleController.text);
        setState(() {
          initiateState();
        });
      } else {
        await saveAudioFile(audioData, titleController.text, DateTime.now());
        setState(() {
          initiateState();
        });
      }
    }
  }

  Future<bool> doesFileExistWithTitle(String title) async {
    String uid = globalData.myUid;
    Directory? directory =
        // await getExternalStorageDirectory(); // Use external storage
        await getApplicationDocumentsDirectory(); // Use external storage
    if (directory == null) throw Exception("No external storage available");
    Directory targetDir =
        Directory('${directory.path}/$uid/${globalData.currentPDFName}');

    final files = directory.listSync();
    for (var file in files) {
      if (file is File && file.uri.pathSegments.last.contains(title)) {
        return true; // File with the same title exists
      }
    }
    return false; // No file with the same title
  }

  void _showOverwriteConfirmation(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('File Already Exists'),
          content: Text(
              'A file with the title "$title" already exists. Do you want to overwrite it?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog and do nothing
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                // Proceed to overwrite the file
                await overwriteAudioFile(title);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without doing anything
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> overwriteAudioFile(String title) async {
    String uid = globalData.myUid;
    Directory? directory =
        // await getExternalStorageDirectory(); // Use external storage
        await getApplicationDocumentsDirectory(); // Use external storage
    if (directory == null) throw Exception("No external storage available");
    Directory targetDir =
        Directory('${directory.path}/$uid/${globalData.currentPDFName}');
    File('$targetDir/$title').deleteSync();

    await saveAudioFile(audioData, title, DateTime.now());
    initiateState();
    print('File "$title" has been overwritten');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Expanded(
        child: SizedBox(
          height: 50,
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

  Widget myRecode() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            initiateState();
            _show();
          },
          icon: Image.asset('assets/icons/reading.png', width: 40, height: 40),
        )
      ],
    );
  }

  void _show() async {
    SmartDialog.show(
        alignment: Alignment.centerRight,
        builder: (_) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_listDialog()],
            ),
          );
        });
  }

  Widget _listDialog() {
    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.93,
          width: 350,
          color: Colors.white,
          child: ListView(
            children: List.generate(audioFiles.length, (index) {
              return ListTile(
                title: TextButton(
                  child: Text(audioFiles[index]),
                  onPressed: () async {
                    await audioPlayer
                        .setFilePath(await getFilePath(audioFiles[index]));
                    audioPlayer.play();
                  },
                ),
                trailing: IconButton(
                  onPressed: () async {
                    await deleteFile(await getFilePath(audioFiles[index]));
                    await initiateState();
                    // Update both the main state and the dialog's state
                    setState(() {});
                    setStateDialog(() {});
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              );
            }),
          ),
        );
      },
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
