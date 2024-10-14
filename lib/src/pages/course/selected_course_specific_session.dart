import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neurossistant/src/db/course/selected_course_session_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/course/material_pdf_viewer_page.dart';
import 'package:neurossistant/src/pages/course/selected_course_session.dart';
// import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
// import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class SelectedCourseSpecificSessionPage extends StatefulWidget {
  final String titleEn;
  final String titleId;
  final String psychologist;
  final int durations;
  final int sessions;
  final String tag;
  final String imageUrl;
  final String courseId;
  final DateTime dateTime;
  final int popularity;
  final String psychologistId;
  final String descriptionEn;
  final String descriptionId;
  final int sessionNumber;
  final bool isTaskSubmitted;

  const SelectedCourseSpecificSessionPage({
    Key? key,
    required this.titleEn,
    required this.titleId,
    required this.psychologist,
    required this.durations,
    required this.sessions,
    required this.tag,
    required this.imageUrl,
    required this.courseId,
    required this.dateTime,
    required this.popularity,
    required this.psychologistId,
    required this.descriptionEn,
    required this.descriptionId,
    required this.sessionNumber,
    required this.isTaskSubmitted,
  }) : super(key: key);

  @override
  State<SelectedCourseSpecificSessionPage> createState() =>
      _SelectedCourseSpecificSessionPageState();
}

