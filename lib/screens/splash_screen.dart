import 'package:flutter/material.dart';
import 'package:gupshup/Controller/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jumping_dot/jumping_dot.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences pref;
  void init() async {
    pref=await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 3));
    await Navigator.pushReplacementNamed(context,await AppController.whereToRedirect());
  }
  @override
  void initState() {
    super.initState();
    init();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // appBar: getAppBar("GupShup"),
      body: ListView(
        padding: EdgeInsets.all(7),
        children: [
          Center(
            heightFactor: size.height*0.004,
            child:SizedBox(height: 140,width: 140,child:  Image.asset('lib/assets/images/logo wc.png'),)
          ),
          JumpingDots(
            numberOfDots: 3,
            color: Colors.blue,
            animationDuration: const Duration(milliseconds: 250),

          ),
        ],
      ),
      
    );
  }
}
