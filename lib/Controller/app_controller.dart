import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
SharedPreferences? pref;
class AppController {
  static Future<bool> isLoggedIn() async {
    pref??=await SharedPreferences.getInstance();
    return Supabase.instance.client.auth.currentUser!=null;
  }
  static Future<void> setLoggedIn() async {
    pref??=await SharedPreferences.getInstance();
    pref!.setBool('isLogged', true);
  }
  static Future<void> setLogout() async {
    pref??=await SharedPreferences.getInstance();
    pref!.setBool('isLogged', false);
  }
  static Future<String> whereToRedirect() async {
    // if it is first time then  the signUp Screen
    pref??=await SharedPreferences.getInstance();
    bool isFirstTime=pref!.getBool('isFirstTime')??true;
    bool isLogged=false;
    if(!isFirstTime){
      isLogged=await isLoggedIn();
    }
    pref!.setBool('isFirstTime', false);
    if(isFirstTime){
      return '/signup';
    }if(isLogged){
      return '/home';
    }else{
     return '/login';
    }
  }
}