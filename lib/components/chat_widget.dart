// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatsData extends StatelessWidget {
  final String title;
  final String subtitle;
  final Image imagePath;
  final int messageCount;
  final Function() onTap;
  final String time;

  const ChatsData({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.messageCount,
    required this.onTap,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[200],
        backgroundImage: imagePath.image,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(time.toString()),
          if (messageCount > 0)
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(messageCount.toString()),
            )
        ],
      ),
    );
  }
}
