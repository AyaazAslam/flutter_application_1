import 'package:flutter_application_1/auth/authentication-services.dart';
import 'package:flutter_application_1/models/friend_model.dart';
import 'package:flutter_application_1/models/req_model.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

class FriendReqScreen extends StatefulWidget {
  const FriendReqScreen({super.key});

  @override
  State<FriendReqScreen> createState() => _FriendReqScreenState();
}

class _FriendReqScreenState extends State<FriendReqScreen> {
  bool isCheckRequest = false;
  List<RequestModel> allRequests = [];
  getAllRequests() async {
    allRequests.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("requests")
        .where("reciverId", isEqualTo: StaticData.userModel!.userId)
        .get();

    for (var data in snapshot.docs) {
      RequestModel model =
          RequestModel.fromMap(data.data() as Map<String, dynamic>);

      setState(() {
        allRequests.add(model);
      });
    }
  }

  @override
  void initState() {
    getAllRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Friend Request"),
          centerTitle: true,
        ),
        body: allRequests.isEmpty
            ? const Center(
                child: Text("No FriendRequest Fount"),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: allRequests.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                        title: Text(allRequests[index].senderName!),
                        leading: const CircleAvatar(
                          child: Icon(Iconsax.people),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.personalcard),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () {
                                  Uuid nuid = const Uuid();

                                  String firstId = nuid.v4();
                                  FriendMOdel mOdel = FriendMOdel(
                                      friendId: allRequests[index].senderId,
                                      friendName: allRequests[index].senderName,
                                      id: firstId,
                                      userID: allRequests[index].reciverId);
                                  FirebaseFirestore.instance
                                      .collection("Friends")
                                      .doc(firstId)
                                      .set(mOdel.toMap());

                                  String secoundId = nuid.v4();
                                  FriendMOdel mOdel1 = FriendMOdel(
                                      friendId: allRequests[index].reciverId,
                                      friendName:
                                          allRequests[index].reciverName,
                                      id: secoundId,
                                      userID: allRequests[index].senderId);
                                  FirebaseFirestore.instance
                                      .collection("Friends")
                                      .doc(secoundId)
                                      .set(mOdel1.toMap());

                                  FirebaseFirestore.instance
                                      .collection("requests")
                                      .doc(allRequests[index].requestId)
                                      .delete();

                                  // FirebaseFirestore.instance
                                  //     .collection("requests")
                                  //     .doc(allRequests[index].requestId)
                                  //     .update({"status": "accepted"});
                                },
                                child:
                                    const Icon(Icons.arrow_circle_up_outlined))
                          ],
                        ),
                      ));
                    }),
              ));
  }
}
