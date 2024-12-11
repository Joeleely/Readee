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
  final String img; // เปลี่ยนจาก List<String> เป็น String
  final String genre; // Mapping `GenreId` เป็นชื่อ Genre
  final int quality; // เปลี่ยนจาก String เป็น int
  final String description;
  final bool isTrade;
  final bool isReport;
  
}
