import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/course/selected_course.dart';
import 'package:neurossistant/src/pages/course/selected_course_specific_session.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:neurossistant/src/db/course/selected_course_session_api.dart';

class SelectedCourseSessionPage extends StatefulWidget {
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

  const SelectedCourseSessionPage({
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
  State<SelectedCourseSessionPage> createState() =>
      _SelectedCourseSessionPageState();
}

class _SelectedCourseSessionPageState extends State<SelectedCourseSessionPage> {
  bool isDarkMode = Get.isDarkMode;
  final SelectedCourseSessionApi api = SelectedCourseSessionApi();
  late Future<SelectedCoursesData?> sessionsFuture;
  late Future<Map<String, dynamic>?> sessionsCompletionFuture;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'NOT-LOGIN';

  @override
  void initState() {
    super.initState();
    sessionsFuture = api.fetchSessions(widget.courseId);
    sessionsCompletionFuture = api.getUserSessionsProgress(
        widget.courseId, FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    final combinedFuture = Future.wait([
      sessionsFuture,
      sessionsCompletionFuture,
    ]);

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : ThemeClass().lightPrimaryColor,
        title: Text(
          AppLocalizations.of(context)!
                  .translate('selected_course_session_title1') ??
              'Sessions',
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
          if (!didPop) {
            if (userId == widget.psychologistId) {
              Get.back();
            } else {
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
                    descriptionId: widget.descriptionId),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<dynamic>>(
            future: combinedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData ||
                  snapshot.data![0].sessions.isEmpty) {
                return const Center(child: Text('No sessions available'));
              } else {
                final sessions = snapshot.data![0].sessions;
                final sessionsCompletion =
                    snapshot.data![1] as Map<String, dynamic>;
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
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ),
                          ),
                          ListTile(
                            title: SelectableText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.translate(
                                            'selected_course_authored_by1') ??
                                        'Authored by ',
                                    style: DefaultTextStyle.of(context).style,
                                  ),
                                  TextSpan(
                                    text: widget.psychologist +
                                        (widget.psychologistId == userId
                                            ? " (${AppLocalizations.of(context)!.translate('you') ?? 'You'})"
                                            : ""),
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(
                                    Icons.timer), // replace with your time icon
                                Text(
                                    ' ${widget.durations} ${(AppLocalizations.of(context)!.translate('course_hour1') ?? 'Hour') + (widget.durations > 1 && locale == 'en' ? 's' : '')}'),
                                const VerticalDivider(),
                                const Icon(Icons
                                    .calendar_today), // replace with your session icon
                                Text(
                                    ' ${widget.sessions} ${(AppLocalizations.of(context)!.translate('course_session1') ?? 'session') + (widget.sessions > 1 && locale == 'en' ? 's' : '')}'),
                              ],
                            ),
                            trailing: Chip(
                              label: SelectableText(widget.tag),
                            ),
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return ListTile(
                            subtitle: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 16,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[500]
                                        : Colors.blueGrey),
                                const SizedBox(width: 4),
                                Text(
                                  "${sessions[index].duration} ${(AppLocalizations.of(context)!.translate('course_hour1') ?? 'Hour') + (sessions[index].duration > 1 && locale == 'en' ? 's' : '')}",
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[500]
                                          : Colors.blueGrey),
                                ),
                              ],
                            ),
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blueAccent,
                              child: Text('${session.sessionNumber}'),
                            ),
                            title: Text((locale == 'en'
                                    ? session.sessionTitle['en']
                                    : session.sessionTitle['id']) ??
                                'Session ${session.sessionNumber}'),
                            trailing: Icon(Icons.check_circle,
                                color: sessionsCompletion.containsKey(
                                            'session${index + 1}') &&
                                        sessionsCompletion[
                                            'session${index + 1}']
                                    ? Colors.green
                                    : Colors.grey),
                            onTap: () {
                              // Check if the previous session is completed
                              // If the index is 0 (meaning the first session or session.sessionNumber == 1), let it pass
                              // If the previous session is not completed, show a message and return
                              if (userId != widget.psychologistId &&
                                  (index != 0 &&
                                      (!sessionsCompletion
                                              .containsKey('session$index') ||
                                          !sessionsCompletion[
                                              'session$index']))) {
                                EasyLoading.showInfo(AppLocalizations.of(
                                            context)!
                                        .translate(
                                            'complete_previous_session') ??
                                    'Please complete the previous session first.');
                                return;
                              }
                              Get.off(
                                () => SelectedCourseSpecificSessionPage(
                                  courseId: widget.courseId,
                                  titleEn: widget.titleEn,
                                  titleId: widget.titleId,
                                  psychologist: widget.psychologist,
                                  durations: widget.durations,
                                  sessions: widget.sessions,
                                  tag: widget.tag,
                                  imageUrl: widget.imageUrl,
                                  dateTime: widget.dateTime,
                                  popularity: widget.popularity,
                                  psychologistId: widget.psychologistId,
                                  descriptionEn: widget.descriptionEn,
                                  descriptionId: widget.descriptionId,
                                  sessionNumber: session.sessionNumber,
                                  isTaskSubmitted: sessionsCompletion
                                          .containsKey('session${index + 1}') &&
                                      sessionsCompletion['session${index + 1}'],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
