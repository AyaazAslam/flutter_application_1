import 'package:flutter_application_1/components/chat_widget.dart';
import 'package:flutter_application_1/models/friend_model.dart';
import 'package:flutter_application_1/screens/chat_secreen.dart';
import 'package:flutter_application_1/screens/friends_req_screen.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../models/user_model.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    getAllRequests();
    getAllUsers(); // Add this to fetch all users
    super.initState();
  }

  List<ModelClass> allUsers = [];

  getAllUsers() async {
    allUsers.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .where("userId", isNotEqualTo: StaticData.userId)
        .get();
    for (var data in snapshot.docs) {
      ModelClass model =
          ModelClass.fromMap(data.data() as Map<String, dynamic>);
      setState(() {
        allUsers.add(model);
      });
    }
  }

  int curentIndex = 0;
  var height, width;
  List<FriendMOdel> allFriends = [];
  getAllRequests() async {
    allFriends.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Friends")
        .where("userID", isEqualTo: StaticData.userId)
        .get();

    for (var data in snapshot.docs) {
      FriendMOdel model =
          FriendMOdel.fromMap(data.data() as Map<String, dynamic>);

      setState(() {
        allFriends.add(model);
      });
    }
  }

  String chatRoomId(String loginUser, String friendUser) {
    if (loginUser[0].toLowerCase().codeUnits[0] >
        friendUser.toLowerCase().codeUnits[0]) {
      return "$loginUser$friendUser";
    } else {
      return "$friendUser$loginUser";
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "Home",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FriendReqScreen(),
                          ));
                    },
                    child: const Text(
                      "Request",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
          SizedBox(
            height: height * 0.15,
            width: width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allUsers.length + 1, // +1 for "Your Story"
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  Image.asset("assets/images/5.jpg").image,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 15,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "",
                          // StaticData.userModel!.userName ?? "Your Story",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              Image.asset("assets/images/5.jpg").image,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          allUsers[index - 1].userName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              height: height * 0.63,
              width: width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 2,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "All Chats",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allFriends.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              // String chatId = chatRoomId(
                              //     StaticData.userModel!.userId!,
                              //     allFriends[index].friendId!);
                              // print(chatId);
                              String chatId = chatRoomId(
                                  StaticData.userModel!.userId!,
                                  allFriends[index].friendId!);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          chatroomId: chatId,
                                          username:
                                              allFriends[index].friendName!)));
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => ChatScreen(
                              //           chatroomId: chatId,
                              //           usernamee:
                              //               allFriends[index].friendName!),
                              //     ));
                            },
                            child: Card(
                                child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,
                                  child: Icon(Iconsax.personalcard),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Center(child: Text("${index}")),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  allFriends[index].friendName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
