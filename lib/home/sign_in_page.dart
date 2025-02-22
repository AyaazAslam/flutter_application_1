import 'package:flutter_application_1/components/click_button_widgets.dart';
import 'package:flutter_application_1/home/login_page.dart';
import 'package:flutter_application_1/home/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var height, width;
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.withOpacity(0.7),
                Colors.blue.withOpacity(0.9),
                Colors.blue.withOpacity(0.9),
                Colors.indigo.withOpacity(0.8),
              ]),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 90,
            ),
            Container(
              margin: const EdgeInsets.only(left: 25),
              height: height * 0.3,
              width: width,
              child: Image.asset('assets/images/chat.png', fit: BoxFit.contain),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text("ChatBox",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 5,
            ),
            Text("can't wait to chat with you",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 20)),
            const SizedBox(
              height: 100,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LoginScreen();
                }));
              },
              child: ClickButtonWidget(
                text: "LOGIN",
                textColor: Colors.white,
                buttonColor: Colors.indigo,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(2, 5),
                  ),
                ],
                borderColor: Colors.transparent,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SignUpScreen();
                }));
              },
              child: const ClickButtonWidget(
                text: "SIGNUP",
                textColor: Colors.white,
                // buttonColor: Colors.none,
                borderColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
