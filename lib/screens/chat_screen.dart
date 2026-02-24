import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gupshup/Controller/calls_provider.dart';
import 'package:gupshup/models/call.dart';
import 'package:gupshup/screens/chat_tab_screen.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../Controller/chat_provider.dart';
import '../models/post.dart';
import '../models/user.dart';

final msgProvider = StateProvider<String>((ref) => '');
ScrollController sc = ScrollController();
User1? otherUserGlobal;

class ChatScreen extends ConsumerStatefulWidget {
  final int currentUsr;
  final User1 otherUsr;
  const ChatScreen({
    super.key,
    required this.currentUsr,
    required this.otherUsr,
  });
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final msgController = TextEditingController();
  String toPrint = "kch nahi bro";

  Future<void> callUser(String type) async {
    // first insert it into the calls table bro
    await Supabase.instance.client.from('calls').insert({
      'caller': widget.currentUsr,
      'callee': widget.otherUsr.id,
      'type': type,
    });
    // do a call
    ref.read(callsProvider.notifier).addCall(Call(caller:'' , callee: otherUserGlobal!.name, type: 'video'.compareTo(type) == 0?'video':'audio',
     timestamp: DateTime.now().toString(), callerId: currUser, calleeId: otherUserGlobal!.id));
    ZegoUIKitPrebuiltCallInvitationService().send(
      invitees: [
        ZegoCallUser(widget.otherUsr.id.toString(), widget.otherUsr.username),
      ],
      isVideoCall: 'video'.compareTo(type) == 0,
    );
  }

