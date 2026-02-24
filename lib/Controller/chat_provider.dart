import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gupshup/models/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gupshup/screens/chat_tab_screen.dart';
import 'package:gupshup/screens/chat_screen.dart';
import '../models/user.dart';

// we should use notifierProvider
final chatProvider = StateNotifierProvider<ChatsNotifier, ChatsState>(
  (ref) => ChatsNotifier(),
);

class ChatsState {
  // it will store List of all the 2 ways communication and last msg and is read stats
  final List<Massage> allChats;
  ChatsState({required this.allChats});
  ChatsState copyWith({List<Massage>? allChats, int? thisUser1}) {
    return ChatsState(allChats: allChats ?? this.allChats);
  }
}

class Massage {
  final User1 user;
  final int chatId;
  final String msg; // massage
  final String type;
  final int from;
  final int to;
  final bool isRead;
  String get massage => msg;
  Massage({
    required this.chatId,
    required this.msg,
    required this.from,
    required this.to,
    required this.isRead,
    required this.user,
    required this.type,
  });
  Massage copyWith({
    String? msg,
    int? from,
    int? to,
    bool? isRead,
    int? chatId,
    User1? user,
    String? type,
  }) {
    return Massage(
      msg: msg ?? this.msg,
      from: from ?? this.from,
      to: to ?? this.to,
      isRead: isRead ?? this.isRead,
      chatId: chatId ?? this.chatId,
      user: user ?? this.user,
      type: type ?? this.type,
    );
  }
  @override
  String toString() {
    return 'from $from to $to user $user type is $type msg is $msg';
  }
}

class ChatsNotifier extends StateNotifier<ChatsState> {
  // constructor
  ChatsNotifier() : super(ChatsState(allChats: [])) {
    _initChannel();
  }
  RealtimeChannel? channel;
  @override
  void dispose() {
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel!);
    }
    super.dispose();
  }

  void _initChannel() {
    channel = Supabase.instance.client
        .channel('public:chats')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chats',
          callback: (payload) async {
            print(payload.newRecord); //{id: 4, user1id: 13, user2id: 14,
            // created_at: 2026-02-08T15:03:44.991152+00:00}
            // User1 currrent User1 ke ellawa hoga
            if (payload.newRecord['user1id'] != currUser &&
                payload.newRecord['user2id'] != currUser) {
              return;
            }
            int id = payload.newRecord['user1id'] == currUser
                ? payload.newRecord['user2id']
                : payload.newRecord['user1id'];
            // agr current dono user me nahi hai then return
            final user = await Supabase.instance.client
                .from('users')
                .select()
                .eq('id', id)
                .single();
            User1? us = User1.getUser(user);
            PostgrestList lastMsg = await Supabase.instance.client.rpc(
              'getlastmsgofusrs',
              params: {'usr1': currUser, 'usr2': id},
            );
            // get last msg of these two ids bro
            String msg = '';
            String type = '';
            if (lastMsg.isNotEmpty) {
              msg = lastMsg[0]['msg'];
              type = lastMsg[0]['type'];
            }
            final m = Massage(
              chatId: payload.newRecord['id'],
              msg: msg,
              from: payload.newRecord['user1id'],
              to: payload.newRecord['user2id'],
              isRead: false,
              user: us,
              type: type,
            );
            addMsg(m);
          },
        )
        .subscribe();
  }

  void updateState(ChatsState state) {
    this.state = state;
  }

  void updateReadStatus(int chid) {}
  void addMsg(Massage msg) {
    state = state.copyWith(allChats: [...state.allChats,msg]);
    print(state.allChats);
  }

  void updateLastMsg(int chid, String msg) {}
}

// bro we need a class for two persons it will keep record of all the messages between them
class Chat {
  final String key;
  final List<Post> allPosts;

  const Chat({
    required this.key,
    required this.allPosts,
  });

  Chat copyWith({String? key, List<Post>? allPosts}) {
    return Chat(
      key: key ?? this.key,
      allPosts: allPosts ?? this.allPosts,
    );
  }
}
class ChatNotifier extends StateNotifier<Map<String,Chat>> {
  ChatNotifier():super({}){
    _init_channel();
  }
late RealtimeChannel channel;
  void _init_channel() {
    // postgres kelie live listening channel bnao for this user bro
    channel = Supabase.instance.client
        .channel('public:posts').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'posts',
      callback: (payload) async {
        if(payload.newRecord['sender_id']==currUser || payload.newRecord['reciever_id']==currUser){
          Post p=Post.getPost(payload.newRecord);
          int curr=0,other=0;
          if(payload.newRecord['sender_id']==currUser){
            curr=payload.newRecord['sender_id'];
            other=payload.newRecord['reciever_id'];
          }else{
            curr=payload.newRecord['reciever_id'];
            other=payload.newRecord['sender_id'];
          }
          String key='curr_user${curr}_other_user$other';
          print('bro11$p');
          print(payload.newRecord);
          // map ko muatate nahi krna sb object ko hilana
          final newState = Map<String, Chat>.from(state);

          if (newState.containsKey(key)) {
            final chat = newState[key]!;
            newState[key] = chat.copyWith(
                allPosts: [...chat.allPosts, p]
            );
          } else {
            newState[key] = Chat(key: key, allPosts: [p]);
          }
          // Single state update
          state = newState;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if(sc.hasClients){
              sc.animateTo(sc.position.maxScrollExtent, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
            }
          },);
        }
      }
      ).subscribe();
  }
  // let it be one for one // family ni koi
  void addPost(Post p,String key) {
    print('$p and $key \n\n\\n\n\n');
    state[key]??=Chat(key: key, allPosts: []);
    state={
      ...state,
      key:state[key]!.copyWith(allPosts: [...state[key]!.allPosts, p])
    };
  }
}
final ChatManagerP=StateNotifierProvider<ChatNotifier,Map<String,Chat>>((ref) => ChatNotifier(),);

//late RealtimeChannel channel;
//   void _init_channel() {
//     // postgres kelie live listening channel bnao for this user bro
//     channel = Supabase.instance.client
//         .channel('public:posts').onPostgresChanges(
//       event: PostgresChangeEvent.insert,
//       schema: 'public',
//       table: 'posts',
//       callback: (payload) async {
//         if(payload.newRecord['sender_id']==currUser || payload.newRecord['reciever_id']==currUser){
//           Post p=Post.getPost(payload.newRecord);
//           int curr=0,other=0;
//           if(payload.newRecord['sender_id']==currUser){
//             curr=payload.newRecord['sender_id'];
//             other=payload.newRecord['reciever_id'];
//           }else{
//             curr=payload.newRecord['reciever_id'];
//             other=payload.newRecord['sender_id'];
//           }
//
//           state = state.copyWith(allPosts: [...state.allPosts, p]);
//         }
//       }
//       ).subscribe();
//   }