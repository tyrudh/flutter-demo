import 'dart:convert';

// import 'package:bottomnavigationbar/api_service.dart';
import 'package:flutter/material.dart';
import 'package:bottomnavigationbar/model/Video.dart';
import 'package:video_player/video_player.dart'; // 确保路径正确，根据实际情况调整
import 'package:http/http.dart' as http;
import 'package:bottomnavigationbar/services/api_service.dart'; // 确保路径正确，根据实际情况调整

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

  @override
  void initState() {
    super.initState();
    if (widget.videoModel.rawUrl.isNotEmpty) {
      _prepareVideoPlayer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('作者: ${widget.videoModel.nickName}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(widget.videoModel.description ?? '', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('评论 ${index + 1}'),
                  subtitle: Text('这里是评论内容...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}