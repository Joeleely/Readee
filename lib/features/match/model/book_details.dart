class BookDetails {
  const BookDetails(
    {required this.isReport, 
      required this.bookId,
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
  final bool isReport;
  
}
