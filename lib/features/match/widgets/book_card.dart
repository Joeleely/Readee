import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';
import 'package:readee_app/typography.dart';
import 'package:swipe_cards/swipe_cards.dart';

class BookCard extends StatefulWidget {
  const BookCard({super.key, required this.books});
  final List<Book> books;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Initialize SwipeItems with Book details
    for (var book in widget.books) {
      _swipeItems.add(SwipeItem(
        content: book,
        likeAction: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Liked ${book.title}"),
            duration: const Duration(milliseconds: 500),
          ));
        },
        nopeAction: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Nope ${book.title}"),
            duration: const Duration(milliseconds: 500),
          ));
        },
      ));
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SwipeCards(
              matchEngine: _matchEngine!,
              itemBuilder: (BuildContext context, int index) {
                Book book = _swipeItems[index].content;
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          // width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(book.img)),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: Text(
                                            book.title,
                                            style:
                                                TypographyText.h2(Colors.white),
                                            maxLines: 2,
                                          ),
                                        ),
                                        Text(
                                          book.author,
                                          style:
                                              TypographyText.b4(Colors.white),
                                        ),
                                        // const SizedBox(
                                        //   width: 10,
                                        // ),
                                        // Padding(
                                        //   padding:
                                        //       const EdgeInsets.only(top: 6),
                                        //   child: Container(
                                        //       padding:
                                        //           const EdgeInsets.symmetric(
                                        //         horizontal: 8,
                                        //       ),
                                        //       decoration: BoxDecoration(
                                        //           color: Colors.white
                                        //               .withOpacity(0.6),
                                        //           borderRadius:
                                        //               const BorderRadius.all(
                                        //                   Radius.circular(
                                        //                       10))),
                                        //       child: Text(
                                        //         book.quality,
                                        //         style: TypographyText.h4(
                                        //             Colors.white),
                                        //       )),
                                        // ),
                                      ],
                                    ),
                                    IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(_createRoute(book));
                                        },
                                        icon: const Icon(
                                          Icons.info_rounded,
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  book.description,
                                  style: TypographyText.b3(
                                      Colors.white.withOpacity(0.8)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _matchEngine!.currentItem?.nope();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(15),
                                        backgroundColor: Colors.white,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.red, size: 40),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _matchEngine!.currentItem?.like();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(15),
                                        backgroundColor: Colors.white,
                                      ),
                                      child: Icon(Icons.favorite,
                                          color: Colors.greenAccent[400],
                                          size: 40),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onStackFinished: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Stack Finished"),
                  duration: Duration(milliseconds: 500),
                ));
              },
              itemChanged: (SwipeItem item, int index) {
                print("Book: ${item.content.title}, index: $index");
              },
              leftSwipeAllowed: true,
              rightSwipeAllowed: true,
              upSwipeAllowed: false,
              fillSpace: true,
            ),
          ),
        ],
      ),
    );
  }
}

Route _createRoute(Book book) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        BookInfoPage(book: book),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
