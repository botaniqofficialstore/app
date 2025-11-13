class ReelsResponse {
  final int page;
  final int limit;
  final int totalReels;
  final List<ReelData> reels;

  ReelsResponse({
    required this.page,
    required this.limit,
    required this.totalReels,
    required this.reels,
  });

  factory ReelsResponse.fromJson(Map<String, dynamic> json) {
    return ReelsResponse(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 5,
      totalReels: (json['totalReels'] ?? 0),
      reels: (json['reels'] as List<dynamic>?)
          ?.map((e) => ReelData.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ReelData {
  final String reelId;
  final String reelUrl;
  final String caption;
  final int totalLikes;
  final bool isLikedByUser;

  ReelData({
    required this.reelId,
    required this.reelUrl,
    required this.caption,
    required this.totalLikes,
    required this.isLikedByUser,
  });

  factory ReelData.fromJson(Map<String, dynamic> json) {
    return ReelData(
      reelId: json['reelId'] ?? '',
      reelUrl: json['reelUrl'] ?? '',
      caption: json['caption'] ?? '',
      totalLikes: json['totalLikes'] ?? 0,
      isLikedByUser: json['isLikedByUser'] ?? false,
    );
  }
}

class LikeReelResponse {
  final String message;
  LikeReelResponse({required this.message});

  factory LikeReelResponse.fromJson(Map<String, dynamic> json) {
    return LikeReelResponse(message: json['message'] ?? '');
  }
}
