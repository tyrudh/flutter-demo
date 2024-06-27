import 'package:flutter/material.dart';
import 'dart:convert'; // 确保导入dart:convert库
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bottomnavigationbar/services/api_service.dart';

import 'model/UserProvider.dart';
import 'model/VUser.dart'; // 确保路径正确，根据实际情况调整
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: '邮箱/手机号'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '密码'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 登录逻辑，此处仅为示例，实际应调用API验证
                _attemptLogin();
              },
              child: Text('登录'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: Text('还没有账号？去注册'),
            ),
          ],
        ),
      ),
    );
  }


  // 假设userData包含手机号和姓名，例如：{'phone': '+1234567890', 'name': '张三'}
  void storeUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 存储手机号
    prefs.setString('phone_number', userData['phone']);

    // 存储姓名
    prefs.setString('user_name', userData['name']);
  }

    Future<void> _attemptLogin() async {
      final phoneOrEmail = emailController.text.trim();
      final password = passwordController.text.trim();

      if (phoneOrEmail.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请输入邮箱/手机号和密码')),
        );
        return;
      }
      try {
        final response = await http.post(
          Uri.parse(ApiService.baseUrl+'/user/userLogin'), // 替换为您的登录API地址
          body: {
            'username': phoneOrEmail, // 根据后端接口调整参数名称
            'password': password,
          },
        );

        if (response.statusCode == 200) {
          Utf8Decoder decode = new Utf8Decoder();

          // 登录成功，假设后端返回的是用户信息
          final Map<String, dynamic> userData = json.decode(decode.convert(response.bodyBytes));
          // 可以根据需要存储用户信息，如使用Secure Storage或Shared Preferences
          final Map<String, dynamic> userDataDetails = userData['data'];
          final user = VUser.fromJson(userDataDetails);
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          storeUserData(userData); // 存储用户数据
          // 然后导航到主界面
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // 登录失败，显示错误信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登录失败，请检查您的账号和密码')),
          );
        }
      } on Exception catch (e) {
        // 处理网络请求或解析异常
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录时发生错误: $e')),
        );
      }

  }
}
