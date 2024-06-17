import 'package:flutter/material.dart';
import 'user.dart';
import 'api_service.dart';
import 'dart:convert'; // 确保导入dart:convert库
import 'package:shared_preferences/shared_preferences.dart';

class AirPlayPageScreen extends StatefulWidget {
  @override
  _AirPlayPageScreenState createState() => _AirPlayPageScreenState();
}

class _AirPlayPageScreenState extends State<AirPlayPageScreen> {
  User? _user;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // 示例数据，实际应用中应从持久化存储或其他来源获取用户信息
  //   _user = User(
  //     name: "张三",
  //     email: "zhangsan@example.com",
  //     phoneNumber: "13812345678",
  //   );
  // }
  late Future<User> _futureUser;
  bool _isLoading = true;
  User _initialUser = User(); // 初始化一个空的User对象来存放初始数据

  @override
  void initState() {
    super.initState();

    _fetchAndSetUserData();
  }
  Future<void> _fetchAndSetUserData() async {
   final apiService = ApiService();

   SharedPreferences prefs = await SharedPreferences.getInstance();

   String? phone = prefs.getString('phone_number');
   try {
     final user = await apiService.getUser(phone!);
     final decodedName = utf8.decode(utf8.encode(user.name!));
     print("Raw user data: ${user.name}, ${user.email}, ${user.phone}");
     setState(() {
       _initialUser = User(
         id: user.id,
         name: user.name,
         email: user.email,
         phone: user.phone,
       ); // 存储原始数据
       _user = user;
       _isLoading = false;

     });
   } catch (e) {
     print("Error fetching user data: $e");
     setState(() {
       _isLoading = false;
     });
   }
  }

  Widget _buildEditProfileForm() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "姓名"),
                onChanged: (value) {
                  setState(() {
                    _user!.name = value;
                  });
                },
                controller: TextEditingController(text: _user?.name ?? ""),
              ),
              TextField(
                decoration: InputDecoration(labelText: "邮箱"),
                onChanged: (value) {
                  setState(() {
                    _user!.email = value;
                  });
                },
                controller: TextEditingController(text: _user?.email ?? ""),
              ),
              TextField(
                decoration: InputDecoration(labelText: "手机号"),
                onChanged: (value) {
                  setState(() {
                    _user!.phone = value;
                  });
                },
                controller: TextEditingController(text: _user?.phone ?? ""),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("取消"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // TODO: 实现保存更新后的用户信息到持久化存储
                      // 确保有更新才发起请求
                      final apiService = ApiService();
                      if (_user != null && (_user!.name != _initialUser.name ||
                      _user!.email != _initialUser.email ||
                      _user!.phone != _initialUser.phone)) {
                      try {
                      final updatedUser = await apiService.updateUser(_user!);
                      // 更新成功，可以弹出提示或更新UI等
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("用户信息更新成功")));

                      _fetchAndSetUserData();

                      // 如果需要，可以在这里刷新页面数据，比如再次调用_fetchAndSetUserData()
                      Navigator.pop(context); // 关闭模态框
                      } catch (e) {
                      // 显示错误信息
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("更新用户信息时发生错误: $e")));
                      }
                      } else {
                      // 如果没有变化，直接关闭模态框
                      Navigator.pop(context);
                      }
                    },
                    child: Text("保存"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的主页"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => _buildEditProfileForm(),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("个人资料", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(_user?.name ?? ""),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text(_user?.email ?? ""),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text(_user?.phone ?? ""),
          ),
        ],
      ),
    );
  }
}
