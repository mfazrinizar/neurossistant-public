import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/course/course_api.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/pages/course/selected_course.dart';
import 'package:neurossistant/src/pages/course/selected_course_psychologist.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key}) : super(key: key);
  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  int _selectedChoiceIndex = 0;
  String _selectedTag = "";
  bool isClicked = false;
  final searchController = TextEditingController();
  late Future<List<CoursesData>> coursesFuture;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'NOT-LOGIN';

  final List<Map<String, dynamic>> tagFilters = [
    {
      "tag": "ADHD",
      "bgColor": const Color.fromARGB(255, 255, 228, 241),
      "bgText": const Color.fromARGB(255, 254, 242, 255),
      "textColor": const Color.fromARGB(255, 255, 128, 189),
      "image": 'assets/images/adhdTagPink.svg',
    },
    {
      "tag": "ASD",
      "bgColor": const Color.fromARGB(255, 254, 239, 220),
      "bgText": const Color.fromARGB(255, 255, 255, 236),
      "textColor": const Color.fromARGB(255, 251, 177, 90),
      "image": 'assets/images/asdTagOrange.svg',
    },
    {
      "tag": "Dyslexia",
      "bgColor": const Color.fromARGB(255, 206, 236, 254),
      "bgText": const Color.fromARGB(255, 241, 249, 253),
      "textColor": const Color.fromARGB(255, 61, 92, 255),
      "image": 'assets/images/dyslexiaTagBlue.svg',
    },
    {
      "tag": "DCD",
      "bgColor": const Color.fromARGB(255, 239, 224, 255),
      "bgText": const Color.fromARGB(255, 255, 243, 255),
      "textColor": const Color.fromARGB(255, 144, 101, 190),
      "image": 'assets/images/dcdTagPurple.svg',
    },
  ];

  // List<Map<String, dynamic>> courses = [
  //   {
  //     "id": "3dsjni93",
  //     "tag": "ASD",
  //     "psychologist": "Dr. Raihan, M.Psi.",
  //     "psychologistId": "ikifjenf",
  //     "titleEn": "Parenting for Autistic Children",
  //     "titleId": "Parenting untuk Anak-anak Autis",
  //     "duration": 16,
  //     "session": 7,
  //     "imageUrl": "assets/images/asdTagOrange.svg",
  //     "popularity": 5,
  //     "dateTime": DateTime.now(),
  //   },
  //   {
  //     "id": "3dsjni93fd",
  //     "tag": "Dyslexia",
  //     "psychologist": "Dr. Raihan, M.Psi.",
  //     "psychologistId": "ikifjenf",
  //     "titleEn": "Parenting for Dyslexic Children",
  //     "titleId": "Parenting untuk Anak-anak Disleksia",
  //     "duration": 16,
  //     "session": 1,
  //     "imageUrl": "assets/images/asdTagOrange.svg",
  //     "popularity": 2,
  //     "dateTime": DateTime.now(),
  //   },
  //   {
  //     "id": "3dsjni93fd",
  //     "tag": "Others",
  //     "psychologist": "Dr. Raihan, M.Psi.",
  //     "psychologistId": "ikifjenf",
  //     "titleEn": "Understanding Neurodiversity",
  //     "titleId": "Memahami Neurodiversitas",
  //     "duration": 16,
  //     "session": 1,
  //     "imageUrl": "assets/images/asdTagOrange.svg",
  //     "popularity": 3,
  //     "dateTime": DateTime.now(),
  //   }
  // ];

  List<CoursesData>? courses;
  List<CoursesData> foundCourses = [];

  @override
  void initState() {
    super.initState();
    coursesFuture = CourseApi.fetchCourses();
    coursesFuture.then((value) {
      setState(() {
        courses = value;
        foundCourses = value;
      });
    });
  }

  void filterCoursesByChoiceAndTag(List<CoursesData>? courses) {
    if (courses != null) {
      List<CoursesData> filteredCourses = List.from(courses);

      // If _selectedChoiceIndex is 1, sort courses by popularity

      if (_selectedChoiceIndex == 0) {
        // nothing
      } else if (_selectedChoiceIndex == 1) {
        filteredCourses.sort((a, b) => b.popularity.compareTo(a.popularity));
      } else if (_selectedChoiceIndex == 2) {
        filteredCourses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      }

      // If _selectedTag is not empty, filter courses by tag
      if (_selectedTag.isNotEmpty) {
        filteredCourses = filteredCourses.where((course) {
          return course.tag.toString().toLowerCase() ==
              _selectedTag.toLowerCase();
        }).toList();
      }

      setState(() {
        foundCourses = filteredCourses;
      });
    }
  }

  void filterCourses(String query, List<CoursesData>? courses) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    if (courses != null) {
      List<CoursesData> filteredCourses = courses.where((course) {
        return (locale == 'en'
            ? course.titleEn.toLowerCase().contains(query.toLowerCase())
            : course.titleId.toLowerCase().contains(query.toLowerCase()) ||
                    _selectedTag != ""
                ? course.tag.toLowerCase().contains(_selectedTag.toLowerCase())
                : course.tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      setState(() {
        foundCourses = filteredCourses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : ThemeClass().lightPrimaryColor,
        title: Text(
          AppLocalizations.of(context)!.translate('course_title1') ?? 'Courses',
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 211, 227, 253)
              : Colors.white,
          onPressed: () {
            Get.offAll(
              () => const HomePage(
                indexFromPrevious: 0,
              ),
            );
          },
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
            setState(() {});
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
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeClass().darkRounded
                    : ThemeClass().lightPrimaryColor),
            child: Stack(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 211, 227, 253)
                              : Colors.black,
                        ),
                        controller: searchController,
                        onChanged: (value) => filterCourses(value, courses),
                        keyboardType: TextInputType.visiblePassword,
                        scrollPadding: const EdgeInsets.all(100),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromARGB(255, 3, 21, 37)
                                  : const Color.fromARGB(255, 240, 240, 245),
                          prefixIcon: Icon(
                            Icons.search,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 211, 227, 253)
                                    : Colors.black,
                          ),
                          hintText: AppLocalizations.of(context)!
                                  .translate('course_search1') ??
                              'Search for Courses...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 211, 227, 253)
                                  : Colors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color.fromARGB(255, 211, 227, 253)
                                    : Colors.blueAccent,
                                width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            scrollDirection: axisDirectionToAxis(AxisDirection.right),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: tagFilters.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          if (index == 0) const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedTag == tagFilters[index]['tag']) {
                                  _selectedTag = "";
                                } else {
                                  _selectedTag = tagFilters[index]['tag'];
                                }
                                filterCoursesByChoiceAndTag(courses);
                              });
                            },
                            child: AnimatedContainer(
                              // alignment: Alignment.bottomRight,
                              duration: const Duration(seconds: 1),
                              constraints: const BoxConstraints(
                                  minWidth: 180,
                                  maxWidth: 180,
                                  minHeight: 100,
                                  maxHeight: 100),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                color: tagFilters[index]["bgColor"],
                                boxShadow:
                                    _selectedTag == tagFilters[index]['tag']
                                        ? [
                                            const BoxShadow(
                                                color: Colors.lightBlue,
                                                blurRadius: 10,
                                                spreadRadius: 5.0)
                                          ]
                                        : [],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    // height: 25,
                                    width: 25,
                                  ),
                                  Row(
                                    children: [
                                      Stack(
                                        children: [
                                          SizedBox(
                                            height: 90,
                                            width: 90,
                                            child: SvgPicture.asset(
                                                tagFilters[index]["image"]),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 95,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    height: 60,
                                                  ),
                                                  Container(
                                                    alignment: Alignment
                                                        .center, // Center the text inside the container
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(20),
                                                      ),
                                                      color: tagFilters[index]
                                                          ["bgText"],
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Text(
                                                      tagFilters[index]["tag"],
                                                      style: TextStyle(
                                                        color: tagFilters[index]
                                                            ["textColor"],
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      textAlign: TextAlign
                                                          .center, // Center the text
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: axisDirectionToAxis(AxisDirection.right),
                child: Row(
                  children: [
                    buildChoiceChip(
                        AppLocalizations.of(context)!
                                .translate('course_all1') ??
                            'All',
                        0),
                    const SizedBox(width: 8),
                    buildChoiceChip(
                        AppLocalizations.of(context)!
                                .translate('course_popular1') ??
                            'Popular',
                        1),
                    const SizedBox(width: 8),
                    buildChoiceChip(
                        AppLocalizations.of(context)!
                                .translate('course_new1') ??
                            'New',
                        2),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          FutureBuilder<List<CoursesData>>(
            future: coursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      CircularProgressIndicator(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                      const SizedBox(height: 20.0),
                      Text(
                        AppLocalizations.of(context)!
                                .translate('course_loading1') ??
                            'Loading...',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred. Please try again later.'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No courses found.'),
                );
              } else {
                if (courses == null) {
                  courses = snapshot.data;
                  foundCourses = snapshot.data!;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: ListView.builder(
                        itemCount: foundCourses.length,
                        itemBuilder: (context, index) {
                          return courseCard(
                            titleEn: foundCourses[index].titleEn,
                            titleId: foundCourses[index].titleId,
                            psychologist: foundCourses[index].psychologist,
                            psychologistId: foundCourses[index].psychologistId,
                            durations: foundCourses[index].durations,
                            sessions: foundCourses[index].sessions,
                            popularity: foundCourses[index].popularity,
                            dateTime: foundCourses[index].dateTime,
                            tag: foundCourses[index].tag,
                            imageUrl: foundCourses[index].imageUrl,
                            courseId: foundCourses[index].courseId,
                            descriptionEn: foundCourses[index].descriptionEn,
                            descriptionId: foundCourses[index].descriptionId,
                          );
                        }),

                    // ListView(
                    //   children: [
                    //     courseCard(
                    //       title: courses[0]['titleEn'],
                    //       psychologist: courses[0]['psychologist'],
                    //       duration: courses[0]['duration'],
                    //       session: courses[0]['session'],
                    //       tag: courses[0]['tag'],
                    //       imageUrl: courses[0]['imageUrl'],
                    //       courseId: courses[0]['id'],
                    //     ),
                    //     courseCard(
                    //       title: courses[1]['titleEn'],
                    //       psychologist: courses[1]['psychologist'],
                    //       duration: courses[1]['duration'],
                    //       session: courses[1]['session'],
                    //       tag: courses[1]['tag'],
                    //       imageUrl: courses[1]['imageUrl'],
                    //       courseId: courses[1]['id'],
                    //     ),
                    //     courseCard(
                    //       title: courses[2]['titleEn'],
                    //       psychologist: courses[2]['psychologist'],
                    //       duration: courses[2]['duration'],
                    //       session: courses[2]['session'],
                    //       tag: courses[2]['tag'],
                    //       imageUrl: courses[2]['imageUrl'],
                    //       courseId: courses[2]['id'],
                    //     ),
                    //   ],
                    // ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget courseCard({
    required String titleEn,
    required String titleId,
    required String psychologist,
    required int durations,
    required int sessions,
    required String tag,
    required String imageUrl,
    required String courseId,
    required int popularity,
    required DateTime dateTime,
    required String psychologistId,
    required String descriptionEn,
    required String descriptionId,
  }) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';

    return InkWell(
      onTap: () {
        if (userId == psychologistId) {
          Get.to(
            () => SelectedCoursePsychologistPage(
              titleEn: titleEn,
              titleId: titleId,
              psychologist: psychologist,
              durations: durations,
              sessions: sessions,
              tag: tag,
              imageUrl: imageUrl,
              courseId: courseId,
              popularity: popularity,
              dateTime: dateTime,
              psychologistId: psychologistId,
              descriptionEn: descriptionEn,
              descriptionId: descriptionId,
            ),
          );
        } else {
          Get.to(
            () => SelectedCoursePage(
              titleEn: titleEn,
              titleId: titleId,
              psychologist: psychologist,
              durations: durations,
              sessions: sessions,
              tag: tag,
              imageUrl: imageUrl,
              courseId: courseId,
              popularity: popularity,
              dateTime: dateTime,
              psychologistId: psychologistId,
              descriptionEn: descriptionEn,
              descriptionId: descriptionId,
            ),
          );
        }
      },
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : Colors.white,
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: imageUrl.contains("http") || imageUrl.contains("https")
                    ? FadeInImage.assetNetwork(
                        image: imageUrl,
                        placeholder: 'assets/images/placeholder_loading.gif',
                        fit: BoxFit.contain,
                      )
                    : SvgPicture.asset(imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(locale == 'en' ? titleEn : titleId,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                        psychologist +
                            (psychologistId == userId
                                ? " (${AppLocalizations.of(context)!.translate('you') ?? 'You'})"
                                : ""),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.blueGrey)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                                "$durations ${(AppLocalizations.of(context)!.translate('course_hour1') ?? 'hour') + (durations > 1 && locale == 'en' ? 's' : '')} | $sessions ${(AppLocalizations.of(context)!.translate('course_session1') ?? 'session') + (sessions > 1 && locale == 'en' ? 's' : '')}",
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[500]
                                        : Colors.blueGrey)),
                          ],
                        ),
                        Text(tag,
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.blueGrey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChoiceChip(String label, int index) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedChoiceIndex == index,
      onSelected: (bool selected) {
        setState(() {
          _selectedChoiceIndex = index;
          filterCoursesByChoiceAndTag(courses);
        });
      },
      selectedColor: ThemeClass().lightPrimaryColor,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.blueGrey
          : Colors.grey[200],
      labelStyle: TextStyle(
          color: _selectedChoiceIndex == index
              ? Colors.white
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: const BorderSide(
            color: Colors.transparent,
          )),
    );
  }
}
