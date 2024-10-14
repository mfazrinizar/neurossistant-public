import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/course/selected_course_test_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';

class SelectedCoursePsychologistTestPage extends StatefulWidget {
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

  const SelectedCoursePsychologistTestPage({
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
  State<SelectedCoursePsychologistTestPage> createState() =>
      _SelectedCoursePsychologistTestPageState();
}

class _SelectedCoursePsychologistTestPageState
    extends State<SelectedCoursePsychologistTestPage> {
  bool isDarkMode = Get.isDarkMode;
  List<TestQuestion> questions = [];
  Future? initDataFuture;
  int currentQuestionIndex = 0;

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
      body: Stack(
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
                          color: Theme.of(context).brightness == Brightness.dark
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
                          itemCount:
                              questions[currentQuestionIndex].choicesEn.length,
                          itemBuilder: (context, i) {
                            bool isCorrectAnswer =
                                questions[currentQuestionIndex]
                                        .correctAnswerIndex ==
                                    i;
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
                                  color: isCorrectAnswer
                                      ? Colors.green
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
                          height: 85,
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
    );
  }
}
