import 'package:flutter_application_1/auth/authentication-services.dart';
import 'package:flutter_application_1/home/sign_up_page.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  AuthServices auth = AuthServices();

  List<ModelClass> allUsers = [];
  getAllUsers() async {
    allUsers.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        // .where("userId", isNotEqualTo: StaticData.userModel!.userId)
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
    getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 700,
        width: 500,
        color: Colors.amber,
        child: ListView.builder(
          itemCount: allUsers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 100,
                width: 400,
                color: Colors.white,
                child: Text(allUsers[index].userName!),
              ),
            );
          },
        ),
      ),
      // body: Center(
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Text(StaticData.userModel!.userName!),
      //     InkWell(
      //       onTap: () {
      //         auth.signOut();
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(
      //             content: Text("Signout Successful"),
      //           ),
      //         );
      //         Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const SignUpScreen(),
      //             ));
      //       },
      //       child: Text("Signout",
      //           style: TextStyle(
      //               color: Colors.black,
      //               fontSize: 40,
      //               fontWeight: FontWeight.bold,
      //               decoration: TextDecoration.underline)),
      //     ),
      //   ],
      // ),
      //  ),
    );
  }
}
