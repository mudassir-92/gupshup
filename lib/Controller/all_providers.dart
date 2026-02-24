// name of every provider should be meaning full boss
import 'package:flutter_riverpod/legacy.dart';

final profileProvider=StateNotifierProvider<ProfileNotifier,ProfileState>(
    (ref)=>ProfileNotifier()
);

class ProfileState{
  final String name;
  final String dp;
  final String bio;
  ProfileState({required this.name,required this.dp,required this.bio});
  ProfileState copyWith({String? name,String? dp,String? bio}){
    return ProfileState(name: name??this.name, dp: dp??this.dp, bio: bio??this.bio);
  }
  @override
  String toString() {
   return 'ProfileState(name: $name, dp: $dp, bio: $bio)';
  }
}
class ProfileNotifier extends StateNotifier<ProfileState>{
  ProfileNotifier():super(ProfileState(name: '', dp: '', bio: ''));
  // update the state bro
  void updateName(String name){
    state=state.copyWith(name: name);
  }
  void updateDp(String dp){
    state=state.copyWith(dp: dp);
  }
  void updateBio(String bio){
    state=state.copyWith(bio: bio);
  }
  void updateState(ProfileState state){
    this.state=state;
  }
}
