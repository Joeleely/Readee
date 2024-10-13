class Matches {
  final int ownerBookId;
  final int matchedBookId;
  final int matchId;

  Matches({
    required this.ownerBookId,
    required this.matchedBookId,
    required this.matchId,
  });

  factory Matches.fromJson(Map<String, dynamic> json) {
    return Matches(
      ownerBookId: json['ownerBookId'] ?? 0,
      matchedBookId: json['matchedBookId'] ?? 0,
      matchId: json['matchId'] ?? 0
    );
  }
}