import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Search Bar Example')),
        body: Center(child: CustomSearchBar()),
      ),
    );
  }
}

// 自定义组件库
class CustomWidgets {
  static Widget searchBar({required Function(String) onSearchSubmitted}) {
    TextEditingController _searchController = TextEditingController();

    void submitSearch(String value) {
      onSearchSubmitted(value);
      _searchController.clear(); // 可选：搜索后清空输入框
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "搜索",
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: submitSearch,
      ),
    );
  }
}


// 使用自定义SearchBar的页面
class CustomSearchBar extends StatefulWidget {
  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  TextEditingController _searchController = TextEditingController();

  void _performSearch(String query) {
    // 在这里处理搜索提交的逻辑
    print('Search submitted: $query');
  }

  @override
  Widget build(BuildContext context) {
    void handleSearch(String query) {
      // 实现您的搜索逻辑
      print("搜索内容: $query");
    }

    return Scaffold(
      appBar: AppBar(title: Text('Search App')),
      body: Center(
        child: CustomWidgets.searchBar(onSearchSubmitted: handleSearch),
      ),
    );
  }
}
