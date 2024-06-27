import 'dart:convert';

// import 'package:bottomnavigationbar/api_service.dart';
import 'package:flutter/material.dart';
import 'package:bottomnavigationbar/model/Video.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // 确保路径正确，根据实际情况调整
import 'package:http/http.dart' as http;
import 'package:bottomnavigationbar/services/api_service.dart'; // 确保路径正确，根据实际情况调整
import 'package:bottomnavigationbar/model/Comment.dart';

import '../model/UserProvider.dart'; // 确保路径正确，根据实际情况调整

// 假设你有一个VideoPlayerPage用来显示视频播放界面
Future<VideoModel> fetchVideoDetails(int videoId) async {
  final response = await http.get(Uri.parse("https://your-api-url.com/videos/$videoId"));
  if (response.statusCode == 200) {
    return VideoModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load video details');
  }
}

class VideoPlayerPage extends StatefulWidget {
  final VideoModel videoModel;

  const VideoPlayerPage({required this.videoModel});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isLiked = false;
  bool _isCollected = false;
  bool _isPlaying = false;
  List<Comment> _comments = [];

  String _commentText = ''; // 用于存储用户输入的评论
  bool _isSendingComment = false; // 标记是否正在发送评论

  @override
  void initState() {
    super.initState();
    if (widget.videoModel.rawUrl.isNotEmpty) {
      _prepareVideoPlayer();
      _fetchComments(widget.videoModel.id); // 假设videoModel有id属性
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  // 新增的fetchComments方法
  Future<void> _fetchComments(int videoId) async {
    try {
      final String videoIdStr = videoId.toString();
      final comments = await ApiService.fetchComments(videoIdStr);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      print('Failed to load comments: $e');
    }
  }


  Future<void> _sendComment() async {
    setState(() => _isSendingComment = true); // 设置正在发送状态
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    try {
      final newComment = Comment(
        content: _commentText,
          userId: user!.id,
          thingId: widget.videoModel.id.toString(),
          title: widget.videoModel.title,
          commentUser: '3',
          replyId: '',
          likeCount: '0',
          // commentTime: DateTime.now().toIso8601String(), // 获取当前时间并转换为ISO8601格式
        // 其他必要字段，如userId, thingId（此处应为widget.videoModel.id）等
        // ...
      );
      // 假设sendComment方法接收视频ID和评论内容作为参数
      await ApiService.sendCommentAsMultipart(newComment);
      // 发送成功后，清空输入框并刷新评论列表
      setState(() {
        _commentText = '';
        _fetchComments(widget.videoModel.id); // 重新获取评论列表
        _isSendingComment = false; // 发送完成
      });
    } catch (e) {
      print('Failed to send comment: $e');
      setState(() => _isSendingComment = false); // 发送失败也要重置状态
    }
  }

  Future<void> _prepareVideoPlayer() async {

    final fullUrl =  ApiService.baseUrl+'/staticfiles/raw/${widget.videoModel.rawUrl}';
    _controller = VideoPlayerController.network(fullUrl)
      ..initialize().then((_) {
        setState(() {});
        if (!_controller.value.isPlaying) _controller.play();
        _isPlaying = true; // 初始化播放状态
      });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    // 实现点赞逻辑...
  }

  void _toggleCollect() {
    setState(() => _isCollected = !_isCollected);
    // 实现收藏逻辑...
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("视频播放")),
      body: Column(
        children: [
          if (_controller.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          else
            Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('作者: ${widget.videoModel.nickName}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(widget.videoModel.description ?? '', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: _isLiked ? Icon(Icons.thumb_up) : Icon(Icons.thumb_up_outlined),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: _isCollected ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
                onPressed: _toggleCollect,
              ),
            ],
          ),
          // 播放/暂停按钮和进度条
          if (_controller.value.isInitialized)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                Expanded(
                  child: Slider(
                    value: _controller.value.position.inMilliseconds.toDouble(),
                    min: 0.0,
                    max: _controller.value.duration.inMilliseconds.toDouble(),
                    onChanged: (position) {
                      setState(() {
                        _controller.seekTo(Duration(milliseconds: position.toInt()));
                      });
                    },
                  ),
                ),
              ],
            ),
          // 示例评论区
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                    leading: CircleAvatar(
                      child: Text(comment.username[0].toUpperCase()),
                    ),
                    title: Text(comment.content),
                    subtitle: Text(comment.commentTime),
                );
              },
            ),

          ),
          // 分割线，可选，用于视觉上分隔评论列表和输入框
          Divider(height: 1),
          // 评论输入框和发送按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '请输入您的评论...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _commentText = value,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSendingComment ? null : _sendComment,
                  child: Text(_isSendingComment ? '发送中...' : '发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}