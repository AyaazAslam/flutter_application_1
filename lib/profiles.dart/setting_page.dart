import 'package:flutter_application_1/auth/authentication-services.dart';
import 'package:flutter_application_1/components/profile_page.dart';
import 'package:flutter_application_1/components/snak_bar.dart';
import 'package:flutter_application_1/home/login_page.dart';
import 'package:flutter_application_1/profiles.dart/change_name.dart';
import 'package:flutter_application_1/profiles.dart/pass_change.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  AuthServices auth = AuthServices();
  var height, width;
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
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
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Iconsax.arrow_left_2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 100,
                    ),
                    const Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )),
        Positioned(
            top: 140,
            right: 0,
            left: 0,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35)),
                  color: Colors.white),
              child: SizedBox(
                height: height * 0.85,
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
                    const SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeNameScreen()));
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Iconsax.user),
                        ),
                        title: Text(StaticData.userModel!.userName!),
                        subtitle:
                            const Text("Privacy, security, change number"),
                        trailing: const Icon(Iconsax.scanning),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    ProfileWidget(
                        title: "Change Password",
                        subtitle: "Privacy, security, change number",
                        icon: Iconsax.key,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChnagePassScreen()));
                        }),
                    ProfileWidget(
                        title: "Chats",
                        subtitle: "Theme, wallpapers, chat history",
                        icon: Iconsax.message,
                        onTap: () {}),
                    ProfileWidget(
                        title: "Notifications",
                        subtitle: "Message, group & call tones",
                        icon: Iconsax.notification,
                        onTap: () {}),
                    ProfileWidget(
                        title: "Help",
                        subtitle: "Help Center, Security , privacy",
                        icon: Iconsax.message_question,
                        onTap: () {}),
                    ProfileWidget(
                        title: "Data and storage usage",
                        subtitle: "Network usage, auto-download",
                        icon: Iconsax.wifi,
                        onTap: () {}),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Iconsax.add_circle),
                          ),
                          const SizedBox(
                            width: 17,
                          ),
                          const Text("Invite a friend"),
                        ],
                      ),
                    ),
                    ProfileWidget(
                        title: "Logout",
                        subtitle: "exit the app",
                        icon: Iconsax.logout,
                        onTap: () async {
                          ///auth.signOut();
                          showMySnakbarWidget(context, "Log out Successfully!");
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('userID');
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }),
                  ],
                ),
              ),
            ))
      ],
    ));
  }
}
