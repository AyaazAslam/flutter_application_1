import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/home/login_page.dart';
import 'package:flutter_application_1/ui/bottom_nav_bar.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  getDataFromSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? action = prefs.getString('userID');
    if (action == null) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const LoginScreen();
        }));
      });
    } else {
      StaticData.userId = action;
      Future.delayed(Duration(seconds: 3), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const BottomNavigationScreen();
        }));
      });
    }
  }

  @override
  void initState() {
    getDataFromSF();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
    );
  }
}
