class ChatUser {
  ChatUser({
    required this.image,
    required this.pushToken,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
  });
  late  String image;
  late  String pushToken;
  late  String about;
  late  String name;
  late  String createdAt;
  late  bool isOnline;
  late  String id;
  late  String lastActive;
  late  String email;

  ChatUser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? '';
    pushToken = json['push_token'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['push_token'] = pushToken;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    return data;
  }
}