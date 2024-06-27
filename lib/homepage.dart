import 'dart:convert';
import 'package:bottomnavigationbar/page/SearchResultPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bottomnavigationbar/model/Video.dart'; // 确保路径正确，根据实际情况调整
import 'package:bottomnavigationbar/services/api_service.dart'; // 确保路径正确，根据实际情况调整
import 'package:bottomnavigationbar/page/VideoPlayerPage.dart'; // 确保路径正确，根据实际情况调整
import 'package:bottomnavigationbar/page/search_bar.dart' as CustomWidgets;
class BilibiliColors {
  static const Color primaryColor = Color(0xffe54e42);
  static const Color textColor = Color(0xff222222);
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: BilibiliColors.primaryColor,
        textTheme: TextTheme(bodyText1: TextStyle(color: BilibiliColors.textColor)),
      ),
      home: HomePageScreen(),
    );
  }
}

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<String> _searchSuggestions = [];
  late ScrollController _scrollController;
  int _pageNum = 1;
  bool _hasMore = true; // 是否还有更多数据
  List<VideoModel> _videos = []; // 存储所有视频

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_onScroll);
    _loadMoreVideos(); // 初始加载第一页数据
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreVideos() async {
    try {
      final videoResponse = await ApiService().fetchVideos(
          pageNum: _pageNum, pageSize: 10);
      if (mounted) {
        setState(() {
          if (videoResponse.videos.isEmpty) {
            _hasMore = false;
          } else {
            _videos.addAll(videoResponse.videos);
            _pageNum++;
          }
        });
      }
    } catch (e) {
      print('Error loading more videos: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter == 0 && _hasMore) {
      _loadMoreVideos(); // 当滑动到最底部且还有更多数据时加载下一页
    }
  }

  TextEditingController _searchController = TextEditingController(); //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 120),
        child: Column(
          children: [
            // 搜索栏及搜索建议容器
            Column(
              children: [
                // 搜索框
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索视频',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text); // 搜索操作
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      // 在这里调用获取搜索建议的方法
                      _getSearchSuggestions(value);
                    },
                  ),
                ),
                // 搜索建议列表，仅当有建议时显示
                if (_searchSuggestions.isNotEmpty)
                  SizedBox(
                    height: 70, // 根据需要调整高度
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchSuggestions[index]),
                          onTap: () {
                            _searchController.text = _searchSuggestions[index];
                            setState(() {
                              _searchSuggestions.clear(); // 清除建议
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            // 分类标签栏保持不变
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min, // 尝试减小主轴的大小
                children: [
                  _buildTagButton('游戏'),
                  _buildTagButton('动漫'),
                  _buildTagButton('音乐'),
                  // 添加更多标签
                ],
              ),
            ),
          ],
        ),
      ),
    body: Container(
    height: 500, // 例如，设置为屏幕高度的80%，根据需要调整
    child: NotificationListener<ScrollEndNotification>(
    onNotification: (notification) {
    if (notification.metrics.extentAfter == 0 && _hasMore) {
    _loadMoreVideos();
    return true;
    }
    return false;
    },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _videos.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _videos.length) {
              return _buildVideoCard(_videos[index]);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    ),
    );
  }


  // 修改后的_buildVideoCard方法
  Widget _buildVideoCard(VideoModel video) {
    final String imageUrlPrefix = ApiService.baseUrl + '/staticfiles/image/';
    final String imageUrl = imageUrlPrefix + video.coverUrl;

    return GestureDetector(
      onTap: () {
        // 导航到VideoPlayerPage
        final int videoId = video.id; // 假设VideoModel中有id字段
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => VideoPlayerPage(videoModel: video)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Center(child: Text('图片加载失败'));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title),
                  SizedBox(height: 4),
                  Text('${video.pv}播放',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300), // 使用shade直接避免混淆
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 14)),
    );
  }


// 确保你有定义_performSearch方法来处理搜索逻辑
  void _performSearch(String query) async {

    try {
      // 构建请求URL，这里假设您的API接受一个名为'keyword'的查询参数
      String url = ApiService.baseUrl +
          "/video/list?keyword=$query&pageNum=1&pageSize=100";

      // 发起HTTP GET请求
      final response = await http.get(Uri.parse(url));


      // 检查响应状态码
      if (response.statusCode == 200) {
        Utf8Decoder decode = new Utf8Decoder();
        final Map<String, dynamic> parsedJson = jsonDecode(decode.convert(response.bodyBytes));
        // 解析响应体中的JSON数据


        // 假设API响应结构中包含一个名为'results'的键，用于存放搜索结果
        List<dynamic> videoDataList = parsedJson['data']['video'];

        // 检查是否有搜索结果
        if (videoDataList.isNotEmpty) {
          // 导航到SearchResultPage并传递搜索结果
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultPage(videoList: videoDataList),
            ),
          );
        } else {
          // 如果没有结果，可以提示用户
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('没有找到相关结果')),
          );
        }
      } else {
        // 处理错误情况
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败，请重试')),
        );
      }
    } catch (e) {
      // 网络请求或解析过程中出现异常
      print('搜索过程中发生错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索过程中发生错误')),
      );
    }
  }

  Future<void> _getSearchSuggestions(String query) async {
    Utf8Decoder decode = new Utf8Decoder();

    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = []; // 清空建议列表
      });
      return;
    }

    try {
      String url = "${ApiService.baseUrl}/video/suggestion?key=$query";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(decode.convert(response.bodyBytes));
        if (data.containsKey('data')) { // 确保数据中包含'suggestions'
          final List<dynamic> suggestionsJson = data['data'];
          setState(() {
            _searchSuggestions = suggestionsJson.cast<String>(); // 直接转换为字符串列表
          });
        } else {
          setState(() {
            _searchSuggestions = []; // 如果'data'不存在，清空建议列表
          });
        }
      } else {
        setState(() {
          _searchSuggestions = [];
        });
        // 可以根据statusCode添加更详细的错误处理逻辑
      }
    } catch (e) {
      print('获取搜索建议出错: $e');
      setState(() {
        _searchSuggestions = [];
      });
    }
  }
}
