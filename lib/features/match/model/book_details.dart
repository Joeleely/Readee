class Book {
  const Book(
      { required this.BookId,
        required this.title,
      required this.author,
      required this.img,
      required this.genreID,
      required this.quality,
      required this.description});
      final int BookId;
  final String title;
  final String author;
  final List<String> img;
  final int genreID;
  final String quality;
  final String description;
}
