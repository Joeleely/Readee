import 'dart:math';

import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchPage extends StatefulWidget {
  final int userID;
  const MatchPage({super.key, required this.userID});

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<BookDetails> books = [];
  final Random random = Random();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      // Step 1: Get user genres
      final genreResponse = await http
          .get(Uri.parse('http://localhost:3000/userGenres?userID=$widget.userID'));
      if (genreResponse.statusCode == 200) {
        List<dynamic> genresData = jsonDecode(genreResponse.body);

        List<int> userGenreIDs =
            genresData.map((genre) => genre['Genre_genre_id'] as int).toList();
        // print("this is user GenreIDs");
        // print(userGenreIDs);

        // Step 2: Get user logs to filter out liked books
        final logsResponse =
            await http.get(Uri.parse('http://localhost:3000/getLogs/${widget.userID}'));
        List<int> likedBookIDs = [];
        if (logsResponse.statusCode == 200) {
          List<dynamic> logsData = jsonDecode(logsResponse.body);
          likedBookIDs =
              logsData.map((log) => log['BookLikeId'] as int).toList();
          //print("This is likedBookIDs");
          //print(likedBookIDs);
        }

        // Step 3: Get books
        final bookResponse =
            await http.get(Uri.parse('http://localhost:3000/getBooks'));
        if (bookResponse.statusCode == 200) {
          List<dynamic> booksData = jsonDecode(bookResponse.body);

          List<BookDetails> matchingBooks = booksData.where((book) {
            return userGenreIDs.contains(book['GenreId']) &&
                book['OwnerId'] != widget.userID &&
                book['IsTraded'] == false &&
                !likedBookIDs.contains(book['BookId']);
          }).map((book) {
            //print("bookOwnerId: ${book['OwnerId']}, userId: ${widget.userID}");
            return BookDetails(
              title: book['BookName'],
              author: book['Author'],
              description: book['BookDescription'],
              img: [book['BookPicture']],
              quality: '${book['Quality']}%',
              genre: '',
              bookId: book['BookId'],
              isTrade: book['IsTraded']
            );
          }).toList();

          List<BookDetails> nonMatchingBooks = booksData.where((book) {
            return !userGenreIDs.contains(book['GenreId']) &&
                book['OwnerId'] != widget.userID &&
                book['IsTraded'] == false &&
                !likedBookIDs.contains(book['BookId']);
          }).map((book) {
            return BookDetails(
              title: book['BookName'],
              author: book['Author'],
              description: book['BookDescription'],
              img: [book['BookPicture']],
              quality: '${book['Quality']}%',
              genre: '',
              bookId: book['BookId'],
              isTrade: book['IsTraded']
            );
          }).toList();

          // Step 4: Randomly select 70% matching and 30% non-matching books
          int matchingBooksCount = (booksData.length * 0.7).toInt();
          int nonMatchingBooksCount = booksData.length - matchingBooksCount;

          List<BookDetails> selectedMatchingBooks =
              _getRandomBooks(matchingBooks, matchingBooksCount);
          List<BookDetails> selectedNonMatchingBooks =
              _getRandomBooks(nonMatchingBooks, nonMatchingBooksCount);

          // Step 5: Combine the selected books
          List<BookDetails> combinedBooks = [
            ...selectedMatchingBooks,
            ...selectedNonMatchingBooks
          ];

          // Step 6: Shuffle the combined list to randomize the order
          combinedBooks.shuffle(random);

           if (mounted) {
          setState(() {
            books = combinedBooks;
            isLoading = false;
          });
        }
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

  List<BookDetails> _getRandomBooks(List<BookDetails> booksList, int count) {
    if (booksList.length <= count) {
      return booksList;
    }
    booksList.shuffle(random);
    return booksList.sublist(0, count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/logo.png'),
          height: 50,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      body: Center(
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text("No more book to show, wait for other to post the book"))
              : BookCard(books: books, userID: widget.userID,)
      ),
    );
  }
}
