import 'package:flutter_application_1/auth/authentication-services.dart';
import 'package:flutter_application_1/components/snak_bar.dart';
import 'package:flutter_application_1/home/sign_up_page.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/ui/bottom_nav_bar.dart';
import 'package:flutter_application_1/ui/forgot_page.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../clipers/custom_cliper.dart';
import '../components/textfiels_widget.dart';
import '../components/click_button_widgets.dart';
import '../ui/first.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthServices auth = AuthServices();
  bool rememberMe = false;
  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.clear();
    passwordController.clear();
    super.dispose();
  }

  @override
  void initState() {
    emailController.text = "mu@gmail.com";
    passwordController.text = "123456";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            color: Colors.white,
          ),
          Positioned(
            top: 4,
            left: 12,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: Container(
                  height: height * 0.35,
                  width: width * 0.6,
                  child: const Image(
                    image: AssetImage("assets/images/logo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            child: ClipPath(
              clipper: MyCustomCliper(),
              child: Container(
                height: height,
                width: width,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome to ChatBox",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Arial',
                      ),
                    ),
                    Text(
                      "Login to your account",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormWidget(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email.";
                        }
                        return null;
                      },
                      prefixIcon: Icons.email,
                      hintText: "username@example.com",
                      shadowColor: Colors.black12,
                      prefixIconActiveColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 20),

                    TextFormWidget(
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password.";
                        }
                        return null;
                      },
                      prefixIcon: Icons.lock,
                      hintText: "Enter your password",
                      obscureText: !isPasswordVisible,
                      shadowColor: Colors.black12,
                      prefixIconActiveColor: Colors.blueAccent,
                      suffixIcon: isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixIconTap: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            activeColor: Colors.white,
                            checkColor: Colors.blueAccent,
                          ),
                          const Text(
                            "Remember Me",
                            style: TextStyle(color: Colors.white),
                          ),
                          // ignore: prefer_const_constructors
                          Spacer(),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const ForgotPasswordScreen();
                              }));
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Button
                    InkWell(
                      onTap: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          return;
                        } else {
                          QuerySnapshot snapshot = await FirebaseFirestore
                              .instance
                              .collection("Users")
                              .where("email", isEqualTo: emailController.text)
                              .where("password",
                                  isEqualTo: passwordController.text)
                              .get();
                          if (snapshot.docs.isEmpty) {
                            emailController.clear();
                            passwordController.clear();
                            // ignore: use_build_context_synchronously
                            showMySnakbarWidget(
                                context, "email and password incorrect!");
                          } else {
                            ModelClass model = ModelClass.fromMap(
                                snapshot.docs[0].data()
                                    as Map<String, dynamic>);
                            print(model);
                            StaticData.userModel = model;
                            StaticData.userId = model.userId;
                            saveDataTOSF(model.userId!);
                            // ignore: use_build_context_synchronously
                            showMySnakbarWidget(context, "Login Successfully");
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BottomNavigationScreen(),
                              ),
                            );
                          }

                          // auth
                          //     .signInWithEmailAndPassword(emailController.text,
                          //         passwordController.text, context)
                          //     .then((value) {});
                        }
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

                    const SizedBox(height: 20),
                    // Sign Up Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const SignUpScreen();
                            }));
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {},
                      child: ClickButtonWidget(
                          text: "Sign In with Google",
                          textColor: Colors.indigo,
                          buttonColor: Colors.white,
                          borderColor: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(2, 5),
                            )
                          ]),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  saveDataTOSF(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userID', id);
  }
}
