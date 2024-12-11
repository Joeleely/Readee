import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/match_list/bookDetail.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';

class MyBooksPage extends StatefulWidget {
  final int userId;

  const MyBooksPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse(
          'https://readee-api.stthi.com/getBookByUser/${widget.userId}'));
      if (response.statusCode == 200) {
        final List<dynamic> bookJson = json.decode(response.body);
        setState(() {
          books = bookJson
              .map((json) => Book.fromJson(json))
              .where((book) => book.isTraded == false)
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching books: $error');
    }
  }

  Uint8List _convertBase64Image(String base64String) {
    String base64Data = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(base64Data);
  }

  void _showConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.red),
                    minimumSize: MaterialStatePropertyAll(Size(100, 50)),
                  ),
                  onPressed: () {
                    // Call delete method if confirmed
                    _deleteBook(index);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.grey),
                    minimumSize: MaterialStatePropertyAll(Size(100, 50)),
                  ),
                  child:
                      const Text('No', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(int index) async {
    int bookId = books[index].bookId;
    String bookName = books[index].bookName;
    try {
      final response = await http.delete(
        Uri.parse('https://readee-api.stthi.com/deleteBook/$bookId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          books.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$bookName deleted')),
        );
      } else {
        throw Exception('Failed to delete book: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting book: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete ${books[index].bookName}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: const Text('My Book'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text("You have no book match right now"))
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      ImageProvider<Object> imageProvider;
                      if (books[index].bookPicture.startsWith('http')) {
                        imageProvider = NetworkImage(books[index].bookPicture);
                      } else {
                        imageProvider = MemoryImage(
                            _convertBase64Image(books[index].bookPicture));
                      }

                      return // The onDismissed will not remove the item immediately, just show the dialog.
                          Dismissible(
                        key: Key((books[index].bookId).toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          // Show the confirmation dialog and wait for the response
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                    'Are you sure you want to delete this book?'),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.red),
                                          minimumSize: MaterialStatePropertyAll(
                                              Size(100, 50)),
                                        ),
                                        onPressed: () {
                                          // Return true to confirm the dismissal and delete the book
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text(
                                          'Yes',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      TextButton(
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.grey),
                                          minimumSize: MaterialStatePropertyAll(
                                              Size(100, 50)),
                                        ),
                                        onPressed: () {
                                          // Return false to cancel the dismissal
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('No',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          // If confirmed, delete the book
                          _deleteBook(index);
                        },
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CustomPageRoute(
                                    page: BookDetailPage(
                                  userId: widget.userId,
                                  bookId: books[index].bookId,
                                  matchId: 0,
                                  isEdit: true,
                                )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: books[index].isReported
                                          ? Colors.red
                                          : Colors.cyan,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      width: 55,
                                      height: 100,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (books[index].isReported)
                                          const Icon(
                                            Icons.report_problem,
                                            color: Colors
                                                .red, // Red color for the icon
                                            size:
                                                20, // Adjust the size as needed
                                          ),
                                        const SizedBox(width: 5),
                                        Text(
                                          books[index].bookName,
                                          style: TextStyle(
                                            color: books[index].isReported
                                                ? Colors.red
                                                : Colors
                                                    .black, // Red if reported
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      books[index].authorName,
                                      style: TextStyle(
                                        color: books[index].isReported
                                            ? Colors.red
                                            : Colors.grey, // Red if reported
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class Book {
  final String bookName;
  final String bookPicture;
  final String authorName;
  final int bookId;
  final bool isTraded;
  final bool isReported;

  Book(
      {required this.isReported,
      required this.bookName,
      required this.bookId,
      required this.bookPicture,
      required this.authorName,
      required this.isTraded});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        bookName: json['BookName'],
        bookId: json['BookId'],
        bookPicture: json['BookPicture'],
        authorName: json['Author'],
        isTraded: json['IsTraded'],
        isReported: json['IsReported']);
  }
}

// class BookMock {
//   final String title;
//   final String author;
//   final String img;
//   final String description;

//   BookMock({
//     required this.title,
//     required this.author,
//     required this.img,
//     required this.description,
//   });
// }

