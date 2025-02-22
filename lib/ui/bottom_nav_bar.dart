import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/ui/call_page.dart';
import 'package:flutter_application_1/screens/message_page.dart';
import 'package:flutter_application_1/profiles.dart/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:iconsax/iconsax.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int currentIndex = 0;
  PageController controller = PageController();

  var height, width;

  getUserProfileData(String id) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .where("userId", isEqualTo: id)
        .get();
    ModelClass model =
        ModelClass.fromMap(snapshot.docs[0].data() as Map<String, dynamic>);
    print(model);
    StaticData.userModel = model;
  }

  @override
  void initState() {
    getUserProfileData(StaticData.userId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                  height: height,
                  width: width,
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: controller,
                    onPageChanged: (value) {
                      setState(() {
                        currentIndex = value;
                      });
                    },
                    children: const [
                      MessageScreen(),
                      CallScreen(),
                      SettingScreen(),
                    ],
                  )),
            ),
            Container(
              height: height * 0.08,
              width: width,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      controller.jumpToPage(0);
                    },
                    child: SizedBox(
                      height: height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.message,
                            color:
                                currentIndex == 0 ? Colors.white : Colors.black,
                          ),
                          Text(
                            "Message",
                            style: TextStyle(
                              color: currentIndex == 0
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.jumpToPage(1);
                    },
                    child: SizedBox(
                      height: height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.call,
                            color:
                                currentIndex == 1 ? Colors.white : Colors.black,
                          ),
                          Text(
                            "Calls",
                            style: TextStyle(
                              color: currentIndex == 1
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.jumpToPage(2);
                    },
                    child: SizedBox(
                      height: height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.setting,
                              color: currentIndex == 2
                                  ? Colors.white
                                  : Colors.black),
                          Text(
                            "Settings",
                            style: TextStyle(
                              color: currentIndex == 2
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
