import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bottomnavigationbar/model/Video.dart';
import 'package:bottomnavigationbar/model/Comment.dart';
import 'package:provider/provider.dart';

import '../model/UserProvider.dart';
import '../model/VUser.dart';

class ApiService {
  static const String baseUrl = 'http://10.100.33.117:8080/api'; // 替换为你的后端地址

  Utf8Decoder decode = new Utf8Decoder();

  Future<VideoResponse> fetchVideos(
      {int pageNum = 1, int pageSize = 10}) async {
    try {
      final url = '$baseUrl/video/list?pageNum=$pageNum&pageSize=$pageSize';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedJson = jsonDecode(decode.convert(response.bodyBytes));
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

  //获取视频评论区评论
  static Future<List<Comment>> fetchComments(String videoId) async {
    Utf8Decoder decoded = new Utf8Decoder();

    final response = await http.get(Uri.parse(
        '$baseUrl/comment/listThingComments?thingId=$videoId&order=recent'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(decoded.convert(response.bodyBytes));

      // 确保响应中code为200，表示成功
      if (responseData['code'] == 200) {
        final List<dynamic> data = responseData['data'];
        final List<Comment> commentList = data.map((json) => Comment.fromJson(json)).toList();

        return commentList;
      } else {
        // 可以根据不同的code抛出更具体的异常
        throw Exception(
            'API returned error code: ${responseData['code']} - ${responseData['msg']}');
      }
    } else {
      throw Exception('Failed to load comments due to network issue');
    }
  }


// 发送评论

  static Future<void> sendCommentAsMultipart(Comment comment) async {
    try {
      // 创建MultipartRequest实例
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/comment/create'),
      );

      // 设置请求头
      request.headers['Content-Type'] = 'multipart/form-data;charset=utf-8';
      // 添加授权头部

      // 将Comment对象的每个字段添加为表单项，注意这里我们不添加文件
      comment.toJson().forEach((key, value) {
        request.fields[key] = value.toString(); // 假设Comment的属性都是可转化为字符串的
      });

      // 发送请求并等待响应
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Comment sent successfully');
      } else {
        throw Exception('Failed to send comment. Status code: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Error during sending comment: $e');
    }
  }


  // 新增方法：根据用户ID获取推荐视频
  Future<List<VideoModel>> fetchRecommendedVideos(String userId) async {

    try {
      final url = '$baseUrl/video/getCommend?userId=$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedJson = jsonDecode(utf8.decode(response.bodyBytes));

        // 确保响应中code为成功状态，然后提取视频列表
        if (parsedJson['code'] == 200) {
          final List<dynamic> videoDataList = parsedJson['data'];
          return videoDataList.map((json) => VideoModel.fromJson(json)).toList();
        } else {
          // 根据返回的错误码处理异常
          throw Exception('API returned error code: ${parsedJson['code']} - ${parsedJson['msg']}');
        }
      } else {
        throw Exception('Failed to load recommended videos. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommended videos: $e');
    }
  }



  Future<VUser> getUserDetail(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/user/detail?userId=$userId"));
    if (response.statusCode == 200) {
      Utf8Decoder decoded = new Utf8Decoder();
      final json = jsonDecode(decoded.convert(response.bodyBytes));
      return VUser.fromJson(json['data']);
    } else {
      throw Exception("Failed to load user detail");
    }
  }

}

// 定义一个类来持有视频列表和总数
class VideoResponse {
  final int totalNum;
  final List<VideoModel> videos;

  VideoResponse({required this.totalNum, required this.videos});
}
