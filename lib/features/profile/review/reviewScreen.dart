import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

//หุ้มด้วย listtile 
class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row แรก - โปรไฟล์และรีวิว
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // รูปโปรไฟล์
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024'), // ใส่รูปโปรไฟล์ของผู้ใช้
                ),
                const SizedBox(width: 10),
                // ชื่อผู้ใช้ และรีวิว
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marshmallow',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'คุยง่าย ไม่โถง',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 25),

            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    Icon(Icons.star, color: Colors.yellow),
                    Icon(Icons.star, color: Colors.yellow),
                    Icon(Icons.star, color: Colors.yellow),
                    Icon(Icons.star, color: Colors.yellow),
                  ],
                ),
              ],
            ),),
             
            const SizedBox(width: 50),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  'https://images-se-ed.com/ws/Storage/Originals/978616/825/9786168254271L.jpg?h=db378bd6c6401f8fe0613e422ec90309', // ใส่รูปปกหนังสือ
                  width: 50,
                  height: 70,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Joe',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
