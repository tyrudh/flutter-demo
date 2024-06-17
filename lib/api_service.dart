import 'network_helper.dart';
import 'user.dart';
import 'dart:convert'; // 确保导入dart:convert库
import 'package:http/http.dart' as http;


class ApiService {
  static const String _baseUrl = 'http://10.244.102.34:8080'; // 替换为实际后端URL

  Future<User> getUserInfo() async {
    final url = '$_baseUrl/user/getUser'; // 假设API路径为获取当前用户信息
    final data = await fetchFromApi(url);
    return User.fromMap(data);
  }
  Future<User> getUser(String phone) async {
    final url = '$_baseUrl/user/getUser'; // 假设API路径为获取当前用户信息
    final data = await FromApi(url, queryParameters: {'phone': phone});
    return User.fromMap(data);
  }
  Future<User> updateUser(User updatedUser) async {
    // 实现更新用户的网络请求逻辑
    // 这里仅示意，具体实现会根据您的后端接口而定
    // 假设updateUserEndpoint是更新用户信息的API端点
    // 设置请求头，确保服务器能识别数据格式
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse("http://10.244.102.34:8080/user/save"),
      headers: headers,
      body: jsonEncode(updatedUser.toMap()),
    );
    if (response.statusCode == 200) {
      final updatedUserData = jsonDecode(response.body);
      return User.fromMap(updatedUserData);
    } else {
      throw Exception("Failed to update user");
    }
  }

}
