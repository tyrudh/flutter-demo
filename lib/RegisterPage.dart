import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // 确保导入dart:convert库

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '手机号',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return '密码至少需要6位';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 这里添加注册逻辑，比如调用API
                    _register();
                  }
                },
                child: Text('注册'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 返回登录页面
                },
                child: Text('已有账号？去登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 示例注册逻辑
  Future<void> _register() async {
    // 获取用户输入
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final phone = _phoneController.text;
    // 准备要发送的数据，根据后端要求可能需要调整
    final userData = {
      "username": username,
      "email": email,
      "phone": phone,
      "password": password, // 注意：实际应用中密码应加密处理再发送
    };

    try {
      // 使用http包发送POST请求到后端注册接口
      final response = await http.post(
        Uri.parse("http://localhost:8080/user/register"), // 替换为实际后端API地址
        body: json.encode(userData), // 将数据转换为JSON格式
        headers: {"Content-Type": "application/json"}, // 设置正确的Content-Type
      );

      // 处理响应
      if (response.statusCode == 200) {
        // 注册成功
        print('注册成功');
        // 可以弹出提示信息给用户，然后导航到登录页面
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册成功，请登录！')),
        );
        // 导航到登录页面
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // 注册失败，根据后端返回的错误信息给出提示
        String errorMessage = '注册失败，请稍后重试。';
        if (response.body.isNotEmpty) {
          // 尝试解析后端返回的错误信息
          var errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // 网络请求错误或其他异常
      print('注册过程中发生错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('网络错误，请检查网络连接')),
      );
  }
}
}
