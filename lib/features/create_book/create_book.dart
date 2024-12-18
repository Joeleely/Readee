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

class CreateBookPage extends StatefulWidget {
  final int userId;
  const CreateBookPage({super.key, required this.userId});

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
  bool _isTitleEmpty = false;
  bool _isGenreEmpty = false;
  bool _isAuthorEmpty = false;

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Compress the image
      final compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 500, // Adjust as needed for smaller size
        minHeight: 500,
        quality: 25, // Adjust the quality level
      );

      // If the compression is successful, create a new XFile from the compressed bytes
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

  Future<void> _postBook({bool isMock = false}) async {
    setState(() {
      _isTitleEmpty = _titleController.text.isEmpty;
      _isAuthorEmpty = _authorController.text.isEmpty;
      _isGenreEmpty = _selectedGenre == null;
    });

    try {
      String? base64Image;
      // Convert the resized image file to Base64 string if an image is selected
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // Prepare the data for the POST request
      final Map<String, dynamic> bookData = {
        'OwnerId': widget.userId,
        'BookName': _titleController.text,
        'BookPicture': base64Image ?? '??',
        'Author': _authorController.text,
        'BookDescription': _descriptionController.text,
        'GenreId': _getGenreId(_selectedGenre!),
        'Quality': _quality.toInt(),
        'IsTraded': false,
      };

      //print(bookData);

      // Use mock response if the flag is true
      if (isMock) {
        print("Mock: Book created successfully");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadeeNavigationBar(
              userId: widget.userId,
              initialTab: 0,
            ),
          ),
        );
      } else {
        // Make the POST request
        final response = await http.post(
          Uri.parse('http://localhost:3000/createBook'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bookData),
        );

        if (response.statusCode == 201) {
          print("Book created successfully");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReadeeNavigationBar(
                      userId: widget.userId,
                      initialTab: 0,
                    )),
          );
        } else {
          print('Failed to create book: ${response.body}');
        }
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
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGenre = newValue;
                  _isGenreEmpty = false;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Genre is required';
                }
                return null;
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _postBook(isMock: false); // Call the function
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
