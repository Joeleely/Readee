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

final matchTimeString = json['MatchTime'];
  //print('MatchTime String: $matchTimeString');

    if (json['MatchTime'] == null || json['MatchTime'].isEmpty) {
      throw ArgumentError('MatchTime cannot be null or empty');
    }

    return Matches(
      ownerBookId: json['OwnerBookId'] ?? 0,
      matchedBookId: json['MatchedBookId'] ?? 0,
      matchId: json['MatchId'] ?? 0,
      //matchTime: json['matchTime'] != null ? DateTime.parse(json['matchTime']) : DateTime.now(),
      matchTime: DateTime.parse(matchTimeString)
    );
  }
}