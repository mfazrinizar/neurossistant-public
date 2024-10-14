import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/file_picking.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:permission_handler/permission_handler.dart';

import 'chat_input_box.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class ChatItem {
  final Content content;
  final Uint8List? image;

  ChatItem({required this.content, this.image});
}

class _ChatBotPageState extends State<ChatBotPage> {
  final ImagePicker picker = ImagePicker();
  final controller = TextEditingController();
  Gemini gemini = Gemini.instance;
  bool _loading = false;
  Uint8List? selectedImage;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);
  final List<ChatItem> chats = [];
  final List<Content> chatsTextOnly = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: () => Get.offAll(
            () => const HomePage(
              indexFromPrevious: 0,
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('chatbot_title1') ??
              'ChatBot Assistant',
        ),
        actions: [
          const LanguageSwitcher(onPressed: localizationChange),
          ThemeSwitcher(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.black,
              onPressed: () {
                setState(
                  () {
                    themeChange();
                  },
                );
              }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chats.isNotEmpty
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      reverse: true,
                      child: ListView.builder(
                        itemBuilder: chatItem,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chats.length,
                        reverse: false,
                      ),
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Theme.of(context).brightness == Brightness.dark
                                ? 'assets/images/chatbot1_dark.svg'
                                : 'assets/images/chatbot1_light.svg',
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.scaleDown,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!
                                      .translate('chatbot_desc1') ??
                                  '\n\nDisclaimer: Please refer to professionals for legit advices, use AI for second opinion only.\n\nHistory of chats will be deleted right after you leave.\n\nAsk something...',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          if (loading)
            CircularProgressIndicator(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.blueAccent,
            ),
          // if (selectedImage != null)
          //   ClipRRect(
          //     borderRadius: BorderRadius.circular(16),
          //     child: Image.memory(
          //       selectedImage!,
          //       width: MediaQuery.of(context).size.width * 0.50,
          //       fit: BoxFit.scaleDown,
          //     ),
          //   ),
          ChatInputBox(
            controller: controller,
            onClickCamera: () async {
              final status = await FilePicking().requestPermission();
              if (!status.isGranted) {
                return;
              }
              if (!context.mounted) return;
              final action = await showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!
                          .translate('image_dialog_choose_an_action1') ??
                      'Choose an action'),
                  content: Text(AppLocalizations.of(context)!
                          .translate('image_dialog_take_a_photo_source1') ??
                      'Pick an image from the gallery or take a new photo?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Gallery'),
                      child: Text(
                        AppLocalizations.of(context)!
                                .translate('image_dialog_gallery1') ??
                            'Gallery',
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Camera'),
                      child: Text(
                        AppLocalizations.of(context)!
                                .translate('image_dialog_camera1') ??
                            'Camera',
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                    ),
                  ],
                ),
              );

              ImageSource source;
              if (action == 'Gallery') {
                source = ImageSource.gallery;
              } else if (action == 'Camera') {
                source = ImageSource.camera;
              } else {
                // The user cancelled the dialog
                return;
              }

              final XFile? photo = await picker.pickImage(source: source);

              if (photo != null) {
                photo.readAsBytes().then(
                      (value) => setState(
                        () {
                          selectedImage = value;
                        },
                      ),
                    );
              }
            },
            onSend: () async {
              if (controller.text.isNotEmpty) {
                loading = true;
                final searchedText = controller.text;
                chats.add(
                  ChatItem(
                      content: Content(
                        role: 'user',
                        parts: [
                          Parts(text: searchedText),
                        ],
                      ),
                      image: selectedImage),
                );
                controller.clear();

                try {
                  if (selectedImage != null) {
                    await gemini
                        .textAndImage(
                            text: searchedText, images: [selectedImage!])
                        .timeout(const Duration(seconds: 20))
                        .then((value) {
                          chats.add(
                            ChatItem(
                              content: Content(
                                role: 'model',
                                parts: [Parts(text: value?.output)],
                              ),
                            ),
                          );
                        }); // Set a timeout
                  } else {
                    // print(chatsTextOnly);
                    chatsTextOnly.add(Content(
                      role: 'user',
                      parts: [Parts(text: searchedText)],
                    ));

                    await gemini
                        .chat(chatsTextOnly)
                        .timeout(const Duration(seconds: 20))
                        .then(
                      (value) {
                        chats.add(
                          ChatItem(
                            content: Content(
                              role: 'model',
                              parts: [
                                Parts(text: value?.output),
                              ],
                            ),
                          ),
                        );
                      },
                    ); // Set a timeout
                  }
                } on TimeoutException catch (_) {
                  if (context.mounted) {
                    Get.snackbar(
                        'Error',
                        AppLocalizations.of(context)!
                                .translate('chatbot_error1') ??
                            'Timeout occurred. Please try again.');
                  }
                  loading = false; // Stop the Gemini instance
                } catch (e) {
                  if (context.mounted) {
                    Get.snackbar(
                        'Error',
                        AppLocalizations.of(context)!
                                .translate('chatbot_error2') ??
                            'An error occurred. Please try again.');
                  }
                  loading = false;
                  // print(e.toString());
                } finally {
                  loading = false;
                  chatsTextOnly.clear();
                }
              }
            },
            selectedImage: selectedImage,
            onClearImage: () => setState(() => selectedImage = null),
          ),
        ],
      ),
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final ChatItem chatItem = chats[index];
    final Content content = chatItem.content;

    return Card(
      elevation: 0,
      color: content.role == 'model'
          ? Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).appBarTheme.backgroundColor
              : Theme.of(context).primaryColorLight
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.role == 'model'
                  ? 'Neurossistant Gemini Model'
                  : AppLocalizations.of(context)!.translate('you') ?? 'You',
              style: TextStyle(
                  color: content.role == 'model'
                      ? Colors.white
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
            ),
            if (chatItem.image != null)
              Image.memory(chatItem.image!,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.scaleDown),
            Markdown(
                styleSheet: content.role == 'model'
                    ? MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.white))
                    : MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black)),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                data: content.parts?.lastOrNull?.text ??
                    AppLocalizations.of(context)!.translate('chatbot_error3') ??
                    'Unable to generate data. Ask with more details.'),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: content.parts?.lastOrNull?.text ?? ''));
                Get.snackbar(
                    AppLocalizations.of(context)!
                            .translate('chatbot_copied1') ??
                        'Copied',
                    AppLocalizations.of(context)!
                            .translate('chatbot_copied_msg1') ??
                        'Content copied successfully.');
              },
              icon: Icon(Icons.copy,
                  color: content.role == 'model'
                      ? Colors.white
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
              label: const Text(''),
            ),
          ],
        ),
      ),
    );
  }
}
