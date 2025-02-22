import 'package:flutter_application_1/auth/authentication-services.dart';
import 'package:flutter_application_1/components/snak_bar.dart';
import 'package:flutter_application_1/home/login_page.dart';
import 'package:flutter_application_1/home/sign_in_page.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/textfiels_widget.dart';
import '../components/click_button_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthServices auth = AuthServices();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "Register",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Create an account to continue",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 60),
              // Username Field
              TextFormWidget(
                controller: usernameController,
                prefixIcon: Icons.person,
                hintText: "Username",
                shadowColor: Colors.black12,
                prefixIconActiveColor: Colors.blueAccent,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your username.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Email Field
              TextFormWidget(
                controller: emailController,
                prefixIcon: Icons.email,
                hintText: "username@example.com",
                shadowColor: Colors.black12,
                prefixIconActiveColor: Colors.blueAccent,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email.";
                  }
                  if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(value)) {
                    return "Please enter a valid email address.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Password Field
              TextFormWidget(
                controller: passwordController,
                prefixIcon: Icons.lock,
                hintText: "Password",
                obscureText: !isPasswordVisible,
                shadowColor: Colors.black12,
                prefixIconActiveColor: Colors.blueAccent,
                suffixIcon:
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                onSuffixIconTap: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password.";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters long.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Confirm Password Field
              TextFormWidget(
                controller: confirmPasswordController,
                prefixIcon: Icons.lock,
                hintText: "Confirm Password",
                obscureText: !isConfirmPasswordVisible,
                shadowColor: Colors.black12,
                prefixIconActiveColor: Colors.blueAccent,
                suffixIcon: isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixIconTap: () {
                  setState(() {
                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password.";
                  }
                  if (value != passwordController.text) {
                    return "Passwords do not match.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Terms and Conditions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.15),
                child: Text(
                  "By registering you agree to our terms and conditions.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Register Button
              InkWell(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      var value = await auth.signUpt(
                        emailController.text,
                        passwordController.text,
                        usernameController.text,
                      );

                      if (value != null && value.user != null) {
                        ModelClass model = ModelClass(
                          email: emailController.text,
                          password: passwordController.text,
                          userId: value.user!.uid,
                          userName: usernameController.text,
                        );

                        await FirebaseFirestore.instance
                            .collection("Users")
                            .doc(value.user!.uid)
                            .set(model.toMap());

                        // Show success snackbar
                        showMySnakbarWidget(
                            context, "Account created successfully!");

                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        });
                      }
                    } catch (e) {
                      showMySnakbarWidget(context, "Acount Create Succesfuly!");
                    }
                  }
                },
                child: ClickButtonWidget(
                  text: "REGISTER",
                  textColor: Colors.white,
                  buttonColor: Colors.indigo,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  borderColor: Colors.transparent,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
