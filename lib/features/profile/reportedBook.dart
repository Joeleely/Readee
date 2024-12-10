import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportedBookPage extends StatefulWidget {
  final int userId;

  const ReportedBookPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ReportedBookPageState createState() => _ReportedBookPageState();
}

class _ReportedBookPageState extends State<ReportedBookPage> {
  List<dynamic> reportedBooks = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchReportedBooks();
  }

  Future<void> fetchReportedBooks() async {
    final url = 'http://localhost:3000/reportedBooks/${widget.userId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          reportedBooks = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load reported books");
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  ImageProvider<Object> _getImage(String img) {
    if (img.startsWith('http')) {
      return NetworkImage(img);
    } else {
      return MemoryImage(_convertBase64Image(img)) as ImageProvider<Object>;
    }
  }

  Uint8List _convertBase64Image(String base64String) {
    return base64.decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Books'),
        backgroundColor: const Color.fromARGB(255, 228, 248, 255),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Text(
                    'Failed to load reported books',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                )
              : reportedBooks.isEmpty
                  ? const Center(
                      child: Text(
                        'You have no reported books yet',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reportedBooks.length,
                      itemBuilder: (context, index) {
                        final book = reportedBooks[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            leading: book['BookPicture'] != null
                                ? Image(
                                    image: _getImage(book['BookPicture']),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.book, size: 50),
                            title: Text(book['BookName'] ?? 'Unnamed Book'),
                            subtitle: Text(
                                'Author: ${book['Author'] ?? 'Unknown'}'),
                          ),
                        );
                      },
                    ),
    );
  }
}
