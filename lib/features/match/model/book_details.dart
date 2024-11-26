class BookDetails {
  const BookDetails(
      {required this.bookId,
      required this.isTrade,
      required this.title,
      required this.author,
      required this.img,
      required this.genre,
      required this.quality,
      required this.description});
  final int bookId;
  final String title;
  final String author;
  final List<String> img;
  final String genre;
  final String quality;
  final String description;
  final bool isTrade;

  factory BookDetails.fromJson(Map<String, dynamic> json) {
    return BookDetails(
      bookId: json['BookId'] as int,
      title: json['BookName'] as String,
      author: json['Author'] as String,
      description: json['BookDescription'] as String,
      img: List<String>.from(
          json['BookPicture']), // If BookPicture is a list of strings
      quality: json['Quality'] as String,
      genre: json['Genre'] ?? 'Unknown', // Default to 'Unknown' if null
      isTrade: json['IsTraded'] as bool,
    );
  }
}
