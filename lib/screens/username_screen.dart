import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gupshup/Controller/app_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_screen.dart';
class UsernameScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  String? username;
  TextEditingController usernameController= TextEditingController();
  UsernameScreen({super.key});
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LogoWithTitle(
        title: 'Choose Username',
        subText:
        "You can chat with anyone with a username.",
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if(value==null ||  value.isEmpty){
                    return 'Username cannot be empty';
                  }
                  username=value;
                  // now check already exists in the system??
                  // if exists then return error
                  // insert if error then
                 
                  return null;
                },
                controller: usernameController,
                decoration: const InputDecoration(
                    hintText: 'username',
                    filled: true,
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0)
                    ),
                  fillColor: Color(0xFFF5FCF9),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0 * 1.5, vertical: 16.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),

                keyboardType: TextInputType.name,
                onSaved: (uname) {
                 username=uname;
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try{
                  print('\n'*40);

                  await Supabase.instance.client.from('users').insert({
                    'username':username??(usernameController.text.isEmpty?null:usernameController.text),
                    'name':ref.read(nameProvider)
                  });
                  await AppController.setLoggedIn();
                  // print('\n'*40);
                  Navigator.pushReplacementNamed(context, '/home');
                  // print('\n'*(10));
                }on PostgrestException catch(e){
                  if(e.code=='23505') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username already exists')));
                  } else {
                    // print(e.toString()*10);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something went wrong')));
                  }
                }
                catch(e){
                  String str =e.toString();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('network isssue ??')));
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
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }
}

class LogoWithTitle extends StatelessWidget {
  final String title, subText;
  final List<Widget> children;

  const LogoWithTitle(
      {super.key,
        required this.title,
        this.subText = '',
        required this.children});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: constraints.maxHeight * 0.1),
              Image.network(
                "https://i.postimg.cc/nz0YBQcH/Logo-light.png",
                height: 100,
              ),
              SizedBox(
                height: constraints.maxHeight * 0.1,
                width: double.infinity,
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.5,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.64),
                  ),
                ),
              ),
              ...children,
            ],
          ),
        );
      }),
    );
  }
}
