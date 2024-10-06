import 'dart:io';

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';

class CreateBookPage extends StatefulWidget {
  const CreateBookPage({super.key});

  @override
  _CreateBookPageState createState() => _CreateBookPageState();
}

class _CreateBookPageState extends State<CreateBookPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  double _quality = 95;
  int _descriptionLength = 0;
  XFile? _selectedImage;
  String? _selectedGenre;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _postBook() async {
    // Validate input
    if (_titleController.text.isEmpty || _selectedGenre == null) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    try {
      // Prepare the data for the POST request
      final Map<String, dynamic> bookData = {
        'OwnerId': 2,
        'BookName': _titleController.text,
        'BookPicture': _selectedImage != null ? _selectedImage!.path : '??',
        'BookDescription': _descriptionController.text,
        'GenreId': _getGenreId(_selectedGenre!),
        'Quality': _quality.toInt(),
        'IsTraded': false
      };

      print(bookData);

      // Make the POST request
      final response = await http.post(
        Uri.parse('http://localhost:3000/createBook'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bookData),
      );
      //print(response.statusCode);

      if (response.statusCode == 201) {
        print("Book created successfully");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookCard(),
          ),
        );
      } else {
        print('Failed to create book');
      }
    } catch (e) {
      print('Something went wrong: $e');
    }
  }

  int _getGenreId(String genre) {
    switch (genre) {
      case 'Sport':
        return 1;
      case 'Fiction':
        return 2;
      case 'Self-improve':
        return 3;
      case 'History':
        return 4;
      case 'Horror':
        return 5;
      case 'Love':
        return 6;
      case 'Psychology':
        return 7;
      case 'Fantasy':
        return 8;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to description controller to update the counter
    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create your book',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: const InputDecoration(
                labelText: 'Genre',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Sport', child: Text('Sport')),
                DropdownMenuItem(value: 'Fiction', child: Text('Fiction')),
                DropdownMenuItem(
                    value: 'Self-improve', child: Text('Self-improve')),
                DropdownMenuItem(value: 'History', child: Text('History')),
                DropdownMenuItem(value: 'Horror', child: Text('Horror')),
                DropdownMenuItem(value: 'Love', child: Text('Love')),
                DropdownMenuItem(
                    value: 'Psychology', child: Text('Psychology')),
                DropdownMenuItem(value: 'Fantasy', child: Text('Fantasy')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGenre = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quality'),
                Expanded(
                  child: Slider(
                    value: _quality,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: Colors.cyan[300],
                    inactiveColor: Colors.cyan[100],
                    label: _quality.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _quality = value;
                      });
                    },
                  ),
                ),
                Text('${_quality.toInt()}%'),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(256),
                  ],
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Text(
                    '${_descriptionLength}/256',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            // TextField(
            //   controller: _isbnController,
            //   decoration: const InputDecoration(
            //     labelText: 'ISBN 13',
            //     border: OutlineInputBorder(),
            //   ),
            //   keyboardType: TextInputType.number,
            //   inputFormatters: [
            //     LengthLimitingTextInputFormatter(13),
            //     FilteringTextInputFormatter.digitsOnly,
            //   ],
            // ),
            const SizedBox(height: 16),
            Row(
              children: [
                _selectedImage != null
                    ? Image.file(
                        File(_selectedImage!.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : GestureDetector(
                        onTap: _pickImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(20),
                          dashPattern: [6, 3],
                          color: Colors.cyan,
                          strokeWidth: 2,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: _selectedImage != null
                                ? Image.file(
                                    File(_selectedImage!.path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.cloud_upload,
                                    color: Colors.cyan),
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _postBook(); // Call the function
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.cyan),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
