class Matches { //use in match_list
  final int ownerBookId;
  final int matchedBookId;
  final int matchId;
  final DateTime matchTime;

  Matches({
    required this.ownerBookId,
    required this.matchedBookId,
    required this.matchId,
    required this.matchTime,
  });

  factory Matches.fromJson(Map<String, dynamic> json) {

final matchTimeString = json['matchTime'];
  print('MatchTime String: $matchTimeString');

    if (json['matchTime'] == null || json['matchTime'].isEmpty) {
      throw ArgumentError('MatchTime cannot be null or empty');
    }

    return Matches(
      ownerBookId: json['ownerBookId'] ?? 0,
      matchedBookId: json['matchedBookId'] ?? 0,
      matchId: json['matchId'] ?? 0,
      //matchTime: json['matchTime'] != null ? DateTime.parse(json['matchTime']) : DateTime.now(),
      matchTime: DateTime.parse(matchTimeString)
    );
  }
}