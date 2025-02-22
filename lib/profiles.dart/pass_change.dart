import 'package:flutter_application_1/components/click_button_widgets.dart';
import 'package:flutter_application_1/components/snak_bar.dart';
import 'package:flutter_application_1/components/textfiels_widget.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChnagePassScreen extends StatefulWidget {
  const ChnagePassScreen({super.key});

  @override
  State<ChnagePassScreen> createState() => _ChnagePassScreenState();
}

class _ChnagePassScreenState extends State<ChnagePassScreen> {
  String oldPass = '';
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    oldPass = StaticData.userModel!.password!;

    super.initState();
  }

  void updatePasword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (oldPass != oldPassControler.text) {
      showMySnakbarWidget(context, 'old password is Incorrect!');
      oldPassControler.clear();
      newPasswoontroller.clear();
      confirmpassController.clear();
      return;
    } else {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(StaticData.userModel!.userId)
          .update({'password': newPasswoontroller.text});

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where("userId", isEqualTo: StaticData.userModel!.userId)
          .get();

      ModelClass model =
          ModelClass.fromMap(snapshot.docs[0].data() as Map<String, dynamic>);
      StaticData.userModel = model;

      setState(() {
        oldPass = model.password!;
        oldPassControler.clear();
        newPasswoontroller.clear();
        confirmpassController.clear();
        Navigator.pop(context);
        showMySnakbarWidget(context, 'Pasword updates Succefully!');
      });
    }
  }

  var height, width;
  TextEditingController oldPassControler = TextEditingController();
  TextEditingController newPasswoontroller = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();
  bool isPasswordVisible = false;
  bool isPasswordVisible1 = false;
  bool isPasswordVisible2 = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chnage Password"),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Update Your password Now!",
                style: TextStyle(fontSize: 23),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormWidget(
                  hintText: 'old password',
                  suffixIcon: isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixIconTap: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  controller: oldPassControler,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter old password';
                    }
                    return null;
                  }),
              SizedBox(
                height: 20,
              ),
              TextFormWidget(
                  controller: newPasswoontroller,
                  hintText: 'create password',
                  suffixIcon: isPasswordVisible1
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixIconTap: () {
                    setState(() {
                      isPasswordVisible1 = !isPasswordVisible1;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.length < 6 ||
                        newPasswoontroller.text.trim().isEmpty) {
                      newPasswoontroller.clear();
                      return 'please  must complete 6 charcter';
                    }
                    return null;
                  }),
              SizedBox(
                height: 20,
              ),
              TextFormWidget(
                  controller: confirmpassController,
                  hintText: 'confirm password',
                  suffixIcon: isPasswordVisible2
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixIconTap: () {
                    setState(() {
                      isPasswordVisible2 = !isPasswordVisible2;
                    });
                  },
                  validator: (value) {
                    if (newPasswoontroller.text.trim() !=
                            confirmpassController.text.trim() ||
                        confirmpassController.text.trim().isEmpty) {
                      confirmpassController.clear();
                      return 'new and confrim password not match';
                    }

                    return null;
                  }),
              SizedBox(
                height: 30,
              ),
              InkWell(
                  onTap: () {
                    updatePasword();
                  },
                  child: ClickButtonWidget(text: 'Update password'))
            ],
          ),
        ),
      ),
    );
  }
}
