import 'package:gupshup/utils.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZigoController {
  static final ZigoController _zigoController=ZigoController._internal();
  factory ZigoController()=> _zigoController;
  ZigoController._internal(); // named ctor
  bool _initialized = false;

  Future<void> initZigo(String userID, String userName) async {
    if (_initialized) return; // prevent double init

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Utils.appId,
      appSign: Utils.appSign, 
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    _initialized = true;
    print("🔥 ZEGO INIT DONE for $userID");
  }

  Future<void> uninit() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _initialized = false;
  }
}