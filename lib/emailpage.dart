import 'package:bottomnavigationbar/model/Video.dart';
import 'package:bottomnavigationbar/page/VideoPlayerPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bottomnavigationbar/services/api_service.dart';

import 'model/UserProvider.dart'; // 确保路径正确，根据实际情况调整

class RecommendedVideosScreen extends StatefulWidget {
  @override
  _RecommendedVideosScreenState createState() => _RecommendedVideosScreenState();
}

class _RecommendedVideosScreenState extends State<RecommendedVideosScreen> {
  bool _isLoading = false;
  List<VideoModel> _recommendedVideos = []; // 假设这是存储推荐视频数据的列表

  @override
  void initState() {
    super.initState();
    _loadRecommendedVideos(); // 页面初始化时加载数据
  }

  Future<void> _loadRecommendedVideos() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    try {
      ApiService apiService = ApiService();
      final recommendedVideos = await apiService.fetchRecommendedVideos(user!.id); // 等待异步操作完成
      setState(() {
        _recommendedVideos = recommendedVideos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching recommended videos: $e');
      setState(() => _isLoading = false);
    }
  }


  Future<void> _onRefresh() async {
    await _loadRecommendedVideos(); // 下拉刷新时重新加载数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("推荐视频"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh, // 设置下拉刷新的回调
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // 加载中显示的Widget
            : ListView.builder(
          itemCount: _recommendedVideos.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5, // 卡片阴影效果
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // 圆角
              child: InkWell( // 处理点击事件
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerPage(videoModel: _recommendedVideos[index]),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio( // 保持视频封面的宽高比
                      aspectRatio: 16 / 9,
                      child: Image.network(ApiService.baseUrl + '/staticfiles/image/'+
                        _recommendedVideos[index].coverUrl, // 假设每个VideoModel有thumbnailUrl属性
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _recommendedVideos[index].title,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

