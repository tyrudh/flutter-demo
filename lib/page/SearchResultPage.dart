import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bottomnavigationbar/model/Video.dart'; // 确保路径正确，根据实际情况调整
import 'package:bottomnavigationbar/services/api_service.dart'; // 确保路径正确，根据实际情况调整
import 'package:bottomnavigationbar/page/VideoPlayerPage.dart'; // 确保路径正确，根据实际情况调整
// import 'package:bottomnavigationbar/page/search_bar.dart' as CustomWidgets
class SearchResultPage extends StatelessWidget {
  final List<dynamic> videoList;

  const SearchResultPage({Key? key, required this.videoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('搜索结果')),
      body: ListView.builder(
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          // 假设每个视频数据是一个Map，包含title和thumbnailUrl字段
          final video = videoList[index];
          return ListTile(
            title: Text(video['title']),
            leading: Image.network(ApiService.baseUrl + '/staticfiles/image/'+video['cover']),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(
                    videoModel: VideoModel.fromJson(video),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
