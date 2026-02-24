import 'package:flutter/material.dart';
class User1{
  final Image dp;
  final String bio;
  final String username;
  final String name;
  final int id;
  User1({required this.bio,required this.name,required this.dp,required this.username, required this.id});
  static User1 getUser(Map<String,dynamic> mp) {
    print(mp);
   String url=mp['dp'];
   Image img=url.isEmpty?Image.asset('lib/assets/images/khali.webp'): Image.network(url);
   return User1(bio: mp['bio'], name: mp['name'], dp: img, username: mp['username'], id: mp['id']);
  }
  User1 copyWith({String? bio,String? name,Image? dp,String? username,int? id}){
    return User1(bio: bio??this.bio, name: name??this.name, dp: dp??this.dp, username: username??this.username, id: id??this.id);
  }
  Image getImage(){
    return dp;
  }
  @override
  String toString() {
    return 'User1(bio: $bio, name: $name username: $username)';
  }
}
