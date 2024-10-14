import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/course/selected_course_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/course/expandable_text_widget.dart';
import 'package:neurossistant/src/pages/course/selected_course_psychologist_evaluation.dart';
import 'package:neurossistant/src/pages/course/selected_course_psychologist_test.dart';
import 'package:neurossistant/src/pages/course/selected_course_session.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';

class SelectedCoursePsychologistPage extends StatefulWidget {
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

  const SelectedCoursePsychologistPage({
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
  }) : super(key: key);

  @override
  State<SelectedCoursePsychologistPage> createState() =>
      _SelectedCoursePsychologistPageState();
}

class _SelectedCoursePsychologistPageState
    extends State<SelectedCoursePsychologistPage> {
  bool isDarkMode = Get.isDarkMode;
  bool? isUserRegistered;
  final SelectedCourseApi api = SelectedCourseApi();
  final userId = FirebaseAuth.instance.currentUser?.uid ?? "NOT-LOGIN";

  @override
  void initState() {
    super.initState();
  }

  Future<bool?> fetchUserIsRegistered() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      isUserRegistered = await api.isUserRegistered(widget.courseId, user.uid);
      if (isUserRegistered != null) return isUserRegistered!;
    }
    return null;
  }

  Future<UserProgress> fetchUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final progress = await api.fetchUserProgress(widget.courseId, user.uid);
      if (progress != null) {
        return progress;
      }
    }
    return UserProgress(
      isPreTestDone: false,
      isSessionsDone: false,
      isPostTestDone: false,
      isEvaluated: false,
    );
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
          // 'Testing',
          AppLocalizations.of(context)!.translate('selected_course_title1') ??
              'Course',
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<bool?>(
              future: fetchUserIsRegistered(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final data = snapshot.data;
                  debugPrint(data.toString());

                  if (snapshot.data != null && data!) {
                    return Column(
                      children: [
                        Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : Colors.white,
                          elevation: 4,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: SelectableText(
                                    locale == 'en'
                                        ? widget.titleEn
                                        : widget.titleId,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: SelectableText.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                                .translate(
                                                    'selected_course_authored_by1') ??
                                            'Authored by ',
                                        style:
                                            DefaultTextStyle.of(context).style,
                                      ),
                                      TextSpan(
                                        text: widget.psychologist +
                                            (widget.psychologistId == userId
                                                ? " (${AppLocalizations.of(context)!.translate('you') ?? 'You'})"
                                                : ""),
                                        style: DefaultTextStyle.of(context)
                                            .style
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    // $durations ${(AppLocalizations.of(context)!.translate('course_hour1') ?? 'hour') + (durations > 1 && locale == 'en' ? 's' : '')} | $sessions ${(AppLocalizations.of(context)!.translate('course_session1') ?? 'session') + (sessions > 1 && locale == 'en' ? 's' : '')}
                                    const Icon(Icons.timer),
                                    Text(
                                        ' ${widget.durations} ${(AppLocalizations.of(context)!.translate('course_hour1') ?? 'Hour') + (widget.durations > 1 && locale == 'en' ? 's' : '')} '),
                                    const VerticalDivider(),
                                    const Icon(Icons.calendar_today),
                                    Text(
                                        ' ${widget.sessions} ${(AppLocalizations.of(context)!.translate('course_session1') ?? 'session') + (widget.sessions > 1 && locale == 'en' ? 's' : '')} '),
                                  ],
                                ),
                                trailing: Chip(
                                  label: SelectableText(widget.tag),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : Colors.white,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ExpandableTextWidget(
                              titleText: AppLocalizations.of(context)!
                                      .translate('author_welcome_title') ??
                                  'Welcome to Your Course Page!',
                              spacingText: ' ',
                              bodyText: AppLocalizations.of(context)!
                                      .translate('author_welcome_body') ??
                                  'Here you can review the pre-test, sessions content and post-test. You could evaluate the Parents\' tests & session submissions by opening Evaluations tile.',
                              titleStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                              spacingStyle: const TextStyle(fontSize: 6),
                              bodyStyle: const TextStyle(fontSize: 16),
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
                        ListTile(
                          leading: const Icon(Icons.book, color: Colors.blue),
                          title: const Text('Pre-test',
                              style: TextStyle(fontSize: 18.0)),
                          trailing: const Icon(Icons.open_in_new,
                              color: Colors.lightBlue),
                          onTap: () {
                            // Navigate to Pre-test Page
                            if (isUserRegistered != null && isUserRegistered!) {
                              Get.to(
                                () => SelectedCoursePsychologistTestPage(
                                    isPreTest: true,
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
                            } else {
                              Get.snackbar(
                                  'Error',
                                  AppLocalizations.of(context)!.translate(
                                          'selected_course_pretest_error_relog1') ??
                                      'Please relog your account.');
                            }
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
                        ListTile(
                          leading: const Icon(Icons.play_circle_fill,
                              color: Colors.green),
                          title: Text(
                              AppLocalizations.of(context)!
                                      .translate('selected_course_sessions1') ??
                                  'Sessions',
                              style: const TextStyle(fontSize: 18.0)),
                          trailing: const Icon(Icons.open_in_new,
                              color: Colors.green),
                          onTap: () {
                            Get.to(
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
                        ListTile(
                          leading: const Icon(Icons.book, color: Colors.red),
                          title: const Text('Post-test',
                              style: TextStyle(fontSize: 18.0)),
                          trailing:
                              const Icon(Icons.open_in_new, color: Colors.red),
                          onTap: () {
                            Get.to(
                              () => SelectedCoursePsychologistTestPage(
                                  isPreTest: false,
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
                        ListTile(
                          leading:
                              const Icon(Icons.feedback, color: Colors.amber),
                          title: Text(
                              AppLocalizations.of(context)!.translate(
                                      'selected_course_evaluations_title1') ??
                                  'Evaluations',
                              style: const TextStyle(fontSize: 18.0)),
                          trailing: const Icon(Icons.open_in_new,
                              color: Colors.amber),

                          // Container(
                          //   width: 24,
                          //   height: 24,
                          //   decoration: BoxDecoration(
                          //     color: Colors.amber,
                          //     borderRadius:
                          //         BorderRadius.circular(12), // Makes it rounded
                          //   ),
                          //   child: Center(
                          //     child: Text(
                          //       1.toString(), // Assuming submissionsCount is an int variable
                          //       style: const TextStyle(
                          //           color: Colors.black, fontSize: 14),
                          //     ),
                          //   ),
                          // ),
                          onTap: () {
                            Get.to(() =>
                                SelectedCoursePsychologistEvaluationPage(
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
                                    descriptionId: widget.descriptionId));
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
                        const SizedBox(height: 25),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: widget.imageUrl.contains("http") ||
                                  widget.imageUrl.contains("https")
                              ? FadeInImage.assetNetwork(
                                  image: widget.imageUrl,
                                  placeholder:
                                      'assets/images/placeholder_loading.gif',
                                  fit: BoxFit.contain,
                                )
                              : SvgPicture.asset(widget.imageUrl),
                        ),
                        Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : Colors.white,
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.book),
                            title: Text(locale == 'en'
                                ? widget.titleEn
                                : widget.titleId),
                            subtitle: Text(
                                '${AppLocalizations.of(context)!.translate('selected_course_session_by1') ?? 'By'} ${widget.psychologist}'),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : Colors.white,
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.timer),
                            title: Text(AppLocalizations.of(context)!.translate(
                                    'selected_course_session_durations1') ??
                                'Durations'),
                            subtitle: Text(
                                '${widget.durations} ${(AppLocalizations.of(context)!.translate('course_hour1') ?? 'hour') + (widget.durations > 1 && locale == 'en' ? 's' : '')}'),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : Colors.white,
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(AppLocalizations.of(context)!
                                    .translate('selected_course_sessions1') ??
                                'Sessions'),
                            subtitle: Text(
                                '${widget.sessions} ${(AppLocalizations.of(context)!.translate('course_session1') ?? 'session') + (widget.sessions > 1 && locale == 'en' ? 's' : '')}'),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : Colors.white,
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.label),
                            title: Text(AppLocalizations.of(context)!
                                    .translate('selected_course_session_nd1') ??
                                'Neurodivergence'),
                            subtitle: Text(widget.tag),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : Colors.white,
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(AppLocalizations.of(context)!.translate(
                                    'selected_course_session_description1') ??
                                'Description'),
                            subtitle: Text(locale == 'en'
                                ? widget.descriptionEn
                                : widget.descriptionId),
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? ThemeClass().darkRounded
                                    : ThemeClass().lightPrimaryColor,
                          ),
                          onPressed: () async {
                            EasyLoading.show(
                                status: AppLocalizations.of(context)!.translate(
                                        'selected_course_session_registering1') ??
                                    'Registering...');
                            final isRegistered = await api.registerUser(
                                widget.courseId,
                                FirebaseAuth.instance.currentUser!.uid);
                            EasyLoading.dismiss();
                            if (isRegistered != null && isRegistered) {
                              setState(() {
                                isUserRegistered = true;
                              });
                              if (context.mounted) {
                                Get.snackbar(
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_success') ??
                                        'Success',
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_registered1') ??
                                        'Registered for this course.');
                              }
                            } else {
                              if (context.mounted) {
                                Get.snackbar(
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_failed') ??
                                        'Failed',
                                    AppLocalizations.of(context)!.translate(
                                            'selected_course_session_failed_message1') ??
                                        'Failed to register for this course.');
                              }
                            }
                          },
                          child: Text(AppLocalizations.of(context)!
                                  .translate('register_to_manage') ??
                              'Register to Manage'),
                        ),
                      ],
                    );
                  }
                }
              }),
        ),
      ),
    );
  }
}