  // load all chats bro and feed it to the provider and get all from provider
  Future<void> loadQoutaBro() async {
    otherUserGlobal = widget.otherUsr;
    // print('Loading\n'*100);
    isLoading = true;
    print('got ${[widget.currentUsr, widget.otherUsr.id]}');
    var ls = [widget.currentUsr, widget.otherUsr.id];
    ls.sort((a, b) => b.compareTo(a));
    List<Map<String, dynamic>> chatss = await Supabase.instance.client
        .from('posts')
        .select()
        .inFilter('sender_id', [widget.currentUsr, widget.otherUsr.id])
        .inFilter('reciever_id', [widget.currentUsr, widget.otherUsr.id])
        .order('created_at', ascending: true);
    // print(chatss);
    if (ref.read(ChatManagerP).isNotEmpty) {
      isLoading = false;
      setState(() {});
      return;
    }
    for (Map<String, dynamic> chat in chatss) {
      // in this chat decide if who is sender
      int currUser, otherUser;
      if (chat['sender_id'] == widget.currentUsr) {
        // then it is sender
        currUser = chat['sender_id'];
        otherUser = chat['reciever_id'];
      } else {
        // then it is receiver
        otherUser = chat['sender_id'];
        currUser = chat['reciever_id'];
      }
      // print('inserting\n'*10);
      ref
          .read(ChatManagerP.notifier)
          .addPost(
            Post.getPost(chat),
            'curr_user${currUser}_other_user$otherUser',
          );
      print(ref.read(ChatManagerP));
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadQoutaBro();
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (sc.hasClients) {
        sc.jumpTo(sc.position.maxScrollExtent);
      }
    });
    String key =
        'curr_user${widget.currentUsr}_other_user${widget.otherUsr.id}';
    // print(key);
    // print('aa\n\n' * 200);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0, // Remove default title spacing
        title: Row(
          children: [
            CircleAvatar(backgroundImage: widget.otherUsr.dp.image, radius: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUsr.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${widget.otherUsr.username}',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              callUser('video');
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              callUser('audio');
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () async {}),
        ],
        backgroundColor: Colors.purple[50],
      ),
      bottomSheet: Row(
        children: [
          Expanded(
            child: TextField(
              controller: msgController,
              onTap: () async {
                await Future.delayed(Duration(milliseconds: 500));
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  if (sc.hasClients) {
                    sc.animateTo(
                      sc.position.maxScrollExtent,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              },
              onChanged: (value) {
                ref.read(msgProvider.notifier).state = msgController.text;
              },
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              var msgField = ref.watch(msgProvider);
              return IconButton(
                icon: Icon(
                  Icons.send,
                  color: msgField.isEmpty ? Colors.grey : Colors.blue,
                ),
                onPressed: () async {
                  if (msgField.isNotEmpty) {
                    // then send msg bro
                    try {
                      int senderId = widget.currentUsr;
                      int receiverId = widget.otherUsr.id;
                      // send the msg bro
                      await Supabase.instance.client.from('posts').insert({
                        'sender_id': senderId,
                        'reciever_id': receiverId,
                        'type': 'text',
                        'data': msgField,
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    } finally {
                      ref.read(msgProvider.notifier).state = '';
                      msgController.clear();
                    }
                  }
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              XFile? img = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 30,
              );
              if (img != null) {
                File file = File(img.path);
                final editedImage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImageEditor(image: file.readAsBytesSync()),
                  ),
                );
                if (editedImage != null) {
                  try {
                    final appDir = await getApplicationDocumentsDirectory();
                    final Docum = appDir.path;
                    File fil = File(
                      '$Docum/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
                    );
                    await fil.writeAsBytes(editedImage);
                    // now upload as post
                    // first upload it own Storage
                    String fileNameOfUploadShouldBe =
                        '${widget.currentUsr}/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
                    await Supabase.instance.client.storage
                        .from('store')
                        .upload(fileNameOfUploadShouldBe, fil);
                    String url = Supabase.instance.client.storage
                        .from('store')
                        .getPublicUrl(fileNameOfUploadShouldBe);
                    await Supabase.instance.client.from('posts').insert({
                      'sender_id': widget.currentUsr,
                      'reciever_id': widget.otherUsr.id,
                      'type': 'image',
                      'data': url,
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Image uploaded')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 10),
                        content: Text(e.toString()),
                      ),
                    );
                  }
                }
                // print('thaa\n'*1000);
                // now upload the image
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/chatBG.png',
              fit: BoxFit.scaleDown,
              opacity: const AlwaysStoppedAnimation(.5),
            ),
          ),
          isLoading
              ? JumpingDots()
              : Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 50,
                  child: Consumer(
                    builder: (context, ref, child) {
                      // Watch the entire ChatManager state
                      final chatState = ref.watch(ChatManagerP);

                      final chat = chatState[key];

                      if (chat == null) {
                        return Center(child: Text('No Message :('));
                      }

                      print('Chat updated: $chat');

                      final posts = chat.allPosts;

                      return ListView.separated(
                        controller: sc,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final isSender = widget.currentUsr == post.sender_id;

                          return Align(
                            alignment: isSender
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft,
                            child: buildTheMassageBro(
                              post.type,
                              context,
                              post.data,
                              left: !isSender,
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: 10);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

Widget buildTheMassageBro(
  String type,
  BuildContext context,
  String data, {
  bool left = true,
}) {
  var size = MediaQuery.of(context).size;
  if ('text'.compareTo(type) == 0) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: size.width * 0.75),
      child: Container(
        // width: size.width * 0.75,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: left ? Colors.blue.shade100 : Colors.green.shade100,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(data, style: TextStyle(fontSize: 18)),
      ),
    );
  } else if ('image'.compareTo(type) == 0) {
    return GestureDetector(
      onTap: () {
        showImageViewer(
          context,
          useSafeArea: true,
          CachedNetworkImageProvider(data),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: size.width * 0.25,
          maxWidth: size.width * 0.75,
          minHeight: size.height * 0.25,
          maxHeight: size.height * 0.75,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.cyan.shade50,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          clipBehavior: Clip.hardEdge,
          child: CachedNetworkImage(
            imageUrl: data,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return LoadingAnimationWidget.inkDrop(
                color: Colors.purple,
                size: 50,
              );
            },
            errorWidget: (context, url, error) =>
                Center(child: Icon(Icons.error, color: Colors.red, size: 40)),
          ),
        ),
      ),
    );
  } else if ('voice'.compareTo(type) == 0) {
    // audio do
    return Column();
  } else {
    return Container();
  }
}
