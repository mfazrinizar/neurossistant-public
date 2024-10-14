import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/consult/consult.dart';
// import 'package:neurossistant/src/theme/theme.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../db/consult/chat_api.dart';
import '../../theme/theme.dart';
import '../profile/profile.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final Pengguna pengguna;

  const ChatScreen({super.key, required this.pengguna});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late String friendName;
  late String friendUid;
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  late String chatDocId;
  bool isDarkMode = Get.isDarkMode;

  bool onKeyboard = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _showEmojiPicker = ValueNotifier<bool>(false);
  late DocumentReference chatDocRef;

  Future<void> _initializeChat() async {
    friendName = widget.pengguna.name;
    friendUid = widget.pengguna.uid;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final chatId = currentUserId.compareTo(friendUid) < 0
        ? '$currentUserId-$friendUid'
        : '$friendUid-$currentUserId';

    final CollectionReference chats =
        FirebaseFirestore.instance.collection('chats');

    final chatDocRef = chats.doc(chatId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatDocRef);

      if (!chatDoc.exists) {
        transaction.set(chatDocRef, {
          'users': [currentUserId, friendUid],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': ''
        });
      }

      // Add/update userLastSeen
      // transaction.update(chatDocRef, {
      //   'usersLastSeen.$currentUserId': FieldValue.serverTimestamp(),
      //   '$currentUserId-notSeenMessages': 0
      // });

      chatDocId = chatDocRef.id;
    });
  }

  Future<void> _updateSeenChat() async {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(chatDocId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(chatDocRef, {
        'usersLastSeen.$currentUserId': FieldValue.serverTimestamp(),
        '$currentUserId-notSeenMessages': 0
      });
    });
  }

  // Future<void> _updateLastSeen() async {
  //   final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //   final chatDocRef =
  //       FirebaseFirestore.instance.collection('chats').doc(chatDocId);

  //   await FirebaseFirestore.instance.runTransaction((transaction) async {
  //     transaction.update(chatDocRef, {
  //       'usersLastSeen.$currentUserId': FieldValue.serverTimestamp(),
  //     });
  //   });
  // }

  Future<void> _updateLastMessage(String message) async {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(chatDocId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(chatDocRef, {
        'lastMessage': message,
        'lastMessageSendByName': FirebaseAuth.instance.currentUser?.displayName,
        'lasMessageSendById': FirebaseAuth.instance.currentUser?.uid,
        'lastMessageDate': DateTime.now()
      });
    });
  }

  Future<void> _addFrienUnseenChat() async {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(chatDocId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(chatDocRef, {
        '$friendUid-notSeenMessages': FieldValue.increment(1),
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _initializeChat().catchError((error) {
      if (kDebugMode) debugPrint("Error initializing chat: $error");
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    _showEmojiPicker.dispose();
    // _updateSeenChat();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _showEmojiPicker.value) {
      // setState(() {
      _showEmojiPicker.value = false;
      // });
    }
  }

  void _toggleEmojiPicker() async {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      await Future.delayed(const Duration(milliseconds: 70));
    }
    _showEmojiPicker.value = !_showEmojiPicker.value;
  }

  void _onEmojiSelected(Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  void _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  bool _isSender(String sender) {
    return sender == currentUserId;
  }

  Alignment _getChatAlignment(String sender) {
    if (_isSender(sender)) {
      return Alignment.topRight;
    } else {
      return Alignment.topLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeChat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text("Error initializing chat: ${snapshot.error}"));
        } else {
          return PopScope(
            canPop: _showEmojiPicker.value,
            onPopInvoked: (didPop) {
              if (_showEmojiPicker.value) {
                // If the emoji picker is open, close it
                _showEmojiPicker.value = false;
              } else if (!didPop) {
                // If the emoji picker is already closed, pop the user out
                Get.back();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.pengguna.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontFamily: "Poppins",
                        color: Colors.white,
                        fontWeight: FontWeight.w400)),
                leadingWidth: 93,
                leading: Row(
                  children: [
                    BackButton(
                      color: isDarkMode
                          ? const Color.fromARGB(255, 211, 227, 253)
                          : Colors.white,
                    ),
                    Builder(
                      builder: (BuildContext context) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(80),
                          onTap: () {
                            Get.to(() => ProfilePage(
                                  pengguna: widget.pengguna,
                                ));
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image:
                                    NetworkImage(widget.pengguna.profilPicture),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: const SizedBox(
                              width: 45,
                              height: 45,
                            ),
                          ),
                        ); // display the user's profile picture
                      },
                    ),
                  ],
                ),
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.black,
                elevation: 7,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: PopupMenuButton<String>(
                        iconColor: isDarkMode
                            ? const Color.fromARGB(255, 211, 227, 253)
                            : Colors.white,
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context)!
                                      .translate('consult_chat_look_profile') ??
                                  "Look Profile"),
                              onTap: () {},
                            ),
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context)!
                                      .translate('consult_chat_search') ??
                                  "Search"),
                              onTap: () {},
                            ),
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context)!
                                      .translate('consult_chat_block') ??
                                  "Block"),
                              onTap: () {},
                            ),
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context)!
                                      .translate('consult_chat_report') ??
                                  "Report"),
                              onTap: () {},
                            ),
                          ];
                        }),
                  )
                ],
              ),
              body: StreamBuilder<List<ChatMessage>>(
                stream: ChatApi().streamChatMessages(chatDocId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          'Error fetching chat history: ${snapshot.error}'),
                    );
                  } else {
                    final messages = snapshot.data!;

                    final groupedMessages = _groupMessagesByDate(messages);
                    _updateSeenChat();
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _showEmojiPicker,
                              builder: (context, showEmojiPicker, child) {
                                return AnimatedPadding(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.only(
                                    bottom: showEmojiPicker ? 320 : 65.0,
                                  ),
                                  child: ListView.builder(
                                    reverse: true,
                                    itemCount: groupedMessages.length,
                                    itemBuilder: (context, index) {
                                      final dateGroup = groupedMessages[index];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16),
                                              child: Container(
                                                height: 30,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? const Color.fromARGB(
                                                          255, 24, 58, 99)
                                                      : const Color.fromARGB(
                                                          255, 71, 124, 217),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    dateGroup.date,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: "Poppins",
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ...dateGroup.messages
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final msg = entry.value;
                                            final isFirstMessage =
                                                entry.key == 0;
                                            final isSenderSameAsPrevious =
                                                !_isSenderSameAsPrevious(
                                                    msg.senderId,
                                                    dateGroup.messages,
                                                    entry.key);
                                            return Align(
                                              alignment: _getChatAlignment(
                                                  msg.senderId),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: isSenderSameAsPrevious
                                                      ? 0
                                                      : isFirstMessage
                                                          ? 20
                                                          : 0,
                                                  bottom: 4,
                                                  left: 16,
                                                  right: 16,
                                                ),
                                                child: ChatBubble(
                                                  clipper: ChatBubbleClipper5(
                                                    type:
                                                        _isSender(msg.senderId)
                                                            ? BubbleType
                                                                .sendBubble
                                                            : BubbleType
                                                                .receiverBubble,
                                                  ),
                                                  alignment:
                                                      _isSender(msg.senderId)
                                                          ? Alignment.topRight
                                                          : Alignment.topLeft,
                                                  margin: EdgeInsets.only(
                                                      top: isFirstMessage
                                                          ? 20
                                                          : 4),
                                                  backGroundColor: _isSender(
                                                          msg.senderId)
                                                      ? isDarkMode
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 24, 58, 99)
                                                          : ThemeClass()
                                                              .lightPrimaryColor
                                                      : isDarkMode
                                                          ? Colors.grey[900]
                                                          : const Color(
                                                              0xffE7E7ED),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                    ),
                                                    child: Text(
                                                      msg.msg,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: "Poppins",
                                                        color: _isSender(
                                                                msg.senderId)
                                                            ? isDarkMode
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    211,
                                                                    227,
                                                                    253)
                                                                : Colors.white
                                                            : isDarkMode
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    211,
                                                                    227,
                                                                    253)
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                55,
                                        child: Card(
                                          color: isDarkMode
                                              ? Colors.grey[900]
                                              : Colors.grey[300],
                                          margin: const EdgeInsets.fromLTRB(
                                              2, 0, 2, 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: TextFormField(
                                            controller: _controller,
                                            focusNode: _focusNode,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: 5,
                                            minLines: 1,
                                            decoration: InputDecoration(
                                              focusedBorder: InputBorder.none,
                                              border: InputBorder.none,
                                              hintText: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'consult_chat_hint') ??
                                                  "Type a message...",
                                              prefixIcon: IconButton(
                                                icon: Icon(
                                                  Icons.emoji_emotions,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                                onPressed: _toggleEmojiPicker,
                                              ),
                                              suffixIcon: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      _showEmojiPicker.value =
                                                          false;
                                                      if (_focusNode.hasFocus) {
                                                        _focusNode.unfocus();
                                                      }
                                                      showModalBottomSheet(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        context: context,
                                                        builder: (builder) =>
                                                            _bottomsheet(
                                                                context),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.attach_file_sharp,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                      Icons.camera_alt_sharp,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.all(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8, left: 2),
                                      child: CircleAvatar(
                                        backgroundColor: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 24, 58, 99)
                                            : ThemeClass().lightPrimaryColor,
                                        radius: 23,
                                        child: IconButton(
                                          onPressed: () async {
                                            if (_controller.text
                                                .trim()
                                                .isNotEmpty) {
                                              await ChatApi().postChatMessage(
                                                chatDocId: chatDocId,
                                                msg: _controller.text.trim(),
                                                senderId: currentUserId,
                                              );
                                              _updateLastMessage(
                                                  _controller.text.trim());
                                              _addFrienUnseenChat();
                                              _controller.clear();
                                            }
                                          },
                                          icon: const Icon(Icons.send_sharp),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ValueListenableBuilder<bool>(
                                  valueListenable: _showEmojiPicker,
                                  builder: (context, showEmojiPicker, child) {
                                    if (showEmojiPicker &&
                                        !_focusNode.hasFocus) {
                                      return SizedBox(
                                        height: 256,
                                        child: child,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                  child: PopScope(
                                    canPop: _showEmojiPicker.value,
                                    child: EmojiPicker(
                                      onEmojiSelected: (categoryEmoji, emoji) {
                                        _onEmojiSelected(emoji);
                                      },
                                      onBackspacePressed: _onBackspacePressed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _bottomsheet(BuildContext context) {
    return SizedBox(
      height: 270,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}

bool _isSenderSameAsPrevious(
    String sender, List<ChatMessage> messages, int index) {
  if (index < messages.length - 1) {
    return messages[index + 1].senderId == sender;
  }
  return false;
}

List<_DateGroup> _groupMessagesByDate(List<ChatMessage> messages) {
  final groupedMessages = <_DateGroup>[];
  String? lastDate;

  for (final msg in messages.reversed) {
    // Reverse the order of messages here
    final date = _formatDate(msg.createdOn);
    if (lastDate == date) {
      groupedMessages.last.messages.add(msg);
    } else {
      groupedMessages.add(_DateGroup(date, [msg]));
      lastDate = date;
    }
  }

  return groupedMessages.reversed
      .toList(); // Reverse the order of groups before returning
}

String _formatDate(DateTime date) {
  final locale = Get.locale?.toLanguageTag() ?? 'en';
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return locale == 'en' ? 'Today' : 'Hari ini';
  } else if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    return locale == 'en' ? 'Yesterday' : 'Kemarin';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DateGroup {
  final String date;
  final List<ChatMessage> messages;

  _DateGroup(this.date, this.messages);
}
