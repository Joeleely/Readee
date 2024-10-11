class MatchDetails {
  final int ownerBookId;
  final int matchedBookId;

  MatchDetails({
    required this.ownerBookId,
    required this.matchedBookId,
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    return MatchDetails(
      ownerBookId: json['ownerBookId'] ?? 0,
      matchedBookId: json['matchedBookId'] ?? 0,
    );
  }
}
