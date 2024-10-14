import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/course/selected_course_api.dart';
import 'package:neurossistant/src/db/course/selected_course_test_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/course/selected_course.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';

class SelectedCourseTestPage extends StatefulWidget {
  final bool isPreTest;
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

  const SelectedCourseTestPage({
    Key? key,
    required this.isPreTest,
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
  }) : super(key: key);

  @override
  State<SelectedCourseTestPage> createState() => _SelectedCourseTestPageState();
}

class _SelectedCourseTestPageState extends State<SelectedCourseTestPage> {
  bool isDarkMode = Get.isDarkMode;
  bool? isUserRegistered;
  final SelectedCourseApi api = SelectedCourseApi();
  bool isDialogOpen = false;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  List<TestQuestion> questions = [];
  Future? initDataFuture;
  List<int> correctAnswersIndices = [];
  List<int> incorrectAnswersIndices = [];
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'NOT-LOGIN';

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initDataFuture = fetchTest();
  }

  Future<void> fetchTest() async {
    SelectedCourseTestApi api = SelectedCourseTestApi();
    Test? test = widget.isPreTest
        ? await api.fetchPreTest(widget.courseId)
        : await api.fetchPostTest(widget.courseId);

    if (test != null) {
      setState(() {
        questions = test.questions;
      });
    }
  }

  void handleAnswer(int questionIndex) {
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].correctAnswerIndex == questions[i].userAnswerIndex) {
        correctAnswers++;
        correctAnswersIndices.add(i);
      } else if (questions[i].userAnswerIndex != -1) {
        incorrectAnswers++;
        incorrectAnswersIndices.add(i);
      }
    }

    if (questionIndex < questions.length - 1 ||
        correctAnswersIndices.length + incorrectAnswersIndices.length !=
            questions.length) {
      Get.snackbar(
          AppLocalizations.of(context)!
                  .translate('selected_course_test_incomplete1') ??
              'Incomplete',
          AppLocalizations.of(context)!
                  .translate('selected_course_test_incomplete_message1') ??
              'You have not completed the test yet!');
      correctAnswers = 0;
      incorrectAnswers = 0;
      correctAnswersIndices = [];
      incorrectAnswersIndices = [];
      EasyLoading.dismiss();
    } else {
      saveTestResult();
      Get.snackbar(
          AppLocalizations.of(context)!
                  .translate('selected_course_test_complete1') ??
              'Completed',
          AppLocalizations.of(context)!
                  .translate('selected_course_test_complete_message1') ??
              'You have completed the test!');

      Get.off(
        () => SelectedCoursePage(
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
          descriptionId: widget.descriptionId,
        ),
      );
    }
  }

  Future<void> saveTestResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final result = {
        widget.isPreTest ? 'preTestResult' : 'postTestResult': {
          'completedAt': DateTime.now(),
          'correct': correctAnswers,
          'incorrect': incorrectAnswers,
          'questionsTotal': currentQuestionIndex + 1,
          'correctAnswersIndices': correctAnswersIndices,
          'incorrectAnswersIndices': incorrectAnswersIndices,
        }
      };
      await firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('users')
          .doc(user.uid)
          .set(result, SetOptions(merge: true));

      await firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('users')
          .doc(user.uid)
          .set({
        'progress': {
          widget.isPreTest ? 'isPreTestDone' : 'isPostTestDone': true,
        }
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : ThemeClass().lightPrimaryColor,
        title: Text(
          widget.isPreTest ? 'Pre-Test' : 'Post-Test',
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
          LanguageSwitcher(
            onPressed: localizationChange,
            textColor: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
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
                    placeholder: 'assets/images/placeholder_loading.gif',
                    fit: BoxFit.cover,
                    width: 45,
                    height: 45,
                  ),
                );
              } else {
                return Icon(
                  Icons.account_circle,
                  color: isDarkMode
                      ? const Color.fromARGB(255, 211, 227, 253)
                      : Colors.white,
                );
              }
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!isDialogOpen && !didPop) {
            isDialogOpen = true;
            AwesomeDialog(
                dismissOnTouchOutside: false,
                context: context,
                keyboardAware: true,
                dismissOnBackKeyPress: false,
                dialogType: DialogType.error,
                animType: AnimType.scale,
                transitionAnimationDuration: const Duration(milliseconds: 200),
                btnOkText:
                    AppLocalizations.of(context)!.translate('yes') ?? "Yes",
                btnCancelText:
                    AppLocalizations.of(context)!.translate('no') ?? "No",
                title:
                    '${AppLocalizations.of(context)!.translate('cancel') ?? 'Cancel'} ${widget.isPreTest ? 'Pre-Test' : 'Post-Test'}',
                desc:
                    '${AppLocalizations.of(context)!.translate('selected_course_test_cancel_message1') ?? 'Are you sure you want to cancel the'} ${widget.isPreTest ? 'Pre-Test' : 'Post-Test'}?',
                btnOkOnPress: () {
                  DismissType.btnOk;
                  isDialogOpen = false;
                  Get.back();
                },
                btnCancelOnPress: () {
                  DismissType.btnCancel;
                  isDialogOpen = false;
                }).show();
          }
        },
        child: Stack(
          children: [
            FutureBuilder(
              future: initDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching test'));
                } else if (questions.isEmpty) {
                  return const Center(child: Text('No questions found'));
                } else {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? ThemeClass().darkRounded
                                    : Colors.white70,
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)!.translate('selected_course_test_question1') ?? 'Question'} ${currentQuestionIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.blueGrey,
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
                                  Text(
                                    locale == 'en'
                                        ? questions[currentQuestionIndex]
                                            .questionEn
                                        : questions[currentQuestionIndex]
                                            .questionId,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
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
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: questions[currentQuestionIndex]
                                .choicesEn
                                .length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                title: Text(
                                  locale == 'en'
                                      ? questions[currentQuestionIndex]
                                          .choicesEn[i]
                                      : questions[currentQuestionIndex]
                                          .choicesId[i],
                                ),
                                leading: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: questions[currentQuestionIndex]
                                                .userAnswerIndex ==
                                            i
                                        ? Colors.blue
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    questions[currentQuestionIndex]
                                        .userAnswerIndex = i;
                                  });
                                },
                              );
                            },
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
                          const SizedBox(
                            height: 10,
                          ),
                          if (currentQuestionIndex == questions.length - 1)
                            ElevatedButton(
                              onPressed: () {
                                EasyLoading.show(
                                    status: AppLocalizations.of(context)!
                                            .translate('please_wait') ??
                                        'Please Wait...');
                                handleAnswer(currentQuestionIndex);
                                EasyLoading.dismiss();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? ThemeClass().darkRounded
                                    : ThemeClass().lightPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                        .translate('done') ??
                                    'Done',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            if (currentQuestionIndex > 0)
              Positioned(
                left: 25,
                bottom: 25,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex--;
                    });
                  },
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            if (currentQuestionIndex < questions.length - 1)
              Positioned(
                right: 25,
                bottom: 25,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex++;
                    });
                  },
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
