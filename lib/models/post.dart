class Post {
  final int sender_id;
  final int reciever_id;
  final String data; // if type is text then data is massage else data is url of image
  final String type;
  Post({required this.sender_id,required this.reciever_id,required this.data,required this.type});
  Post copyWith({int? sender_id,int? reciever_id,String? data,String? type}){
    return Post(sender_id: sender_id??this.sender_id, reciever_id: reciever_id??this.reciever_id, data: data??this.data, type: type??this.type);
  }
  static Post getPost(Map<String,dynamic> mp){
    return Post(sender_id: mp['sender_id'], reciever_id: mp['reciever_id'], data: mp['data'],
        type: mp['type']);
  }
  @override
  String toString() {
    return 'Post(sender_id: $sender_id, reciever_id: $reciever_id, data: $data, type: $type)';
  }
}