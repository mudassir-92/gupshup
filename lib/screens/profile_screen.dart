import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gupshup/Controller/all_providers.dart';

import 'package:jumping_dot/jumping_dot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

String toPrint = "faaah";

// get the detail about current user bro and show it here
class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  // variable for class
  bool isLoaded = false;
  bool editkro = false;
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  File? img;
  bool isUpdating=false;
  String url="hah";

  // load the data bro // all the data should be fed to ProfileProviderR
  Future<void> loadQouta() async {
    try {
      var postgrestFilterBuilder = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      ProfileState pf = ProfileState(
        name: postgrestFilterBuilder[0]['name'],
        dp: postgrestFilterBuilder[0]['dp'] ?? '',
        bio: postgrestFilterBuilder[0]['bio'] ?? '',
      );
      nameController.text=pf.name;
      bioController.text=pf.bio;
      ref.read(profileProvider.notifier).updateState(pf);
       toPrint="${postgrestFilterBuilder}achay wla";
    } catch (e) {
      // toPrint = e.toString() + 'exceptopn me';
      toPrint="${Supabase.instance.client.auth.currentUser}With error";
    } finally {
      setState(() {});
    }
  }


  @override
  void initState() {
    loadQouta();
    super.initState();
  }
  @override
  void dispose() {

    super.dispose();
  }
  bool imgSelected=false;

  @override
  Widget build(BuildContext context) {
    Supabase supabase = Supabase.instance;
    final profile = ref.watch(profileProvider);
    // nameController.text=ref.read(profileProvider).name;
    // bioController.text=ref.read(profileProvider).bio;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            setState(() {
              editkro=true;
            });
          }, icon: Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
        // padding: EdgeInsets.all(10),
        padding: EdgeInsets.all(40),
        // mainAxisAlignment: MainAxisAlignment.center,
        child: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  if(editkro){
                    var xfile=await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 30);

                    if(xfile!=null){
                      // khuch aaya bro
                      img=File(xfile.path);
                      // set update to loading
                     setState(() {
                       imgSelected=true;
                     });
                      // show krna isko instead of that 
                    } 
                  }
                },
                child:Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: img != null
                          ? FileImage(img!)
                          : (profile.dp.isEmpty
                          ? const AssetImage('lib/assets/images/khali.webp')
                          : NetworkImage(profile.dp)) as ImageProvider,
                    ),
                    if (editkro)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                )

              ),
              SizedBox(height: 5,),
              Text('Name:',style: TextStyle(fontSize: 20),textAlign: TextAlign.end,),
              SizedBox(height: 5,),

              // put here the name of user
              TextFormField(
                enabled: editkro,
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Full name',
                  filled: true,
                  fillColor: const Color(0xFFF5FCF9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0 * 1.5,
                    vertical: 16.0,
                  ),
                  border: const OutlineInputBorder(
                    // borderSide: BorderSide,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Text('Bio:',style: TextStyle(fontSize: 20),textAlign: TextAlign.end,),
              SizedBox(height: 10,),
              TextFormField(
                enabled: editkro,
                controller: bioController,
                decoration: InputDecoration(
                  hintText:'Please Enter Bio',
                  filled: true,
                  fillColor: const Color(0xFFF5FCF9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0 * 1.5,
                    vertical: 16.0,
                  ),
                  border: const OutlineInputBorder(
                    // borderSide: BorderSide,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
              SizedBox(height: 25,),
              if(editkro)
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isUpdating=true;
                  });
                  // update the data bro
                  // end pe
                  if(nameController.text.trim().isNotEmpty && bioController.text.trim().isNotEmpty){
                    try{
                      String supbaseWhatFileNameOfDp='dps/${Supabase.instance.client.auth.currentUser!.id}/profile';
                      // uplaod kro
                     if(imgSelected){
                       try{
                         await Supabase.instance.client.storage.from('store').upload(supbaseWhatFileNameOfDp,img!);
                       }catch(e){
                         if(e.toString().contains('409')){
                           await Supabase.instance.client.storage.from('store').update(supbaseWhatFileNameOfDp,img!);
                         }
                       }
                     }
                      //
                      // now get Public URL of this images and store in user database
                      url=Supabase.instance.client.storage.from('store').getPublicUrl(supbaseWhatFileNameOfDp);

                      // // debug jst
                       //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(url)));
                      //
                      await Supabase.instance.client.from('users').update({'dp':url,'name':nameController.text,'bio':bioController.text}).eq('user_id',Supabase.instance.client.auth.currentUser!.id);
                      ref.read(profileProvider.notifier).updateState(ProfileState(name: nameController.text, dp: url, bio: bioController.text));

                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }finally{
                      setState(() {
                        isUpdating=false;
                        editkro=false;
                        imgSelected=false;
                      });
                    }
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name or Bio cant be empty')));
                  }
                  setState(() {
                    editkro=false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF00BF6D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const StadiumBorder(),
                ),
                child: isUpdating?JumpingDots() :Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}