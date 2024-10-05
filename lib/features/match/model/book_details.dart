class Book {
  const Book(
      {required this.title,
      required this.author,
      required this.img,
      required this.genre,
      required this.quality,
      required this.description});
  final String title;
  final String author;
  final List<String> img;
  final String genre;
  final String quality;
  final String description;
}
