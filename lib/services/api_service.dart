import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bottomnavigationbar/model/Video.dart';

class ApiService {
  static const String baseUrl = 'http://10.100.207.43:8080/api'; // 替换为你的后端地址

  Future<VideoResponse> fetchVideos({int pageNum = 1, int pageSize = 10}) async {
    try {
      final url = '$baseUrl/video/list?pageNum=$pageNum&pageSize=$pageSize';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedJson = jsonDecode(response.body);
        final List<dynamic> videoDataList = parsedJson['data']['video'];
        final int totalNum = int.parse(parsedJson['data']['totalNum']);

        // 确保安全地处理可能的null值
        final List<VideoModel> videos = videoDataList != null
            ? videoDataList.map((json) => VideoModel.fromJson(json)).toList()
            : [];

        return VideoResponse(totalNum: totalNum, videos: videos);
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

// 定义一个类来持有视频列表和总数
class VideoResponse {
  final int totalNum;
  final List<VideoModel> videos;

  VideoResponse({required this.totalNum, required this.videos});
}
