import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gupshup/Controller/call_service.dart';
import 'package:gupshup/Controller/zigo_controller.dart';
import 'package:gupshup/screens/add_new_chat_using_username_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '';
import '../Controller/chat_provider.dart';
import '../models/user.dart';
import 'chat_screen.dart';

class ChatTabScreen extends ConsumerStatefulWidget {
  const ChatTabScreen({super.key});
  @override
  ConsumerState<ChatTabScreen> createState() => _ChatTabScreenState();
}

int currUser = 0;
String username="";
class _ChatTabScreenState extends ConsumerState<ChatTabScreen> {
  String toPrint = "kch nahi bro";
  Future<void> loadQouta(BuildContext context) async {

    final map = await Supabase.instance.client
        .from('users')
        .select('id,username')
        .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
        .single();
    currUser = map['id'];
    username=map['username'].toString();
    myUserId=currUser.toString();
    PostgrestList chats = await Supabase.instance.client.rpc('get_chats_with_last_msg',params: {'usr':currUser});
    print('rn$chats');
    // no get last msgs
    for (Map<String, dynamic> chat in chats) {
      // User Bnao
      int id = chat['user1id'] == map['id'] ? chat['user2id'] : chat['user1id'];
      
      // is if or doosri id ka last massages lo agr hai
      // await Supabase.instance.client.from('chat').select('pos')
      final user = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', id)
          .single();
      String msg=chat['data']??'--';
      String type=chat['type']??'--';
      User1? us = User1.getUser(user);
      ref
          .read(chatProvider.notifier)
          .addMsg(
            Massage(
              chatId: chat['id'],
              msg: msg,
              from: chat['user1id'],
              to: chat['user2id'],
              isRead: false,
              user: us, type: type,
            ),
          );
      // print(chat);
    }
    ZigoController().initZigo(myUserId,username);
  }

  @override
  void initState() {
    super.initState();
    loadQouta(context);
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatProvider);
    return Scaffold(
      body: ListView.separated(
        itemCount: chats.allChats.length,

        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
             // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(chats.allChats[index].user.name)));
              // Navigate to Chat Screen Bro Used cached Image and cached Video Player Brrrooo
              Navigator.push(context,MaterialPageRoute(builder: (context)=>ChatScreen(currentUsr: currUser,otherUsr: chats.allChats[index].user,)));
            },
            child: ListTile(
              minTileHeight: 60,
              minLeadingWidth: 1,
              leading: Container(height: 50,width: 50,decoration: BoxDecoration(),
                  child: CircleAvatar(backgroundImage: chats.allChats[index].user.dp.image,)),
              title: Text(chats.allChats[index].user.name,style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text(chats.allChats[index].msg),
              trailing: chats.allChats[index].isRead?Icon(Icons.circle,color: Colors.green,):Icon(Icons.check,color: Colors.green,),
            ),
          );
        }, separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            thickness: 1,
          );
      },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddNewChat(curr_user:currUser);
          },));
        //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(chats.allChats.toString())));
        },
        child: Icon(Icons.chat,color: Colors.white,),
      ),
    );
  }
}
