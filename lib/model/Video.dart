class VideoModel {
  final int id;
  final String title;
  final String coverUrl;
  final String rawUrl;
  final String description;
  final String status;
  final String createTime;
  final String score;
  final String pv;
  final String recommendCount;
  final String wishCount;
  final String collectCount;
  final int classificationId;
  final int danmuCount;
  final String userId;
  final String nickName;
  final List<String> tags;

  VideoModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.rawUrl,
    required this.description,
    required this.status,
    required this.createTime,
    required this.score,
    required this.pv,
    required this.recommendCount,
    required this.wishCount,
    required this.collectCount,
    required this.classificationId,
    required this.danmuCount,
    required this.userId,
    required this.nickName,
    required this.tags,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0, // 如果'id'为null，则使用0
      title: json['title'] ?? '', // 如果'title'为null，则使用空字符串
      coverUrl: json['cover'] ?? '', // 类似地为其他可能为null的字符串字段设置默认值
      rawUrl: json['raw'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createTime: json['createTime'] ?? '',
      score: json['score'] ?? '0',
      pv: json['pv'] ?? '0',
      recommendCount: json['recommendCount'] ?? '0',
      wishCount: json['wishCount'] ?? '0',
      collectCount: json['collectCount'] ?? '0',
      classificationId: json['classificationId'] ?? 0,
      danmuCount: json['danmuCount'] ?? 0,
      userId: json['userId'] ?? '',
      nickName: json['nickName'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

}
