import 'package:flutter/material.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: const Icon(Icons.onetwothree),
          title: const Text('Numbers'),
          onTap: () {
            // create numeric qr
          },
        ),
        ListTile(
          leading: const Icon(Icons.abc),
          title: const Text('Text'),
          onTap: () {
            // create text qr
          },
        ),
        ListTile(
          leading: const Icon(Icons.file_present),
          title: const Text('File'),
          onTap: () {
            // create file qr
          },
        ),
        ListTile(
          leading: const Icon(Icons.brush),
          title: const Text('Kanji/Kana'),
          onTap: () {
            // create kanji/kana qr
          },
        ),
      ],
    );
  }
}
