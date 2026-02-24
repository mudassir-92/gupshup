import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final isPasswordVisibleProvider = StateProvider<bool>((ref) => false);
final nameProvider=StateProvider<String>((ref) {
  return "Anonymous";
},);
class SignUpScreen extends ConsumerWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String? email;
  String? password;
  String? name;
  final supabase=Supabase.instance.client;

  // bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  SignUpScreen({super.key});

  Future<void> signUpUsingGoogle(BuildContext context) async {
    // make a google signIn Account
    GoogleSignIn googleSignIn=GoogleSignIn.instance;
    // now is signin client ko initialize krna by use of android client
    googleSignIn.initialize(
      clientId: dotenv.env['ANDROID_CLIENT'],
      // web kelie server client do bro
      serverClientId: dotenv.env['WEB_CLIENT']
    );
    // now sign in with google and account milay ga authentication se
    GoogleSignInAccount account=await googleSignIn.authenticate();

    // all google things are done ab signup krna using supabase
    // we need id token and one access token
    //    Supabase.instance.client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken,accessToken: )
    final idtk= account.authentication.idToken??'';
    final accesstk=await account.authorizationClient.authorizationForScopes(['email','profile'])?? await account.authorizationClient.authorizeScopes(['email','profile']);
   AuthResponse authResponse=await  Supabase.instance.client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idtk,accessToken: accesstk.accessToken);

   if(authResponse.user==null || authResponse.session==null){
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong')));
   }else{
     // no deciede either ask for user name or go to
     final res=await Supabase.instance.client.from('users').select('id').eq('user_id',authResponse.user!.id);
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.toString())));

     await Future.delayed(Duration(seconds: 3));
     if(res.isEmpty){
       Navigator.pushReplacementNamed(context, '/username');
     }
     //)
     Navigator.pushReplacementNamed(context, '/home');
   }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPasswordVisible = ref.watch(isPasswordVisibleProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Image.asset(
                    'lib/assets/images/banner.png',
                    width: constraints.maxWidth * 0.5,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text(
                    "Sign In",
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: 'Full name',
                            filled: true,
                            fillColor: Color(0xFFF5FCF9),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                              BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          onSaved: (nam) {
                            if(nam!=null) {
                              ref.read(nameProvider.notifier).state=nam;
                            }else{
                              ref.read(nameProvider.notifier).state=nameController.text;
                            } // else anonymous bnda hai bro
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            filled: true,
                            fillColor: Color(0xFFF5FCF9),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                              BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (em) {
                            // print('email');
                            email = em;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              suffix: GestureDetector(
                                child: isPasswordVisible ? const Icon(
                                    Icons.visibility) : const Icon(
                                    Icons.visibility_off_outlined),
                                onTap: () {
                                  ref
                                      .read(isPasswordVisibleProvider.notifier)
                                      .state = !isPasswordVisible;
                                },
                              ),
                              hintText: 'Password',
                              filled: true,
                              fillColor: const Color(0xFFF5FCF9),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0 * 1.5, vertical: 16.0),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                            onSaved: (pass) {
                              // Save it
                              password = pass;
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                             // now try login in if not failed
                              // email is valid and password is valid
                              AuthResponse response=await supabase.auth.signUp(email: email!,password: password!);
                              if(response.user!=null){
                                Navigator.pushReplacementNamed(context, '/username');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF00BF6D),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Sign Up"),
                        ),
                        const SizedBox(height: 16.0),
                    
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text.rich(
                            const TextSpan(
                              text: "Have an account? ",
                              children: [
                                TextSpan(
                                  text: "Sign in",
                                  style: TextStyle(color: Color(0xFF00BF6D)),
                                ),
                              ],
                            ),
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(0.64),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await signUpUsingGoogle(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color(0x0ff00000),
                                borderRadius:BorderRadius.all(Radius.circular(20))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 50,width: 50,child: Image.asset('lib/assets/images/google.png'),),
                                Text('Continue With Google',style: TextStyle(color: Colors.purple),)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}