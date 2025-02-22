import 'package:flutter_application_1/auth/authentication-services.dart';
import 'package:flutter_application_1/models/req_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isSend = true;
  AuthServices auth = AuthServices();
  List<ModelClass> allUsers = [];

  getAllUsers() async {
    allUsers.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .where("userId", isNotEqualTo: StaticData.userModel!.userId)
        .get();
    for (var data in snapshot.docs) {
      ModelClass model =
          ModelClass.fromMap(data.data() as Map<String, dynamic>);
      setState(() {
        allUsers.add(model);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getAllUsers();
    super.initState();
  }

  var height, width;
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        // backgroundColor: Colors.black,
        body: Stack(
      children: [
        Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(color: Colors.black),
        ),
        Positioned(
            top: 20,
            right: 0,
            left: 0,
            child: SizedBox(
              height: height * 0.15,
              width: width * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white)),
                      child: const Icon(
                        Iconsax.search_favorite,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Calls",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white)),
                      child: const Icon(
                        Iconsax.call,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )),
        Positioned(
            top: 170,
            right: 0,
            left: 0,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35)),
                  color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Recent",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: height * 0.66,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(
                            radius: 25,
                            child: Icon(
                              Iconsax.user,
                            ),
                          ),
                          title: Text(
                            allUsers[index].userName!,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Today, 10:30 AM",
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: InkWell(
                              onTap: () {
                                setState(() {
                                  isSend != isSend;
                                });
                                Uuid uid = Uuid();
                                String reqId = uid.v4();
                                // print(reqId);
                                RequestModel model = RequestModel(
                                    reciverId: allUsers[index].userId,
                                    senderName: StaticData.userModel!.userName,
                                    senderId: StaticData.userModel!.userId,
                                    status: "pending",
                                    reciverName: allUsers[index].userName,
                                    requestId: reqId);

                                // RequestModel model = RequestModel(
                                //     reciverId: allUsers[index].userId,
                                //     reciverName: allUsers[index].userName,
                                //     requestId: reqId,
                                //     senderId: StaticData.userModel!.userId,
                                //     senderName: StaticData.userModel!.userName,
                                //     status: "pendding");
                                FirebaseFirestore.instance
                                    .collection("requests")
                                    .doc(reqId)
                                    .set(model.toMap());
                              },
                              child: Icon(
                                Iconsax.add,
                                color: Colors.green,
                              )),
                        );
                      },
                      itemCount: allUsers.length,
                    ),
                  )
                ],
              ),
            ))
      ],
    ));
  }
}
