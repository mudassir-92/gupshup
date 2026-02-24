// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:flutter_webrtc/flutter_webrtc.dart';
//
// class SocketService {
//   // make it factory  style
//   static final SocketService _socketService=SocketService._internal();
//   factory SocketService()=> _socketService;
//   SocketService._internal(); // named ctor
//
//
//   IO.Socket? socket;
//   void connectToSocket(String myUserId) {
//     socket = IO.io(
//       "https://gupshup-backend-fayk.onrender.com",
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .enableAutoConnect()
//           .build(),
//     );
//     socket!.connect();
//     socket!.onConnect((_){
//       // jb socket se connect ho
//       print('socket connected to ${socket!.id}');
//       socket!.emit('register',myUserId);
//     });
//     socket!.onDisconnect((_){
//       print('disconnected');
//     });
//   }
//   // do other things
// }