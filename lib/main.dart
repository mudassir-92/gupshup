import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gupshup/screens/home_screen.dart';
import 'package:gupshup/screens/login_screen.dart';
import 'package:gupshup/screens/signup_screen.dart';
import 'package:gupshup/screens/splash_screen.dart';
import 'package:gupshup/screens/username_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
final navigatorKey = GlobalKey<NavigatorState>();
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // AS THIS IS SUPABASE PROJECT SO INITIALIZE IT BROOO
  // load envrionment variables
  await dotenv.load(fileName: ".env");
  // no intialize it bro
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // initlize ZEGO systems
   ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
 await ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
   ZegoUIKitSignalingPlugin()
 ]);


  runApp(SafeArea(top: false,
      child: ProviderScope(child: const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // it will show untill the other things are shown
  // onBoarding (signUp)+ or home screen
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.purple.shade50),
      ),
     initialRoute: '/splash_screen',
      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/login': (context) => SignInScreen(),
        '/signup': (context) =>SignUpScreen(),
        '/username':(context)=>UsernameScreen(),
        '/home':(context)=>HomeScreen()
      },
    );
  }
}
