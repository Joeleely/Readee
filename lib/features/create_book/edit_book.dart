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
  Uint8List? _existingImage;
  String? _existingImageUrl;

  final ImagePicker _picker = ImagePicker();
  bool _isTitleEmpty = false;
  bool _isGenreEmpty = false;
  bool _isAuthorEmpty = false;

  @override
  void initState() {
    super.initState();
    _fetchBookData();
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
        _quality = bookData['Quality'];

        // Optionally, load the existing image if needed
        if (bookData['BookPicture'] != null) {
          // If it's a URL, assign it to the variable
          if (bookData['BookPicture'].startsWith('http')) {
            _existingImageUrl = bookData['BookPicture'];
            _existingImage = null; // Clear any existing byte data
          } else {
            // Otherwise, assume it's base64 encoded
            _existingImage = base64Decode(bookData['BookPicture']);
            _existingImageUrl = null; // Clear any existing URL
          }
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

        setState(() {
          _selectedImage = imageTemp;
          _existingImage =
              null; // Clear existing image when a new one is picked
        });
      } else {
        print('Image compression failed');
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<String?> _fetchNetworkImageAsBase64(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    } else {
      print('Failed to fetch image: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching network image: $e');
    return null;
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

      // If a new image is selected, convert it to base64
      if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    } else if (_existingImage != null) {
      // Use the existing local image if no new image is selected
      base64Image = base64Encode(_existingImage!);
    } else if (_existingImageUrl != null) {
      // If no new image is selected and there's no existing local image, use the existing image URL
      base64Image = await _fetchNetworkImageAsBase64(_existingImageUrl!);
    } else {
      // Fallback if no image is available
      base64Image = null; // or assign a default image if needed
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
                GestureDetector(
                  onTap: _pickImage, // Allow image to be changed on tap
                  child: _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : _existingImageUrl != null // Check for URL first
                          ? Image.network(
                              _existingImageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey,
                                  child: const Icon(Icons.error),
                                );
                              },
                            )
                          : _existingImage != null
                              ? Image.memory(
                                  _existingImage!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : DottedBorder(
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
                                    child: const Icon(Icons.cloud_upload,
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
