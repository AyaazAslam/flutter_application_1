import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MyAudioController extends GetxController {
  static MyAudioController get to => Get.find();

  bool isRecording = false;
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  String total = "";

  late final AudioPlayerService _audioPlayerService;
  bool isRecordPlaying = false;
  int currentId = 999999;
  var completedPercentage = 0.0;
  var currentDuration = 0;
  var totalDuration = 0;
  var remainingDuration = 0;

  @override
  void onInit() {
    _audioPlayerService = AudioPlayerAdapter();

    _audioPlayerService.getAudioPlayer.onDurationChanged.listen((duration) {
      totalDuration = duration.inSeconds;
      remainingDuration = duration.inSeconds;
      update();
    });

    _audioPlayerService.getAudioPlayer.onPositionChanged.listen((duration) {
      currentDuration = duration.inSeconds;
      remainingDuration = totalDuration - currentDuration;
      completedPercentage = currentDuration / totalDuration;
      update();
    });

    _audioPlayerService.getAudioPlayer.onPlayerComplete.listen((event) async {
      await _audioPlayerService.getAudioPlayer.seek(Duration.zero);
      isRecordPlaying = false;
      currentDuration = 0;
      remainingDuration = totalDuration;
      completedPercentage = 0.0;
      update();
    });

    super.onInit();
  }

  void changeRecordingStatus(bool v) {
    isRecording = v;
    update();
  }

  final Record _audioRecorder = Record();
  String? _recordedFilePath;
  Future<bool> checkPermissions() async {
    PermissionStatus micStatus = await Permission.microphone.request();

    if (micStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> startRecording() async {
    bool hasPermission = await checkPermissions();
    if (!hasPermission) {
      print("Permission denied");
      return;
    }

    Directory tempDir = await getTemporaryDirectory();
    String filePath =
        '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      path: filePath,
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
    );

    isRecording = true;
    _recordedFilePath = filePath;
    print(_recordedFilePath);
    update();
  }

  Future<void> stopRecording(String name, String chatID) async {
    String? path = await _audioRecorder.stop();

    end = DateTime.now();
    calcDuration();

    if (path != null) {
      File audioFile = File(path);
      final String fileName =
          "UserAudios/${DateTime.now().microsecondsSinceEpoch}.m4a";
      final reference = FirebaseStorage.instance.ref().child(fileName);

      await reference.putFile(audioFile);

      String downloadUrl = await reference.getDownloadURL();
      print("Audio uploaded successfully: $downloadUrl");

      onSendMessage(downloadUrl, "audio", total, name, chatID);
    }
  }

  void calcDuration() {
    var a = end.difference(start).inSeconds;
    total = "$a";
    print(total);
    update();
  }

  void onSendMessage(String msg, String type, String audioDuration, String name,
      String? chtId) async {
    Map<String, dynamic> messages = {
      "sendBy": StaticData.userModel!.userName,
      "recievBy": name,
      "message": msg,
      "time": FieldValue.serverTimestamp(),
      "type": type,
      "duration": audioDuration
    };

    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chtId)
        .collection("chats")
        .add(messages);
  }

  Future<void> _pauseRecord() async {
    isRecordPlaying = false;
    update();
    await _audioPlayerService.pause();
  }

  String getRemainingTime() {
    return "${remainingDuration}s";
  }

  void onPressedPlayButton(int id, String content) async {
    currentId = id;
    if (isRecordPlaying) {
      await _pauseRecord();
    } else {
      isRecordPlaying = true;
      update();
      await _audioPlayerService.play(content);
    }
  }
}

abstract class AudioPlayerService {
  void dispose();
  Future<void> play(String url);
  Future<void> resume();
  Future<void> pause();
  Future<void> release();

  AudioPlayer get getAudioPlayer;
}

class AudioPlayerAdapter implements AudioPlayerService {
  late AudioPlayer _audioPlayer;

  @override
  AudioPlayer get getAudioPlayer => _audioPlayer;

  AudioPlayerAdapter() {
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() async {
    await _audioPlayer.dispose();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> play(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  @override
  Future<void> release() async {
    await _audioPlayer.release();
  }

  @override
  Future<void> resume() async {
    await _audioPlayer.resume();
  }
}
