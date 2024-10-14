import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/course/selected_course_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/course/selected_course_psychologist_specific_evaluation.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:intl/intl.dart';

class SelectedCoursePsychologistEvaluationPage extends StatefulWidget {
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

  const SelectedCoursePsychologistEvaluationPage(
      {super.key,
      required this.courseId,
      required this.titleEn,
      required this.titleId,
      required this.psychologist,
      required this.durations,
      required this.sessions,
      required this.tag,
      required this.imageUrl,
      required this.dateTime,
      required this.popularity,
      required this.psychologistId,
      required this.descriptionEn,
      required this.descriptionId});

  @override
  State<SelectedCoursePsychologistEvaluationPage> createState() =>
      _SelectedCoursePsychologistEvaluationPageState();
}

class _SelectedCoursePsychologistEvaluationPageState
    extends State<SelectedCoursePsychologistEvaluationPage> {
  @override
  Widget build(BuildContext context) {
    final SelectedCourseApi api = SelectedCourseApi();
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'NOT-LOGIN';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('evaluation_title') ??
              'Evaluations',
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 211, 227, 253)
                      : Colors.white,
                ); // show a default icon if the user is not logged in or doesn't have a profile picture
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: api.fetchUserTestAndTaskResults(widget.courseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)!
                          .translate('no_registered_users') ??
                      'No registered users found.'));
            }

            List<Map<String, dynamic>> users = snapshot.data ?? [];

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                if (user['userId'] != null && user['userId'] == userId) {
                  return const SizedBox.shrink();
                }
                var evaluations = user['evaluations'] ?? {};
                var sessionsEvaluatedTotal =
                    (evaluations['sessionsEvaluations'] ?? []).length;
                var progress = user['progress'] ?? {};
                var sessionsCompletion = user['sessionsCompletion'] ?? {};

                String userName = user['userName'] ?? 'Unknown User';
                String registeredAt = user['registeredAt'] != null
                    ? DateFormat('yyyy-MM-dd').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            user['registeredAt'].seconds * 1000))
                    : 'Unknown';

                return userCard(
                  userName: userName,
                  isAllEvaluated: evaluations['isAllEvaluated'] ?? false,
                  preTestEvaluated: evaluations['preTestEvaluated'] ?? false,
                  sessionsEvaluated: evaluations['sessionsEvaluated'] ?? false,
                  postTestEvaluated: evaluations['postTestEvaluated'] ?? false,
                  sessionsEvaluatedTotal: sessionsEvaluatedTotal ?? 0,
                  registeredAt: registeredAt,
                  isPreTestDone: progress['isPreTestDone'] ?? false,
                  isSessionsDone: progress['isSessionsDone'] ?? false,
                  sessionsDone: sessionsCompletion.entries
                      .where((entry) =>
                          entry.key.toString().startsWith('session') &&
                          entry.value == true)
                      .length,
                  isPostTestDone: progress['isPostTestDone'] ?? false,
                  onTap: () {
                    var isPreTestDone = progress['isPreTestDone'] ?? false;
                    var sessionsDone = sessionsCompletion.entries
                        .where((entry) =>
                            entry.key.toString().startsWith('session') &&
                            entry.value == true)
                        .length;
                    var isPostTestDone = progress['isPostTestDone'] ?? false;

                    if (!isPreTestDone &&
                        sessionsDone == 0 &&
                        !isPostTestDone) {
                      _showUserNoProgress(context);
                    } else {
                      Get.to(() =>
                          SelectedCoursePsychologistSpecificEvaluationPage(
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
                            userCourseData: user,
                          ));
                    }
                  },
                  context: context,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget userCard({
    required String userName,
    required String registeredAt,
    required bool isPreTestDone,
    required bool isSessionsDone,
    required int sessionsDone,
    required int sessionsEvaluatedTotal,
    required bool isPostTestDone,
    required bool isAllEvaluated,
    required bool preTestEvaluated,
    required bool sessionsEvaluated,
    required bool postTestEvaluated,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : Colors.white,
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(
                        isAllEvaluated
                            ? Icons.feedback
                            : Icons.feedback_outlined,
                        size: 16,
                        color: isAllEvaluated
                            ? Colors.green
                            : preTestEvaluated ||
                                    sessionsEvaluated ||
                                    postTestEvaluated
                                ? Colors.lightGreen
                                : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(isAllEvaluated
                          ? AppLocalizations.of(context)!
                                  .translate('evaluated') ??
                              'Evaluated'
                          : preTestEvaluated ||
                                  sessionsEvaluated ||
                                  postTestEvaluated
                              ? AppLocalizations.of(context)!
                                      .translate('part_evaluated') ??
                                  'Part Evaluated'
                              : AppLocalizations.of(context)!
                                      .translate('not_evaluated') ??
                                  'Not Evaluated'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)!.translate('registered_at') ?? 'Registered at'}: $registeredAt',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context)!.translate('user_progress') ?? 'User Progress'}:',
                style: const TextStyle(fontSize: 14),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  statusIndicator(
                    isDone: isPreTestDone,
                    label: 'Pre-Test',
                    context: context,
                  ),
                  statusIndicator(
                    isDone: isSessionsDone,
                    label:
                        '${AppLocalizations.of(context)!.translate('selected_course_sessions1') ?? 'Sessions'} ($sessionsDone)',
                    context: context,
                  ),
                  statusIndicator(
                    isDone: isPostTestDone,
                    label: 'Post-Test',
                    context: context,
                  ),
                ],
              ),
              Text(
                '\n${AppLocalizations.of(context)!.translate('evaluation_progress') ?? 'Evaluation Progress'}:',
                style: const TextStyle(fontSize: 14),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  statusIndicator(
                    isDone: preTestEvaluated,
                    label: 'Pre-Test',
                    context: context,
                  ),
                  statusIndicator(
                    isDone: sessionsEvaluated,
                    label:
                        '${AppLocalizations.of(context)!.translate('selected_course_sessions1') ?? 'Sessions'} ($sessionsEvaluatedTotal/$sessionsDone)',
                    context: context,
                  ),
                  statusIndicator(
                    isDone: postTestEvaluated,
                    label: 'Post-Test',
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statusIndicator({
    required bool isDone,
    required String label,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.check_circle_outline,
          color: isDone ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  void _showUserNoProgress(BuildContext context) {
    AwesomeDialog(
      dismissOnTouchOutside: true,
      context: context,
      keyboardAware: true,
      dismissOnBackKeyPress: false,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      transitionAnimationDuration: const Duration(milliseconds: 200),
      btnOkText: "OK",
      btnOkOnPress: () {},
      title:
          AppLocalizations.of(context)!.translate('user_no_progress_title') ??
              "No Progress",
      desc: AppLocalizations.of(context)!.translate('user_no_progress_body') ??
          "This user has not yet completed any progress.",
    ).show();
  }
}
