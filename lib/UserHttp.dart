import 'package:http/http.dart' as http; // 若使用 dio，则导入 dio 库
import 'user.dart';
import 'dart:convert';

Future<User> getUserInfo() async {
  final url = 'https://your-backend-url/api/users'; // 替换为实际后端 URL
  final response = await http.get(Uri.parse(url)); // 使用 dio 时，使用 dio.get 方法

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return User.fromMap(data); // 使用 User 模型的 fromMap 方法解析 JSON 数据
  } else {
    throw Exception('Failed to load user info');
  }
}

Future<void> updateUserInfo(User updatedUser) async {
  final url = 'https://your-backend-url/api/users';
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode(updatedUser.toMap());

  final response = await http.put(Uri.parse(url), headers: headers, body: body); // 使用 dio 时，使用 dio.put 方法

  if (response.statusCode != 204) {
    throw Exception('Failed to update user info');
  }
}