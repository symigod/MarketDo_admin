import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatefulWidget {
  static const String id = 'announcements-screen';
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ANNOUNCEMENTS',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                    onPressed: () {}, child: const Text('Add announcement'))
              ],
            ),
          ],
        ),
      );
}
