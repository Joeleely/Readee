class Matches {
  final int ownerBookId;
  final int matchedBookId;

  Matches({
    required this.ownerBookId,
    required this.matchedBookId,
  });

  factory Matches.fromJson(Map<String, dynamic> json) {
    return Matches(
      ownerBookId: json['ownerBookId'] ?? 0,
      matchedBookId: json['matchedBookId'] ?? 0,
    );
  }
}