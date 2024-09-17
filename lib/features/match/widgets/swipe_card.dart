import 'package:flutter/material.dart';
import 'package:readee_app/typography.dart';

class SwipeCard extends StatefulWidget {
  const SwipeCard({super.key});

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          'https://bci.kinokuniya.com/jsp/images/book-img/97813/97813985/9781398515697.JPG'))),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                'The Seven Husbands of Evelyn Hugo',
                                maxLines: 2,
                                style: TypographyText.h2(Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Text(
                                    '95%',
                                    style: TypographyText.h4(Colors.white),
                                  )),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.info_rounded,
                              color: Colors.white,
                            ))
                      ],
                    ),
                    Text(
                      'Taylor',
                      style: TypographyText.b4(Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'description this is mock to check love you the seven husbands of evelyn hugo',
                      style: TypographyText.b3(Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.white),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 50),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.white),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
