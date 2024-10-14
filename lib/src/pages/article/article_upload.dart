import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neurossistant/src/db/article/article_api.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/reusable_func/file_picking.dart';

class ArticleUploadPage extends StatefulWidget {
  const ArticleUploadPage({super.key});

  @override
  ArticleUploadPageState createState() => ArticleUploadPageState();
}

class ArticleUploadPageState extends State<ArticleUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  File? _image;
  final _filePicking = FilePicking();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Article',
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Get.offAll(
            () => const HomePage(
              indexFromPrevious: 2,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a body';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child: const Text('Select Image'),
              onPressed: () async {
                final pickedFile =
                    await _filePicking.pickImage(ImageSource.gallery);
                setState(() {
                  _image = pickedFile;
                });
              },
            ),
            if (_image != null)
              kIsWeb ? Image.network(_image!.path) : Image.file(_image!),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                EasyLoading.show(status: 'Uploading...');
                if (_formKey.currentState!.validate() && _image != null) {
                  final uploadingProcess = await ArticleApi.postArticle(
                    title: _titleController.text,
                    body: _bodyController.text,
                    image: _image!,
                  );

                  if (uploadingProcess == 'SUCCESS') {
                    Get.snackbar('Success', 'Articles posted successfully.');
                  } else if (uploadingProcess == 'NOT-ADMIN') {
                    Get.snackbar(
                        'Error', 'You are not authorized to post articles.');
                    // if (!context.mounted) return;
                    // Navigator.pop(context); // Mungkin tidak perlu? Supaya user tetap bisa upload article lagi.
                  } else {
                    Get.snackbar('Error', 'Something went wrong, check logs.');
                  }
                }
                EasyLoading.dismiss();
              },
            ),
          ],
        ),
      ),
    );
  }
}
