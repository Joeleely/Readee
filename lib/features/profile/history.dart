import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRU3BLi1Tkm6IWiYqcugjdwY9wbCnyRK58U9A&s')),
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          width: 80,
                          child: const Text(
                            'Test long text for book 1',
                            overflow: TextOverflow.ellipsis,
                          )),
                      const Icon(Icons.swap_horiz),
                      Container(
                          alignment: Alignment.center,
                          width: 80,
                          child: const Text('Test long text for book 2',
                              overflow: TextOverflow.ellipsis)),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  'https://photos-us.bazaarvoice.com/photo/2/cGhvdG86aW5kaWdvLWNh/0fbb5eb4-82fa-5244-b56b-1e17edf42758')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
