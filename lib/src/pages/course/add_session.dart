import 'package:flutter/material.dart';

class AddSessionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddSession;

  const AddSessionPage({Key? key, required this.onAddSession})
      : super(key: key);

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  final TextEditingController titleEnController = TextEditingController();
  final TextEditingController titleIdController = TextEditingController();
  final TextEditingController contentEnController = TextEditingController();
  final TextEditingController contentIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: titleEnController,
                decoration: const InputDecoration(labelText: 'Title (EN)'),
              ),
              TextFormField(
                controller: titleIdController,
                decoration: const InputDecoration(labelText: 'Title (ID)'),
              ),
              TextFormField(
                controller: contentEnController,
                decoration: const InputDecoration(labelText: 'Content (EN)'),
              ),
              TextFormField(
                controller: contentIdController,
                decoration: const InputDecoration(labelText: 'Content (ID)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> sessionData = {
                    "title": {
                      "en": titleEnController.text,
                      "id": titleIdController.text,
                    },
                    "content": {
                      "en": contentEnController.text,
                      "id": contentIdController.text,
                    },
                  };

                  widget.onAddSession(sessionData);
                  Navigator.of(context).pop();
                },
                child: const Text('Add Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
