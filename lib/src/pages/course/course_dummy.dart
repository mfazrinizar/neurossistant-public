// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CoursePage(),
    );
  }
}

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  // void test() async {
  //   final test = FirebaseFirestore.instance
  //       .collection('users')
  //       .where('userType', isEqualTo: 'Psychologist')
  //       .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //       .snapshots();
  //   print(test.toString());
  // }

  // void initState() {
  //   test();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choice your course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (bool selected) {},
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Popular'),
                  selected: false,
                  onSelected: (bool selected) {},
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('New'),
                  selected: false,
                  onSelected: (bool selected) {},
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  courseCard(
                      'What is Dyslexia', 'Robertson Connie', '16 hours'),
                  courseCard('Parenting for Dyslexic children', 'Nguyen Shane',
                      '16 hours'),
                  courseCard('Parenting for autistic children', 'Bert Pullman',
                      '14 hours'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget courseCard(String title, String author, String duration) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 30, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(author, style: const TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(duration,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
