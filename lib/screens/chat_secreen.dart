// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_application_1/screens/audioController.dart';
import 'package:flutter_application_1/screens/controllers/my_audio_controller.dart';
import 'package:flutter_application_1/screens/pdf.dart';
import 'package:flutter_application_1/screens/video_container.dart';
import 'package:flutter_application_1/screens/map_screen.dart';
import 'package:flutter_application_1/ui/seacrh_page.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ChatScreen extends StatefulWidget {
  final String? username;
  final String? chatroomId;
  const ChatScreen(
      {super.key, required this.username, required this.chatroomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var height, width;

  TextEditingController msgController = TextEditingController();
  bool isMessageEmpty = true;

  // AudioController audioController = Get.put(AudioController());
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isRecording = false;
  bool isPlaying = false;
  int currentPlayingIndex = -1;

  String getFormattedTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return "";
    }
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  String durationText = "00:00";
  @override
  void initState() {
    super.initState();
    Get.put(MyAudioController());
    // _audioPlayer.onPlayerComplete.listen((_) {
    //   setState(() {
    //     isPlaying = false;
    //     currentPlayingIndex = -1;
    //   });
    // });

    msgController.addListener(() {
      setState(() {
        isMessageEmpty = msgController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    msgController.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  void bottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: height * 0.25,
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            children: [
              // Document
              _buildGridItem(
                icon: Icons.file_present_outlined,
                label: 'Document',
                color: Colors.blue,
                onTap: () {
                  pickPdf();
                  Navigator.pop(context);
                },
              ),
              // Gallery
              _buildGridItem(
                icon: Icons.image,
                label: 'Gallery',
                color: Colors.purple,
                onTap: () {
                  pickImageFromGallary();
                  Navigator.pop(context);
                },
              ),
              // Camera
              _buildGridItem(
                icon: Icons.camera_alt,
                label: 'Camera',
                color: Colors.pink,
                onTap: () {
                  pickimagefromCamera();
                  Navigator.pop(context);
                },
              ),
              // Video
              _buildGridItem(
                icon: Icons.video_library,
                label: 'Video',
                color: Colors.red,
                onTap: () {
                  pickVideoFromGallery();
                  Navigator.pop(context);
                },
              ),
              // Location
              _buildGridItem(
                icon: Icons.location_on,
                label: 'Location',
                color: Colors.green,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );

                  if (result != null) {
                    final locationData = {
                      'latitude': result['latitude'],
                      'longitude': result['longitude'],
                      'address': result['address'],
                    };
                    final locationString = json.encode(locationData);
                    _onSendMessage(locationString, "location", "");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void sendText() {
    String textmessage = msgController.text.trim();
    if (textmessage.isEmpty) {
      msgController.clear();
      return;
    } else {
      _onSendMessage(textmessage, "text", "");
      msgController.clear();
    }
  }

  void _onSendMessage(String msg, String type, String audioDuration) async {
    Map<String, dynamic> messages = {
      "sendBy": StaticData.userModel!.userName,
      "recievBy": widget.username!,
      "message": msg,
      "time": FieldValue.serverTimestamp(),
      "type": type,
      "duration": audioDuration
    };

    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(widget.chatroomId)
        .collection("chats")
        .add(messages);
  }

  Future<void> pickimagefromCamera() async {
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final file = File(image.path);
      final fileName =
          "UserImages/${DateTime.now().microsecondsSinceEpoch}.jpg";
      final reference = FirebaseStorage.instance.ref().child(fileName);
      await reference.putFile(file);
      String downloadUrl = await reference.getDownloadURL();
      _onSendMessage(downloadUrl, "image", "");
    }
  }

  final picker = ImagePicker();
  File? imageFile;

  Future<void> pickImageFromGallary() async {
    XFile? pickedimage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedimage != null) {
      imageFile = File(pickedimage.path);

      final String fileName =
          "UserImages/${DateTime.now().microsecondsSinceEpoch}.png";
      final reference = FirebaseStorage.instance.ref().child(fileName);

      await reference.putFile(imageFile!);

      String downloadUrl = await reference.getDownloadURL();

      _onSendMessage(downloadUrl, "img", "");
    }
  }

  Future<void> pickVideoFromGallery() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      File uploasVideoFile = File(video.path);
      var videoName = DateTime.now().microsecondsSinceEpoch.toString();
      var stroageRef =
          FirebaseStorage.instance.ref().child("video/$videoName.mp4");
      var uploadtask = stroageRef.putFile(uploasVideoFile);
      var downloadVideoUrl = await (await uploadtask).ref.getDownloadURL();
      _onSendMessage(downloadVideoUrl, "video", "");
    }
  }

  void pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result!.files.isNotEmpty) {
      File uploadpdfFile = File(result.files.first.path!);
      var imageName = DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef =
          FirebaseStorage.instance.ref().child('file/$imageName.pdf');
      var uploadTask = storageRef.putFile(uploadpdfFile);
      var pdfdownloadUrl = await (await uploadTask).ref.getDownloadURL();

      _onSendMessage(pdfdownloadUrl, "pdf", "");
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: height,
          width: width,
          color: Colors.pink[50],
          child: Column(
            children: [
              Container(
                height: height * 0.1,
                width: width,
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 20,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    Text(
                      widget.username!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {},
                          child: const Icon(Icons.call_outlined),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.05,
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.videocam_outlined,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.05,
                    )
                  ],
                ),
              ),
              Expanded(
                  child: SizedBox(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chatRoom")
                      .doc(widget.chatroomId)
                      .collection("chats")
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return onSendmessage(
                              MediaQuery.of(context).size, map, index);
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: msgController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          hintText: "write something here...",
                          suffixIcon: InkWell(
                            onTap: () {
                              bottomSheet();
                            },
                            child: const Icon(Icons.attach_file),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Send/Voice button
                    GestureDetector(
                      onTap: () {
                        sendText();
                      },
                      onLongPress: () async {
                        MyAudioController.to.startRecording();
                        MyAudioController.to.start = DateTime.now();
                      },
                      onLongPressEnd: (details) async {
                        await MyAudioController.to.stopRecording(
                          StaticData.userModel!.userName!,
                          widget.chatroomId!,
                        );
                        MyAudioController.to.changeRecordingStatus(false);
                      },
                      child: isMessageEmpty
                          ? GetBuilder<MyAudioController>(
                              builder: (obj) {
                                return CircleAvatar(
                                  radius: 27,
                                  backgroundColor: Colors.black,
                                  child: Center(
                                    child: obj.isRecording
                                        ? Icon(
                                            Icons.record_voice_over,
                                            color: Colors.white,
                                            size: obj.isRecording ? 50 : 30,
                                          )
                                        : Icon(
                                            Icons.mic,
                                            color: Colors.white,
                                            size: obj.isRecording ? 50 : 30,
                                          ),
                                  ),
                                );
                              },
                            )
                          : const CircleAvatar(
                              radius: 27,
                              backgroundColor: Colors.green,
                              child: Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget onSendmessage(Size size, Map<String, dynamic> map, int index) {
    Timestamp? time = map["time"];
    bool isSender = map["sendBy"] == StaticData.userModel!.userName;
    String senderName = isSender ? "You" : map["sendBy"];
    return Container(
      width: size.width,
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width * 0.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isSender ? const Color(0xFF25D366) : const Color(0xFFF0F0F0),
        ),
        child: IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                map['type'] == "pdf"
                    ? MyPdfViewer(
                        url: map["message"],
                      )
                    : map['type'] == "audio"
                        ? GetBuilder<MyAudioController>(builder: (obj) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senderName,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: height * 0.05,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          obj.onPressedPlayButton(
                                              index, map['message']);
                                        },
                                        onSecondaryTap: () {
                                          _audioPlayer.stop();
                                          //   audioController.completedPercentage.value = 0.0;
                                        },
                                        child: (obj.isRecordPlaying &&
                                                obj.currentId == index)
                                            ? Icon(
                                                Icons.cancel,
                                                color: isSender
                                                    ? Colors.white
                                                    : Colors.red,
                                              )
                                            : Icon(
                                                Icons.play_arrow,
                                                color: isSender
                                                    ? Colors.white
                                                    : Colors.red,
                                              ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          width: width * 0.3,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0),
                                            child: LinearProgressIndicator(
                                              key: ValueKey(map['sendBy']),
                                              minHeight: 5,
                                              backgroundColor: Colors.grey,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                (isSender)
                                                    ? (obj.isRecordPlaying &&
                                                            obj.currentId ==
                                                                index)
                                                        ? Colors
                                                            .white // Change to white when playing
                                                        : Colors
                                                            .red // Change to red when sent
                                                    : Colors
                                                        .white, // Keep white for received messages
                                              ),
                                              value: (obj.isRecordPlaying &&
                                                      obj.currentId == index)
                                                  ? obj.completedPercentage
                                                  : obj.totalDuration
                                                      .toDouble(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        (obj.isRecordPlaying &&
                                                obj.currentId == index)
                                            ? obj
                                                .getRemainingTime() // Show countdown
                                            : "${map['duration']} s", // Show default duration if not playing
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isSender
                                                ? Colors.white
                                                : Colors.red),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          })
                        : map['type'] == "img"
                            ? Container(
                                height: size.height * 0.2,
                                width: size.width * 0.3,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(map['message']))),
                              )
                            : map["type"] == "video"
                                ? VideoContainer(videoUrl: map['message'])
                                : map['type'] == "location"
                                    ? GestureDetector(
                                        onTap: () {
                                          final locationData =
                                              json.decode(map['message']);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MapScreen(
                                                latitude:
                                                    locationData['latitude'],
                                                longitude:
                                                    locationData['longitude'],
                                                isViewer: true,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: height * 0.2,
                                          width: width * 0.85,
                                          padding: EdgeInsets.all(5),
                                          // decoration: BoxDecoration(
                                          //   color: Colors.white,
                                          //   borderRadius:
                                          //       BorderRadius.circular(15),
                                          //   boxShadow: [
                                          //     BoxShadow(
                                          //       color: Colors.grey
                                          //           .withOpacity(0.3),
                                          //       spreadRadius: 2,
                                          //       blurRadius: 5,
                                          //       offset: const Offset(0, 2),
                                          //     ),
                                          //   ],
                                          // ),
                                          child: Center(
                                            child: Column(
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  height: height * 0.185,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    // borderRadius:
                                                    //     const BorderRadius
                                                    //         .vertical(
                                                    //   top: Radius.circular(15),
                                                    // ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        'https://maps.googleapis.com/maps/api/staticmap?'
                                                        'center=${json.decode(map['message'])['latitude']},${json.decode(map['message'])['longitude']}'
                                                        '&zoom=15&size=400x200&maptype=roadmap'
                                                        '&markers=color:red%7C${json.decode(map['message'])['latitude']},${json.decode(map['message'])['longitude']}'
                                                        '&key=AIzaSyB0sppwm5PsZzrfHd0n2Pv4nSAz188b_Ls',
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                // Container(
                                                //   // padding:
                                                //   //     const EdgeInsets.all(4),
                                                //   height: height * 0.5,
                                                //   decoration:
                                                //       const BoxDecoration(
                                                //     color: Colors.white,
                                                //     borderRadius:
                                                //         BorderRadius.vertical(
                                                //       bottom:
                                                //           Radius.circular(15),
                                                //     ),
                                                //   ),
                                                //   child: Column(
                                                //     crossAxisAlignment:
                                                //         CrossAxisAlignment
                                                //             .start,
                                                //     children: [
                                                //       Row(
                                                //         children: [
                                                //           Icon(
                                                //             Icons
                                                //                 .place_outlined,
                                                //             color: isSender
                                                //                 ? Colors.green
                                                //                 : Colors.red,
                                                //             size: 20,
                                                //           ),
                                                //           const SizedBox(
                                                //               width: 8),
                                                //           Expanded(
                                                //             child: Text(
                                                //               json.decode(map[
                                                //                           'message'])[
                                                //                       'address'] ??
                                                //                   'Unknown location',
                                                //               style:
                                                //                   const TextStyle(
                                                //                 fontSize: 13,
                                                //                 fontWeight:
                                                //                     FontWeight
                                                //                         .w500,
                                                //               ),
                                                //               maxLines: 2,
                                                //               overflow:
                                                //                   TextOverflow
                                                //                       .ellipsis,
                                                //             ),
                                                //           ),
                                                //         ],
                                                //       ),
                                                //       const SizedBox(height: 8),
                                                //       Text(
                                                //         'Tap to view in map',
                                                //         style: TextStyle(
                                                //           fontSize: 11,
                                                //           color:
                                                //               Colors.grey[600],
                                                //           fontStyle:
                                                //               FontStyle.italic,
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        map["message"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: map["sendBy"] ==
                                                  StaticData.userModel!.userName
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    getFormattedTime(time),
                    style: const TextStyle(fontSize: 10),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
