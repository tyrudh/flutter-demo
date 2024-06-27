class Comment {
  final int id;
  final String content;
  final String commentTime;
  final String likeCount;
  final String userId;
  final String username; // 注意：这个字段在后端是非数据库字段（exist = false）
  final String thingId;
  final String title; // 这个字段在后端是非数据库字段（exist = false）
  final String cover; // 这个字段在后端是非数据库字段（exist = false）
  final String commentUser;
  final String replyId;

  Comment({
    this.id = -1,
    this.content = '',
    this.commentTime = '',
    this.likeCount = '',
    this.userId ='',
    this.username = '', // 默认值为空字符串，因为后端不直接提供
    this.thingId = '',
    this.title = '11', // 同上，默认值为空字符串
    this.cover = '11', // 同上，默认值为空字符串
    this.commentUser = '',
    this.replyId = '',
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final coverValue = json['cover'] as String? ?? '';
    return Comment(
      id: json['id'] as int,
      content: json['content'] as String,
      commentTime: json['commentTime'] as String,
      likeCount: json['likeCount'] as String,
      userId: json['userId'] as String,
      username: json.containsKey('username') ? json['username'] as String : '',
      thingId: json['thingId'] as String,
      title: json['title']??'',
      cover: coverValue,
      commentUser: json['commentUser'] as String,
      replyId: json['replyId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'commentTime': commentTime,
      'likeCount': likeCount,
      'userId': userId,
      'username': username,
      'thingId': thingId,
      'title': title,
      'cover': cover,
      'commentUser': commentUser,
      'replyId': replyId,
    };
  }
}
