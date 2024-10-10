import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';

class MatchListPage extends StatelessWidget {
  final List<Book> books = [
    Book(
        title: 'Atomic Habits',
        author: 'James Clear',
        img: 'assets/atomic-habit.jpg',
        description:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
    Book(
        title: 'จิตวิทยาสายดาร์ก',
        author: 'Dr.Hiro',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG',
        description:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
    Book(
        title: 'The Alchemist',
        author: 'Paulo Coelho',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG',
        description:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
    Book(
        title: 'All Things Are Too Small',
        author: 'Becca Rothfeld',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG',
        description:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
    Book(
        title: 'Think and Grow Rich',
        author: 'Napoleon Hill',
        img:
            'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG',
        description:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Match'),
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
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

class BookInfoPage extends StatefulWidget {
  final Book book;
  final String userName = 'JoeleelyMock';
  final int timesSwap = 2;
  final double rating = 4.9;

  BookInfoPage({required this.book});

  @override
  _BookInfoPageState createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  bool isExpanded = false;
  bool showToggle = false;

  @override
  void initState() {
    super.initState();
    // Using addPostFrameCallback to update showToggle after the build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDescriptionLength();
    });
  }

  void _checkDescriptionLength() {
    final span = TextSpan(
      text: widget.book.description,
      style: const TextStyle(color: Colors.grey),
    );
    final tp = TextPainter(
      text: span,
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width);

    if (tp.didExceedMaxLines) {
      setState(() {
        showToggle = true;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure to send request?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.green),
                    minimumSize: MaterialStatePropertyAll(Size(100, 50)),
                  ),
                  onPressed: () {}, // sent trade here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Image.network(widget.book.img),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                            'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.userName),
                        Row(
                          children: [
                            Text(
                              "${widget.timesSwap}",
                              style: const TextStyle(color: Colors.cyan),
                            ),
                            const Text(" Swapped"),
                            const SizedBox(width: 10),
                            Text(
                              "${widget.rating}",
                              style: const TextStyle(color: Colors.cyan),
                            ),
                            const Text(" Ratings"),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.sms)
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Author: ',
                      style: TextStyle(color: Colors.cyan),
                    ),
                    Text(widget.book.author),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(color: Colors.cyan),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      firstChild: Text(
                        widget.book.description,
                        maxLines: isExpanded ? null : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(widget.book.description),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    if (showToggle)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? "Show less" : "Show more...",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.cyan,
                ),
                child: const Text(
                  'Request to trade',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Book {
  final String title;
  final String author;
  final String img;
  final String description;

  Book({
    required this.title,
    required this.author,
    required this.img,
    required this.description,
  });
}
