import 'package:flutter/material.dart';
import 'package:readee_app/typography.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({super.key});

  @override
  State<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        // backgroundColor: Colors.blueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'The Seven Husbands of Evelyn Hugo',
                    maxLines: 2,
                    style: TypographyText.h2(Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Taylor Jenkins Reid',
                  style: TypographyText.b4(Colors.grey),
                )
              ],
            ),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_circle_down_outlined)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG'))),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TypographyText.h3(Colors.blueAccent),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Aging and reclusive Hollywood movie icon Evelyn Hugo is finally ready to tell the truth about her glamorous and scandalous life. But when she chooses unknown magazine reporter Monique Grant for the job, no one is more astounded than Monique herself. Why her? Why now? Monique is not exactly on top of the world. Her husband has left her, and her professional life is going nowhere. Regardless of why Evelyn has selected her to write her biography, Monique is determined to use this opportunity to jumpstart her career.Summoned to Evelyns luxurious apartment, Monique listens in fascination as the actress tells her story. From making her way to Los Angeles in the 1950s to her decision to leave show business in the 80s, and, of course, the seven husbands along the way, Evelyn unspools a tale of ruthless ambition, unexpected friendship, and a great forbidden love. Monique begins to feel a very real connection to the legendary star, but as Evelyns story nears its conclusion, it becomes clear that her life intersects with Moniques own in tragic and irreversible ways',
                      style: TypographyText.b2(Colors.black),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
