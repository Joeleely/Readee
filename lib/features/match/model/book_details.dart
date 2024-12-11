class BookDetails {
  const BookDetails({
    required this.bookId,
    required this.isTrade,
    required this.title,
    required this.author,
    required this.img,
    required this.genre,
    required this.quality,
    required this.description,
  });

  final int bookId;
  final String title;
  final String author;
  final String img; // เปลี่ยนจาก List<String> เป็น String
  final String genre; // Mapping `GenreId` เป็นชื่อ Genre
  final int quality; // เปลี่ยนจาก String เป็น int
  final String description;
  final bool isTrade;

  // Static method for mapping GenreId to Genre name
  static String mapGenre(int genreId) {
    const genreMapping = {
      5: 'Fiction',
      8: 'Horror',
      // เพิ่ม Genre อื่นๆ ที่เกี่ยวข้อง
    };
    return genreMapping[genreId] ?? 'Unknown'; // Default เป็น Unknown
  }

  factory BookDetails.fromJson(Map<String, dynamic> json) {
    return BookDetails(
      bookId: json['BookId'] as int,
      title: json['BookName'] as String,
      author: json['Author'] as String,
      description: json['BookDescription'] as String,
      img: json['BookPicture'] as String, // รับ `String` จาก JSON
      quality: json['Quality'] as int, // ใช้เป็น int
      genre: mapGenre(json['GenreId'] ?? 0), // Mapping Genre
      isTrade: json['IsTraded'] as bool,
    );
  }
}
