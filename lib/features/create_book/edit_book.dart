import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/widget/bottomNav.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditBookPage extends StatefulWidget {
  final int bookId;

  const EditBookPage({super.key, required this.bookId});

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
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
  bool _isTitleEmpty = false;
  bool _isGenreEmpty = false;
  bool _isAuthorEmpty = false;

  @override
  void initState() {
    super.initState();
    // Fetch the book data when the page is initialized
    _fetchBookData();
    // Listen to description controller to update the counter
    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
      });
    });
  }

  Future<void> _fetchBookData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getBook/${widget.bookId}'),
      );

      if (response.statusCode == 200) {
        final bookData = jsonDecode(response.body);

        // Pre-fill the form fields with fetched data
        _titleController.text = bookData['BookName'];
        _authorController.text = bookData['Author'];
        _descriptionController.text = bookData['BookDescription'];
        _selectedGenre = _getGenreName(bookData['GenreId']);
        _quality = bookData['Quality'].toDouble();

        // Optionally, load the existing image if needed
        if (bookData['BookPicture'] != null) {
          // Handle loading the existing book picture if applicable
          // e.g. Convert Base64 string to image and show it
        }

        setState(() {}); // Update the UI after loading data
      } else {
        print('Failed to fetch book data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching book data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Compress the image
      final compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 500,
        minHeight: 500,
        quality: 25,
      );

      if (compressedImage != null) {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/temp_image.jpg')
          ..writeAsBytesSync(compressedImage);
        final imageTemp = XFile(tempFile.path);

        setState(() => _selectedImage = imageTemp);
      } else {
        print('Image compression failed');
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> _saveBook() async {
    setState(() {
      _isTitleEmpty = _titleController.text.isEmpty;
      _isAuthorEmpty = _authorController.text.isEmpty;
      _isGenreEmpty = _selectedGenre == null;
    });

    if (_isTitleEmpty || _isAuthorEmpty || _isGenreEmpty) {
      print('Error: Please fill all required fields');
      return;
    }

    try {
      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final Map<String, dynamic> bookData = {
        'BookName': _titleController.text,
        'BookPicture': base64Image ?? '??',
        'Author': _authorController.text,
        'BookDescription': _descriptionController.text,
        'GenreId': _getGenreId(_selectedGenre!),
        'Quality': _quality.toInt(),
      };

      // Make the PUT request to update the book
      final response = await http.patch(
        Uri.parse('http://localhost:3000/editBook/${widget.bookId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bookData),
      );

      if (response.statusCode == 200) {
        print("Book updated successfully");
        Navigator.pop(context, true);
      } else {
        print('Failed to update book: ${response.body}');
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

  String _getGenreName(int genreId) {
    switch (genreId) {
      case 1:
        return 'Sport';
      case 2:
        return 'Fiction';
      case 3:
        return 'Self-improve';
      case 4:
        return 'History';
      case 5:
        return 'Horror';
      case 6:
        return 'Love';
      case 7:
        return 'Psychology';
      case 8:
        return 'Fantasy';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit your book',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isTitleEmpty ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isTitleEmpty ? Colors.red : Colors.cyan,
                  ),
                ),
                errorText: _isTitleEmpty ? 'Title is required' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isAuthorEmpty ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isAuthorEmpty ? Colors.red : Colors.cyan,
                  ),
                ),
                errorText: _isAuthorEmpty ? 'Author is required' : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: InputDecoration(
                labelText: 'Genre',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isGenreEmpty ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isGenreEmpty ? Colors.red : Colors.cyan,
                  ),
                ),
                errorText: _isGenreEmpty ? 'Genre is required' : null,
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
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value;
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveBook,
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Colors.cyan,
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => {Navigator.pop(context)},
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
