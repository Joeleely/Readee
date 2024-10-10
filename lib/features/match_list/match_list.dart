import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';

class MatchListPage extends StatelessWidget {
  final List<Book> books = [
    Book(
        title: 'Atomic Habits',
        author: 'James Clear',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG'),
    Book(
        title: 'จิตวิทยาสายดาร์ก',
        author: 'Dr.Hiro',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG'),
    Book(
        title: 'The Alchemist',
        author: 'Paulo Coelho',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG'),
    Book(
        title: 'All Things Are Too Small',
        author: 'Becca Rothfeld',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG'),
    Book(
        title: 'Think and Grow Rich',
        author: 'Napoleon Hill',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    // Navigate to the book info page when clicked
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BookInfoPage(book: book),
                    ));
                  },
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                            image: NetworkImage(book.img), fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(book.title),
                    subtitle: Text(book.author),
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BookInfoPage(book: book),
                    ));
                    }, // Navigate to partner book
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                  image: NetworkImage(book.img),
                                  fit: BoxFit.cover)),
                        ),
                        title: Text(book.title),
                        subtitle: Text(book.author),
                      ),
                    )),
                    const Divider()
              ],
            );
          },
        ),
      ),
    );
  }
}

class BookInfoPage extends StatelessWidget {
  final Book book;

  BookInfoPage({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(book.img),
            const SizedBox(height: 16),
            Text(
              book.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Author: ${book.author}'),
            const SizedBox(height: 16),
            const Text('Description: Lorem ipsum...'), // Add book description here
          ],
        ),
      ),
    );
  }
}

// Book model
class Book {
  final String title;
  final String author;
  final String img;

  Book({required this.title, required this.author, required this.img});
}
