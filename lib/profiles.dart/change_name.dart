// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter_application_1/components/click_button_widgets.dart';
import 'package:flutter_application_1/components/snak_bar.dart';
import 'package:flutter_application_1/components/textfiels_widget.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({super.key});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  String oldName = '';

  var height, width;
  @override
  void initState() {
    oldName = StaticData.userModel!.userName!;
    nameEditController.text = oldName;
    super.initState();
  }

  void updateName() async {
    if (nameEditController.text.trim().isEmpty) {
      nameEditController.clear();
      showMySnakbarWidget(context, 'Name is Required!');
      return;
    }

    if (nameEditController.text == StaticData.userModel!.userName) {
      showMySnakbarWidget(context, 'you are usin same name please change it!');
      return;
    } else {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(StaticData.userModel!.userId)
          .update({'userName': nameEditController.text});
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: StaticData.userModel!.userId)
          .get();

      ModelClass model =
          ModelClass.fromMap(snapshot.docs[0].data() as Map<String, dynamic>);
      StaticData.userModel = model;

      setState(() {
        Navigator.pop(context);
        showMySnakbarWidget(context, 'name updated succesfully');
        nameEditController.clear();
      });
    }
  }

  TextEditingController nameEditController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title : const Text("Update Name"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormWidget(
                controller: nameEditController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    showMySnakbarWidget(context, 'Name is required!');
                  }
                    return null;
                }),
            SizedBox(
              height: height * 0.06,
            ),
            InkWell(
                onTap: () {
                  updateName();
                },
                child: ClickButtonWidget(text: "Update Name"))
          ],
        ),
      ),
    );
  }
}
