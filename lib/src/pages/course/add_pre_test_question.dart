import 'package:flutter/material.dart';

class AddPreTestQuestionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddQuestion;

  const AddPreTestQuestionPage({Key? key, required this.onAddQuestion})
      : super(key: key);

  @override
  State<AddPreTestQuestionPage> createState() => _AddPreTestQuestionPageState();
}

class _AddPreTestQuestionPageState extends State<AddPreTestQuestionPage> {
  final TextEditingController questionEnController = TextEditingController();
  final TextEditingController questionIdController = TextEditingController();
  final TextEditingController optionAEnController = TextEditingController();
  final TextEditingController optionAIdController = TextEditingController();
  final TextEditingController optionBEnController = TextEditingController();
  final TextEditingController optionBIdController = TextEditingController();
  final TextEditingController optionCEnController = TextEditingController();
  final TextEditingController optionCIdController = TextEditingController();
  final TextEditingController optionDEnController = TextEditingController();
  final TextEditingController optionDIdController = TextEditingController();
  final TextEditingController optionEEnController = TextEditingController();
  final TextEditingController optionEIdController = TextEditingController();
  final TextEditingController correctAnswerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pre-Test Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: questionEnController,
                decoration: const InputDecoration(labelText: 'Question (EN)'),
              ),
              TextFormField(
                controller: questionIdController,
                decoration: const InputDecoration(labelText: 'Question (ID)'),
              ),
              TextFormField(
                controller: optionAEnController,
                decoration: const InputDecoration(labelText: 'Option A (EN)'),
              ),
              TextFormField(
                controller: optionAIdController,
                decoration: const InputDecoration(labelText: 'Option A (ID)'),
              ),
              TextFormField(
                controller: optionBEnController,
                decoration: const InputDecoration(labelText: 'Option B (EN)'),
              ),
              TextFormField(
                controller: optionBIdController,
                decoration: const InputDecoration(labelText: 'Option B (ID)'),
              ),
              TextFormField(
                controller: optionCEnController,
                decoration: const InputDecoration(labelText: 'Option C (EN)'),
              ),
              TextFormField(
                controller: optionCIdController,
                decoration: const InputDecoration(labelText: 'Option C (ID)'),
              ),
              TextFormField(
                controller: optionDEnController,
                decoration: const InputDecoration(labelText: 'Option D (EN)'),
              ),
              TextFormField(
                controller: optionDIdController,
                decoration: const InputDecoration(labelText: 'Option D (ID)'),
              ),
              TextFormField(
                controller: optionEEnController,
                decoration: const InputDecoration(labelText: 'Option E (EN)'),
              ),
              TextFormField(
                controller: optionEIdController,
                decoration: const InputDecoration(labelText: 'Option E (ID)'),
              ),
              TextFormField(
                controller: correctAnswerController,
                decoration: const InputDecoration(
                    labelText: 'Correct Answer (A, B, C, D, or E)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> questionData = {
                    "question": {
                      "en": questionEnController.text,
                      "id": questionIdController.text,
                    },
                    "options": {
                      "A": {
                        "en": optionAEnController.text,
                        "id": optionAIdController.text,
                      },
                      "B": {
                        "en": optionBEnController.text,
                        "id": optionBIdController.text,
                      },
                      "C": {
                        "en": optionCEnController.text,
                        "id": optionCIdController.text,
                      },
                      "D": {
                        "en": optionDEnController.text,
                        "id": optionDIdController.text,
                      },
                      "E": {
                        "en": optionEEnController.text,
                        "id": optionEIdController.text,
                      },
                    },
                    "correctAnswer": correctAnswerController.text,
                  };

                  widget.onAddQuestion(questionData);
                  Navigator.of(context).pop();
                },
                child: const Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
