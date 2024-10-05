import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/widget/bottomNav.dart';

class MatchPage extends StatelessWidget {
  const MatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample book data
    List<Book> books = const [
      Book(
        title: 'The Seven Husbands of Evelyn Hugo',
        author: 'Taylor Jenkins Reid',
        description: 'A book about all the lives you could have lived.',
        img: ['https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGG0NQOwrLEgU67POJ7SZvy2TPC91PsnBfxw&s', 'https://down-th.img.susercontent.com/file/sg-11134201-23010-1qmyzsxyshmv73'],
        quality: '95%', genre: '',
      ),
      Book(
        title: 'Atomic Habits',
        author: 'James Clear',
        description: 'An easy and proven way to build good habits and break bad ones.',
        img: ['https://m.media-amazon.com/images/I/51-uspgqWIL.jpg' ],
        quality: '80%', genre: '',
      ),
      Book(
        title: 'November 9',
        author: 'Colleen Hoover',
        description: 'Fallon meets Ben, an aspiring novelist, the day before her scheduled cross-country move. Their untimely attraction leads them to spend Fallon’s last day in L.A. together, and her eventful life becomes the creative inspiration Ben has always sought for his novel.',
        img: ['https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1447138036i/25111004.jpg'],
        quality: '80%', genre: '',
      ),
      Book(
        title: 'Daisy Jones & The Six',
        author: 'Taylor Jenkins Reid',
        description: 'Daisy is a girl coming of age in L.A. in the late sixties, sneaking into clubs on the Sunset Strip, sleeping with rock stars, and dreaming of singing at the Whisky a Go Go. The sex and drugs are thrilling, but it’s the rock ’n’ roll she loves most.',
        img: ['https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1580255154i/40597810.jpg'],
        quality: '70%', genre: '',
      ),
      // Add more book entries here
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
      ),
      body: Center(
        child: BookCard(books: books),  // Pass the list of books here
      ),
      
    );
  }
}
