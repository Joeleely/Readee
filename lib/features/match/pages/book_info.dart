import 'dart:typed_data'; // Import for Uint8List
import 'dart:convert'; // Import for base64Decode
import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/typography.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({super.key, required this.book});
  final BookDetails book;

  @override
  _BookInfoPageState createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  int _currentImageIndex = 0;

  // Method to convert Base64 string to Uint8List
  Uint8List _convertBase64Image(String base64String) {
    return base64Decode(base64String);
  }

  void _nextImage() {
    setState(() {
      // Cycle through the images
      _currentImageIndex = (_currentImageIndex + 1) % widget.book.img.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    widget.book.title,
                    maxLines: 2,
                    style: TypographyText.h2(Colors.black),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.book.author,
                  style: TypographyText.b3(Colors.grey),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_circle_down_outlined),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _nextImage, // Change image on tap
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.book.img[_currentImageIndex].startsWith('http')
                            ? NetworkImage(widget.book.img[_currentImageIndex]) // Network image
                            : MemoryImage(_convertBase64Image(widget.book.img[_currentImageIndex])) as ImageProvider<Object>, // Base64 image
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TypographyText.h3(Colors.blueAccent),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.book.description,
                        style: TypographyText.b3(Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
