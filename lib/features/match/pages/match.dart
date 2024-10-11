import 'dart:math';

import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<Book> books = [];
  final int userID = 1; // Set your userID here
   final Random random = Random();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      // Step 1: Get user genres
      final genreResponse = await http
          .get(Uri.parse('http://localhost:3000/userGenres?userID=$userID'));
      if (genreResponse.statusCode == 200) {
        List<dynamic> genresData = jsonDecode(genreResponse.body);

        List<int> userGenreIDs =
            genresData.map((genre) => genre['Genre_genre_id'] as int).toList();
        // print("this is user GenreIDs");
        // print(userGenreIDs);

        // Step 2: Get user logs to filter out liked books
        final logsResponse =
            await http.get(Uri.parse('http://localhost:3000/getLogs/$userID'));
        List<int> likedBookIDs = [];
        if (logsResponse.statusCode == 200) {
          List<dynamic> logsData = jsonDecode(logsResponse.body);
          likedBookIDs =
              logsData.map((log) => log['BookLikeId'] as int).toList();
          print("This is likedBookIDs");
          print(likedBookIDs);
        }

        // Step 3: Get books
        final bookResponse =
            await http.get(Uri.parse('http://localhost:3000/getBooks'));
        if (bookResponse.statusCode == 200) {
          List<dynamic> booksData = jsonDecode(bookResponse.body);

          List<Book> matchingBooks = booksData.where((book) {
            return userGenreIDs.contains(book['GenreId']) &&
                book['OwnerId'] != userID &&
                book['IsTraded'] == false &&
                !likedBookIDs.contains(book['BookId']);
          }).map((book) {
            return Book(
              title: book['BookName'],
              author: book['Author'],
              description: book['BookDescription'],
              img: [book['BookPicture']],
              quality: '${book['Quality']}%',
              genreID: book['GenreId'], BookId: book['BookId'],
            );
          }).toList();

          List<Book> nonMatchingBooks = booksData.where((book) {
            return !userGenreIDs.contains(book['GenreId']) &&
                book['OwnerId'] != userID &&
                book['IsTraded'] == false &&
                !likedBookIDs.contains(book['BookId']);
          }).map((book) {
            return Book(
              title: book['BookName'],
              author: book['Author'],
              description: book['BookDescription'],
              img: [book['BookPicture']],
              quality: '${book['Quality']}%',
              genreID: book['GenreId'], BookId: book['BookId'],
            );
          }).toList();

          // Step 4: Randomly select 70% matching and 30% non-matching books
          int matchingBooksCount = (booksData.length * 0.7).toInt();
          int nonMatchingBooksCount = booksData.length - matchingBooksCount;

          List<Book> selectedMatchingBooks =
              _getRandomBooks(matchingBooks, matchingBooksCount);
          List<Book> selectedNonMatchingBooks =
              _getRandomBooks(nonMatchingBooks, nonMatchingBooksCount);

          // Step 5: Combine the selected books
          List<Book> combinedBooks = [
            ...selectedMatchingBooks,
            ...selectedNonMatchingBooks
          ];

          // Step 6: Shuffle the combined list to randomize the order
          combinedBooks.shuffle(random);

          setState(() {
            books = combinedBooks;
          });
          //print(books);

          // print("this is book that get from filter");
          // print(filteredBooks);
        } else {
          throw Exception('Failed to load books');
        }
      } else {
        throw Exception('Failed to load user genres');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  List<Book> _getRandomBooks(List<Book> booksList, int count) {
    if (booksList.length <= count) {
      return booksList;
    }
    booksList.shuffle(random);
    return booksList.sublist(0, count);
  }

  @override
  Widget build(BuildContext context) {
    // Sample book data
    // List<Book> books = const [
    //   Book(
    //     title: 'The Seven Husbands of Evelyn Hugo',
    //     author: 'Taylor Jenkins Reid',
    //     description: 'A book about all the lives you could have lived.',
    //     img: ['https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGG0NQOwrLEgU67POJ7SZvy2TPC91PsnBfxw&s', 'https://down-th.img.susercontent.com/file/sg-11134201-23010-1qmyzsxyshmv73'],
    //     quality: '95%', genre: '',
    //   ),
    //   Book(
    //     title: 'Atomic Habits',
    //     author: 'James Clear',
    //     description: 'An easy and proven way to build good habits and break bad ones.',
    //     img: ['https://m.media-amazon.com/images/I/51-uspgqWIL.jpg' ],
    //     quality: '80%', genre: '',
    //   ),
    //   Book(
    //     title: 'November 9',
    //     author: 'Colleen Hoover',
    //     description: 'Fallon meets Ben, an aspiring novelist, the day before her scheduled cross-country move. Their untimely attraction leads them to spend Fallon’s last day in L.A. together, and her eventful life becomes the creative inspiration Ben has always sought for his novel.',
    //     img: ['https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1447138036i/25111004.jpg'],
    //     quality: '80%', genre: '',
    //   ),
    //   Book(
    //     title: 'Daisy Jones & The Six',
    //     author: 'Taylor Jenkins Reid',
    //     description: 'Daisy is a girl coming of age in L.A. in the late sixties, sneaking into clubs on the Sunset Strip, sleeping with rock stars, and dreaming of singing at the Whisky a Go Go. The sex and drugs are thrilling, but it’s the rock ’n’ roll she loves most.',
    //     img: ['https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1580255154i/40597810.jpg'],
    //     quality: '70%', genre: '',
    //   ),
    //   // Add more book entries here
    // ];

    return Scaffold(
      appBar: AppBar(
    leading: IconButton(
      onPressed: () {},
      icon: const Icon(Icons.notifications),
    ),
    backgroundColor: const Color.fromARGB(255, 243, 252, 255),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 16.0),
        child: Image(
          image: AssetImage('assets/logo.png'),
          height: 50,
        ),
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 16.0),
        //     child: Image(
        //       image: AssetImage('assets/logo.png'),
        //       height: 40,
        //     ),
        ),
        ],
      ),
      body: Center(
        child: books.isNotEmpty 
          ? BookCard(books: books, userID: 2,)
          : const CircularProgressIndicator(), // Show loading indicator while data is fetched
      ),
    );
  }
}
