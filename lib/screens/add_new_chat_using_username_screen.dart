import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class AddNewChat extends ConsumerWidget {
  int curr_user;
  final _formKey = GlobalKey<FormState>();
  String? username;
  TextEditingController usernameController= TextEditingController();
  AddNewChat({super.key,required this.curr_user});
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(

      ),
      backgroundColor: Colors.white,
      body: LogoWithTitle(
        title: 'Finding that Person ?!',
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
                 // if any such user exists and
                  Map<String, dynamic>? map = await Supabase.instance.client.from('users').select('id').eq('username', usernameController.text.trim()).maybeSingle();
                  if(map==null){
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                     backgroundColor: Colors.red,
                       padding: EdgeInsets.all(20),
                       behavior: SnackBarBehavior.floating,
                       content: Text('No Such User Exists',style: TextStyle(color: Colors.black),)));
                  }else{
                    // show the chatt Menu
                    // if already not exists
                    var map2 = await Supabase.instance.client.from('chats').select().or('and(user1id.eq.${map['id']},user2id.eq.$curr_user),and(user1id.eq.$curr_user,user2id.eq.${map['id']})').maybeSingle();
                    if(map2==null){
                      await Supabase.instance.client.from('chats').insert({'user1id':curr_user,'user2id':map['id']});
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You Already Chattingg..')));
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Initializing chat...'),backgroundColor: Colors.green,));
                    Future.delayed(Duration(seconds: 3));
                    Navigator.pop(context);
                  }
                }
                catch(e){
                  String str =e.toString();
                  print(str);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
              Image.asset(
                'lib/assets/images/banner.png',
                height: 100,
                width: 250,
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
