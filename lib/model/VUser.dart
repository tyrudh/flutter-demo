class VUser {
  final String id;
  late final String username;
  final String password;
  final String rePassword = ''; // 非数据库字段，默认为空字符串
  final String nickname;
  late final String mobile;
  late final String email;
  final String description;
  final String role;
  final String earning;
  final String status;
  final String score;
  final String avatar;
  final String token;
  final String createTime;
  final String pushEmail;
  final String pushSwitch;
  final String vip;

  VUser({
    required this.id,
    required this.username,
    required this.password,
    this.nickname = '',
    this.mobile = '',
    this.email = '',
    this.description = '',
    this.role = '',
    this.earning = '',
    this.status = '',
    this.score = '',
    this.avatar = '',
    required this.token,
    required this.createTime,
    this.pushEmail = '',
    this.pushSwitch = '',
    this.vip = '',
  });

  factory VUser.fromJson(Map<String, dynamic> json) {
    return VUser(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      nickname: json['nickname'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String,
      description: json['description'] as String,
      role: json['role'] as String,
      earning: json['earning'] as String,
      status: json['status'] as String,
      score: json['score'] as String,
      token: json['token'] as String,
      createTime: json['createTime'] as String,
      pushEmail: json.containsKey('pushEmail') ? json['pushEmail'] as String : '',
      pushSwitch: json.containsKey('pushSwitch') ? json['pushSwitch'] as String : '',
      vip: json['vip'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nickname': nickname,
      'mobile': mobile,
      'email': email,
      'description': description,
      'role': role,
      'earning': earning,
      'status': status,
      'score': score,
      'avatar': avatar,
      'token': token,
      'createTime': createTime,
      'pushEmail': pushEmail,
      'pushSwitch': pushSwitch,
      'vip': vip,
    };
  }
}