class _SelectedCourseSpecificSessionPageState
    extends State<SelectedCourseSpecificSessionPage> {
  bool isDarkMode = Get.isDarkMode;
  bool? isUserRegistered;
  late YoutubePlayerController _youtubePlayerController;
  final SelectedCourseSessionApi api = SelectedCourseSessionApi();
  late Future<SelectedCoursesData?> _sessionDataFuture;
  String? videoId;
  bool taskSubmitted = false;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();
  List<Comment> commentsList = [];

  // final GlobalKey<SfPdfViewerState> _pdfViewerKey =
  //     GlobalKey<SfPdfViewerState>();

  @override
  initState() {
    taskSubmitted = widget.isTaskSubmitted;

    super.initState();
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _youtubePlayerController.addListener(() {
      if (_youtubePlayerController.value.isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: [SystemUiOverlay.top]);
      }
    });
    _sessionDataFuture = api.fetchSessions(widget.courseId);
  }

  String parseVideoId(String videoId) {
    if (videoId.contains('v=')) {
      return videoId.split('v=')[1];
    } else {
      return videoId;
    }
    // _sessionDataFuture = api.fetchSessions(widget.courseId);
    // _sessionDataFuture.then((data) {
    //   final session = data?.sessions.firstWhere(
    //       (session) => session.sessionNumber == widget.sessionNumber);
    //   setState(() {
    //     videoId = session?.materials[0].content['en'].split('v=')[1];
    //     if (kDebugMode) debugPrint('Video ID: $videoId');
    //   });
    // }).catchError((e) {
    //   if (kDebugMode) debugPrint(e.toString());
    // });
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    // final isFullScreen = _youtubePlayerController.value.isFullScreen;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Get.off(
            () => SelectedCourseSessionPage(
                titleEn: widget.titleEn,
                titleId: widget.titleId,
                psychologist: widget.psychologist,
                durations: widget.durations,
                sessions: widget.sessions,
                tag: widget.tag,
                imageUrl: widget.imageUrl,
                courseId: widget.courseId,
                dateTime: widget.dateTime,
                popularity: widget.popularity,
                psychologistId: widget.psychologistId,
                descriptionEn: widget.descriptionEn,
                descriptionId: widget.descriptionId),
          );
        }
      },
      child: FutureBuilder<SelectedCoursesData?>(
        future: _sessionDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found.'));
          } else {
            final session = snapshot.data?.sessions.firstWhere(
                (session) => session.sessionNumber == widget.sessionNumber);
            commentsList = session?.commentsList ?? [];

            return YoutubePlayerBuilder(
              player: YoutubePlayer(
                aspectRatio: 16 / 7,
                controller: _youtubePlayerController = YoutubePlayerController(
                  initialVideoId: parseVideoId((locale == 'en'
                          ? session!.materials[0].content['en']
                          : session!.materials[0].content['id']) ??
                      ''),
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.lightBlue,
              ),
              builder: (context, player) {
                return Scaffold(
                  appBar: AppBar(
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? ThemeClass().darkRounded
                            : ThemeClass().lightPrimaryColor,
                    title: Text(
                      '${AppLocalizations.of(context)!.translate('course_session1') ?? 'Session'} ${widget.sessionNumber}',
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 211, 227, 253)
                              : Colors.white),
                    ),
                    leading: BackButton(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 211, 227, 253)
                          : Colors.white,
                    ),
                    actions: [
                      // LanguageSwitcher(
                      //   onPressed: localizationChange,
                      //   textColor:
                      //       Theme.of(context).brightness == Brightness.dark
                      //           ? const Color.fromARGB(255, 211, 227, 253)
                      //           : Colors.white,
                      // ),
                      ThemeSwitcher(onPressed: () async {
                        themeChange();
                        setState(() {
                          isDarkMode = !isDarkMode;
                        });
                      }),
                      Builder(
                        builder: (BuildContext context) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null && user.photoURL != null) {
                            return ClipOval(
                              child: FadeInImage.assetNetwork(
                                image: user.photoURL!,
                                placeholder:
                                    'assets/images/placeholder_loading.gif',
                                fit: BoxFit.cover,
                                width: 45,
                                height: 45,
                              ),
                            ); // display the user's profile picture
                          } else {
                            return Icon(
                              Icons.account_circle,
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 211, 227, 253)
                                  : Colors.white,
                            ); // show a default icon if the user is not logged in or doesn't have a profile picture
                          }
                        },
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  (locale == 'en'
                                          ? session.sessionTitle['en']
                                          : session.sessionTitle['id']) ??
                                      'No title',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(Icons.timelapse),
                                    Text(
                                      ' ${session.duration} ${(AppLocalizations.of(context)!.translate('course_hour1') ?? 'Hour') + (session.duration > 1 && locale == 'en' ? 's' : '')}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 2.0,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)!.translate(
                                        'selected_course_session_video_material1') ??
                                    'Video Material:',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              player,
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)!.translate(
                                        'selected_course_session_article_material1') ??
                                    'Article Material:',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Card(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? ThemeClass().darkRounded
                                    : Colors.white70,
                                elevation: 4,
                                child: Text(
                                  Uri.decodeFull((locale == 'en'
                                          ? session.materials[1].content['en']
                                          : session
                                              .materials[1].content['id']) ??
                                      'No text material.'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)!
                                        .translate('course_pdf_material1') ??
                                    'PDF Material:',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  String pdfUrl = (locale == 'en'
                                          ? session.materials[2].content['en']
                                          : session
                                              .materials[2].content['id']) ??
                                      '';
                                  if (pdfUrl.isNotEmpty) {
                                    Get.to(() =>
                                        MaterialPdfViewerPage(pdfUrl: pdfUrl));
                                  } else {
                                    if (kDebugMode) {
                                      debugPrint('PDF URL is empty');
                                    }
                                  }
                                },
                                label: Text(
                                  AppLocalizations.of(context)!.translate(
                                          'selected_course_session_pdf_button1') ??
                                      'Open PDF Material',
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color.fromARGB(
                                              255, 211, 227, 253)
                                          : Colors.blue[10],
                                      fontWeight: FontWeight.bold),
                                ),
                                icon: Icon(
                                  Icons.picture_as_pdf,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.blue[10],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)!.translate(
                                        'selected_course_session_task1') ??
                                    'Task:',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Card(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? ThemeClass().darkRounded
                                    : Colors.white70,
                                elevation: 4,
                                child: Text(
                                  Uri.decodeFull((locale == 'en'
                                          ? session.task.description['en']
                                          : session.task.description['id']) ??
                                      'No description'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? ThemeClass().darkRounded
                                          : Colors.blue[10],
                                ),
                                onPressed: taskSubmitted ||
                                        userId == widget.psychologistId
                                    ? null
                                    : () {
                                        _showTaskSubmissionDialog(context);
                                      },
                                child: Text(userId == widget.psychologistId
                                    ? AppLocalizations.of(context)!
                                            .translate('you_are_the_author') ??
                                        'You Are the Author'
                                    : taskSubmitted
                                        ? AppLocalizations.of(context)!.translate(
                                                'selected_course_session_submitted_task_button1') ??
                                            'Task Submitted'
                                        : AppLocalizations.of(context)!.translate(
                                                'selected_course_session_unsubmitted_task_button1') ??
                                            'Submit Task'),
                              ),
                              if (taskSubmitted)
                                TextButton.icon(
                                  onPressed: () async {
                                    final api = SelectedCourseSessionApi();

                                    final taskSubmission = await api
                                        .fetchCurrentUserTaskSubmissions(
                                            widget.courseId,
                                            userId!,
                                            widget.sessionNumber);

                                    if (taskSubmission != null) {
                                      if (context.mounted) {
                                        _showSubmissionDialog(
                                            context, taskSubmission);
                                      }
                                    } else {
                                      if (context.mounted) {
                                        EasyLoading.showError(AppLocalizations
                                                    .of(context)!
                                                .translate(
                                                    'selected_course_session_task_submitted_error1') ??
                                            'Error fetching task submission');
                                      }
                                    }
                                  },
                                  label: Text(
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_task_submitted_button1') ??
                                        'See Your Submission',
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color.fromARGB(
                                                255, 211, 227, 253)
                                            : Colors.blue[10],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  icon: Icon(
                                    Icons.task,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors.blue[10],
                                  ),
                                ),
                              Container(
                                height: 2.0,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildCommentForm(
                          context,
                        ),
                        _buildCommentList(context),
                        const SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCommentForm(BuildContext context) {
    return Form(
      key: _editFormKey,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.translate(
                        'selected_course_session_enter_a_comment1') ??
                    'Please enter a comment';
              }
              return null;
            },
            focusNode: commentFocusNode,
            controller: commentController,
            decoration: InputDecoration(
              labelStyle: const TextStyle(
                color: Colors.black,
              ),
              hintText: AppLocalizations.of(context)!
                      .translate('selected_course_session_write_a_comment1') ??
                  'Write a comment...',
              prefixIcon: const Icon(Icons.comment),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _postComment,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentList(BuildContext context) {
    return Column(
      children: List.generate(
        commentsList.length,
        (index) {
          final Comment comment = commentsList[index];
          return ListTile(
            leading: ClipOval(
              child: FadeInImage.assetNetwork(
                image: comment.avatarUrl,
                placeholder: 'assets/images/placeholder_loading.gif',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SelectableText(
                    '${comment.commenterName} | ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    DateFormat('yyyy-MM-dd – kk:mm')
                        .format(comment.commentDate),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 12),
                  ),
                  if (userId == comment.commenterId)
                    InkWell(
                      onTap: () async {
                        _showDeleteCommentDialog(comment, context);
                      },
                      child: const Icon(Icons.delete),
                    ),
                ],
              ),
            ),
            subtitle: SelectableText(
              comment.text,
              textAlign: TextAlign.justify,
            ),
          );
        },
      ),
    );
  }

// Assuming this function is triggered when taskSubmission is not null
  void _showSubmissionDialog(
      BuildContext context, Map<String, dynamic> taskSubmission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate(
                  'selected_course_session_task_submission_title1') ??
              'Task Submission'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '${AppLocalizations.of(context)!.translate('selected_course_session_session_number1') ?? 'Session Number:'} ${taskSubmission['sessionNumber']}'),
                Text(
                    '${AppLocalizations.of(context)!.translate('selected_course_session_submitted_at1') ?? 'Submitted At:'} ${DateFormat('dd-MM-yyyy').format((taskSubmission['submittedAt'] as Timestamp).toDate())}'),
                Text(
                    '${AppLocalizations.of(context)!.translate('selected_course_session_submitted_answer1') ?? 'Submitted Answer:'} '),
                Text(
                  taskSubmission['taskText'],
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : ThemeClass().lightPrimaryColor,
                    ),
                    child: Text(AppLocalizations.of(context)!.translate(
                            'selected_course_session_download_submission_button1') ??
                        'Download Submission'),
                    onPressed: () async {
                      _downloadFile(taskSubmission['taskFileUrl'], context);
                    }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.translate('close') ?? 'Close',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 211, 227, 253)
                      : ThemeClass().lightPrimaryColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadFile(String url, BuildContext context) async {
    try {
      bool storage = true;

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (Platform.isAndroid) {
        if (androidInfo.version.sdkInt >= 33) {
          // Do nothing
        } else {
          PermissionStatus storageStatus = await Permission.storage.request();

          if (storageStatus.isGranted) {
            storage = true;
          } else if (storageStatus.isDenied) {
            await Permission.storage.request();
          } else if (storageStatus.isPermanentlyDenied) {
            storage = false;
            await openAppSettings();
          } else {
            if (context.mounted) {
              EasyLoading.showError(AppLocalizations.of(context)!.translate(
                      'selected_course_session_storage_permission_not_granted1') ??
                  'Storage permission is not granted');
            }
            return;
          }
        }
      }

      if (storage) {
        if (context.mounted) {
          EasyLoading.show(
              status: AppLocalizations.of(context)!.translate(
                      'selected_course_session_getting_directory1') ??
                  'Getting Directory...');
        }

        // Use FilePicker to pick a directory
        String? directoryPath = androidInfo.version.sdkInt < 30
            ? await FilePicker.platform.getDirectoryPath()
            : (await getExternalStorageDirectory())?.path;

        if (directoryPath == null) {
          if (context.mounted) {
            EasyLoading.showInfo(AppLocalizations.of(context)!
                    .translate('selected_course_session_directory_failed1') ??
                'Can\'t access selected directory');
          }
          EasyLoading.dismiss();
          return;
        }

        String? fileName;
        EasyLoading.dismiss();
        if (context.mounted) fileName = await _showFileNameDialog(context);
        if (fileName == null || fileName.isEmpty) {
          if (context.mounted) {
            EasyLoading.showInfo(AppLocalizations.of(context)!.translate(
                    'selected_course_session_submit_task_dialog_submit_file_name_empty1') ??
                'File name can\'t be empty');
          }
          EasyLoading.dismiss();
          return;
        }

        EasyLoading.dismiss();
        if (context.mounted) {
          EasyLoading.show(
              status: AppLocalizations.of(context)!
                      .translate('selected_course_downloading_file1') ??
                  'Downloading File...');
        }

        String extension = path.extension(url).contains('.pdf')
            ? '.pdf'
            : path.extension(url).contains('.txt')
                ? '.txt'
                : '';

        String filePath = '$directoryPath/$fileName$extension';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          if (context.mounted) {
            EasyLoading.showSuccess(
                '${AppLocalizations.of(context)!.translate('selected_course_session_downloaded_file1') ?? 'File downloaded to'} $filePath',
                duration: const Duration(seconds: 5));
            await openFile(filePath);
          }
        } else {
          if (context.mounted) {
            EasyLoading.showError(AppLocalizations.of(context)!.translate(
                    'selected_course_session_storage_error_downloading') ??
                'Error downloading file');
          }
        }
        EasyLoading.dismiss();
      } else {
        if (!storage) {
          if (context.mounted) {
            EasyLoading.showError(AppLocalizations.of(context)!.translate(
                    'selected_course_session_storage_permission_not_granted1') ??
                'Storage permission not granted');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      if (context.mounted) {
        EasyLoading.showError(AppLocalizations.of(context)!.translate(
                'selected_course_session_storage_error_downloading') ??
            'Error downloading file');
      }
      EasyLoading.dismiss();
    }
  }

  Future<String?> _showFileNameDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.translate('enter_file_name') ??
                  'Enter File Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)?.translate('file_name') ??
                        'File Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 211, 227, 253)
                      : ThemeClass().lightPrimaryColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)?.translate('ok') ?? 'OK',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 211, 227, 253)
                      : ThemeClass().lightPrimaryColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _postComment() async {
    if (_editFormKey.currentState!.validate()) {
      final api = SelectedCourseSessionApi();

      final newComment = Comment(
        commentId: const Uuid().v4(),
        commenterId: userId ?? '',
        commenterName:
            FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous',
        avatarUrl: FirebaseAuth.instance.currentUser?.photoURL ?? '',
        text: commentController.text,
        commentDate: DateTime.now(),
      );

      try {
        await api.addComment(widget.courseId, widget.sessionNumber, newComment);
      } catch (e) {
        if (kDebugMode) debugPrint('Error posting comment: $e');
        if (mounted) {
          EasyLoading.showError(AppLocalizations.of(context)!
                  .translate('selected_course_session_error_comment1') ??
              'Error posting comment');
        }
        return;
      }

      setState(() {
        commentsList.add(newComment);
        commentController.clear();
      });
      if (mounted) {
        EasyLoading.showToast(AppLocalizations.of(context)!
                .translate('selected_course_session_comment_posted1') ??
            'Comment posted successfully');
      }
    }
  }

  void _showDeleteCommentDialog(Comment comment, BuildContext context) {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      keyboardAware: true,
      dismissOnBackKeyPress: false,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      transitionAnimationDuration: const Duration(milliseconds: 200),
      btnOkText: AppLocalizations.of(context)!.translate('delete') ?? "Delete",
      btnCancelText:
          AppLocalizations.of(context)!.translate('cancel') ?? "Cancel",
      title: AppLocalizations.of(context)!
              .translate('selected_course_session_comment_delete_title1') ??
          'Delete Comment',
      desc: AppLocalizations.of(context)!
              .translate('selected_course_session_comment_delete_message1') ??
          "Are you sure you want to delete this comment?",
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final api = SelectedCourseSessionApi();

        final isSuccess = await api.deleteComment(
            widget.courseId, widget.sessionNumber, comment.commentId);

        if (isSuccess) {
          if (context.mounted) {
            EasyLoading.showSuccess(AppLocalizations.of(context)!
                    .translate('selected_course_session_comment_deleted1') ??
                'Comment deleted successfully');
          }
          setState(() {
            commentsList.remove(comment);
          });
        } else {
          if (context.mounted) {
            EasyLoading.showError(AppLocalizations.of(context)!.translate(
                    'selected_course_session_comment_delete_failed1') ??
                'Error deleting comment');
          }
        }
      },
    ).show();
  }

  void _showTaskSubmissionDialog(BuildContext context) {
    final Color iconAndLabelColor =
        Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 211, 227, 253)
            : ThemeClass().lightPrimaryColor;
    File? taskFile;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        TextEditingController textEditingController = TextEditingController();
        // make form key
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate(
                  'selected_course_session_submit_task_dialog_title1') ??
              'Submit Task'),
          content: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.translate(
                                  'selected_course_session_submit_task_dialog_empty1') ??
                              'Please enter your answer';
                        }
                        return null;
                      },
                      maxLength: 1000,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: textEditingController,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.translate(
                                  'selected_course_session_submit_task_dialog_answer1') ??
                              'Your answer'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : ThemeClass().lightPrimaryColor,
                    ),
                    onPressed: taskFile == null
                        ? () async {
                            try {
                              EasyLoading.show(
                                  status: AppLocalizations.of(context)!.translate(
                                          'selected_course_session_submit_task_dialog_submit_loading_file_picker1') ??
                                      'Opening File Picker...');
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'txt'],
                              );

                              EasyLoading.dismiss();
                              if (result != null) {
                                PlatformFile file = result.files.first;
                                String? filePath = file.path;

                                if (file.size > 2 * 1024 * 1024) {
                                  if (context.mounted) {
                                    EasyLoading.showError(AppLocalizations.of(
                                                context)!
                                            .translate(
                                                'selected_course_session_submit_task_dialog_submit_file_exceeds_limit1') ??
                                        'File size exceeds the limit of 2 MB');
                                  }
                                  EasyLoading.dismiss();
                                  return;
                                } else {
                                  if (filePath != null) {
                                    final String fileType =
                                        path.extension(filePath);

                                    if (fileType != '.pdf' &&
                                        fileType != '.txt') {
                                      if (context.mounted) {
                                        EasyLoading.showError(AppLocalizations
                                                    .of(context)!
                                                .translate(
                                                    'selected_course_session_submit_task_dialog_submit_invalid_file_type1') ??
                                            'Invalid file type');
                                      }

                                      return;
                                    }

                                    setState(() {
                                      taskFile = File(filePath);
                                    });
                                    if (kDebugMode) {
                                      debugPrint('In taskFile: $taskFile');
                                    }
                                  }
                                  if (kDebugMode) {
                                    debugPrint('File path: $filePath');
                                  }
                                }
                              }
                              EasyLoading.dismiss();
                            } on Exception catch (e) {
                              if (kDebugMode) {
                                debugPrint('Error picking file: $e');
                              }
                              if (context.mounted) {
                                EasyLoading.showError(
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_submit_task_dialog_error_picking_file') ??
                                        'Error picking file');
                              }
                              EasyLoading.dismiss();
                            }
                          }
                        : null,
                    child: Text(AppLocalizations.of(context)!.translate(
                            'selected_course_session_submit_task_dialog_choose_file_button1') ??
                        'Choose File'),
                  ),
                  TextButton.icon(
                    onPressed: taskFile != null
                        ? () {
                            if (taskFile != null) {
                              setState(() {
                                taskFile = null;
                              });
                            }
                          }
                        : null,
                    icon: Icon(Icons.delete,
                        color: taskFile != null
                            ? iconAndLabelColor
                            : Colors.blueGrey),
                    label: Text(
                      AppLocalizations.of(context)!.translate(
                              'selected_course_session_submit_task_dialog_remove_file_button1') ??
                          'Remove File',
                      style: TextStyle(
                          color: taskFile != null
                              ? iconAndLabelColor
                              : Colors.blueGrey),
                    ),
                  ),
                  Text(AppLocalizations.of(context)!.translate(
                          'selected_course_session_submit_task_dialog_allowed_file_types') ??
                      "*allowed file types: .pdf and .txt\n*max file size: 2 MB"),
                ],
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.translate('cancel') ?? 'Cancel',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : ThemeClass().lightPrimaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? ThemeClass().darkRounded
                    : ThemeClass().lightPrimaryColor,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final api = SelectedCourseSessionApi();
                  late bool? isUpdated;
                  if (userId != null) {
                    bool cancelDialog = false;
                    if (taskFile == null) {
                      await AwesomeDialog(
                        dismissOnTouchOutside: false,
                        context: context,
                        keyboardAware: true,
                        dismissOnBackKeyPress: false,
                        dialogType: DialogType.question,
                        animType: AnimType.scale,
                        transitionAnimationDuration:
                            const Duration(milliseconds: 200),
                        btnOkText:
                            AppLocalizations.of(context)!.translate('yes') ??
                                "Yes",
                        btnCancelText:
                            AppLocalizations.of(context)!.translate('cancel') ??
                                "Cancel",
                        title: AppLocalizations.of(context)!
                                .translate('no_task_file_title') ??
                            'No Task File Selected',
                        desc: AppLocalizations.of(context)!
                                .translate('no_task_file_body') ??
                            "Are you sure you don't want to attach a task file (optional)?",
                        btnCancelOnPress: () {
                          cancelDialog = true;
                          DismissType.btnCancel;
                          EasyLoading.dismiss();
                        },
                        btnOkOnPress: () async {
                          cancelDialog = false;
                          EasyLoading.show(
                              status: AppLocalizations.of(context)!.translate(
                                      'selected_course_session_submit_task_dialog_submit_loading1') ??
                                  'Submitting Task...');

                          final taskSubmission =
                              await api.uploadSessionTaskSubmission(
                                  widget.courseId,
                                  userId!,
                                  widget.sessionNumber,
                                  textEditingController.text,
                                  taskFile);

                          if (taskSubmission) {
                            setState(() {
                              taskSubmitted = true;
                            });
                            isUpdated = await api.updateUserSessionsProgress(
                                widget.courseId,
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.sessionNumber,
                                widget.sessionNumber == widget.sessions
                                    ? true
                                    : false);
                          }

                          // if (context.mounted) Navigator.of(context).pop();
                        },
                      ).show();
                      if (!cancelDialog) {
                        if (context.mounted) {
                          Future.delayed(const Duration(milliseconds: 1000),
                              () {
                            EasyLoading.dismiss();
                            if (isUpdated ?? false) {
                              if (widget.sessionNumber == widget.sessions) {
                                EasyLoading.showSuccess(
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_submit_task_dialog_course_completed1') ??
                                        'Course completed successfully');
                              } else {
                                EasyLoading.showSuccess(
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_submit_task_dialog_submit_success1') ??
                                        'Task submitted successfully');
                              }
                            } else {
                              EasyLoading.showError(
                                  AppLocalizations.of(context)!.translate(
                                          'selected_course_session_submit_task_dialog_submit_error1') ??
                                      'Error updating task submission status.');
                            }
                          });
                        } else {
                          if (context.mounted) {
                            await EasyLoading.showError(
                                AppLocalizations.of(context)!.translate(
                                        'selected_course_session_task_submitted_error1') ??
                                    'Error submitting task');
                          }
                        }

                        if (context.mounted) Navigator.of(context).pop();
                      }
                    } else {
                      EasyLoading.show(
                          status: AppLocalizations.of(context)!.translate(
                                  'selected_course_session_submit_task_dialog_submit_loading1') ??
                              'Submitting Task...');

                      final taskSubmission =
                          await api.uploadSessionTaskSubmission(
                              widget.courseId,
                              userId!,
                              widget.sessionNumber,
                              textEditingController.text,
                              taskFile);

                      if (taskSubmission) {
                        setState(() {
                          taskSubmitted = true;
                        });
                        isUpdated = await api.updateUserSessionsProgress(
                            widget.courseId,
                            FirebaseAuth.instance.currentUser!.uid,
                            widget.sessionNumber,
                            widget.sessionNumber == widget.sessions
                                ? true
                                : false);
                        if (context.mounted) {
                          if (isUpdated) {
                            if (widget.sessionNumber == widget.sessions) {
                              EasyLoading.showSuccess(
                                  AppLocalizations.of(context)!.translate(
                                          'selected_course_session_submit_task_dialog_course_completed1') ??
                                      'Course completed successfully');
                            } else {
                              EasyLoading.showSuccess(
                                  AppLocalizations.of(context)!.translate(
                                          'selected_course_session_submit_task_dialog_submit_success1') ??
                                      'Task submitted successfully');
                            }
                          } else {
                            EasyLoading.showError(AppLocalizations.of(context)!
                                    .translate(
                                        'selected_course_session_submit_task_dialog_submit_error1') ??
                                'Error updating task submission status.');
                          }
                        } else {
                          if (context.mounted) {
                            EasyLoading.showError(AppLocalizations.of(context)!
                                    .translate(
                                        'selected_course_session_submit_task_dialog_submit_error1') ??
                                'Error submitting task');
                          }
                        }
                      }
                      EasyLoading.dismiss();
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.translate(
                      'selected_course_session_submit_task_dialog_submit_button1') ??
                  'Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);

    if (kDebugMode) debugPrint(result.message);
  }
}
