// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:ofc_learn_v2/api/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../comman/design_course_app_theme.dart';

class CourseInfoScreen extends StatefulWidget {
  // bool isLoading = true;

  @override
  _CourseInfoScreenState createState() => _CourseInfoScreenState();
}

class _CourseInfoScreenState extends State<CourseInfoScreen>
    with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.5;
  double opacity3 = 0.0;

  bool isLoading = false;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    super.initState();
    setState(() {});
  }

  Future<void> setData() async {
    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    SingleCourse course = tempSingleCourse[0];

    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String course_excerpt = course.course_excerpt!.replaceAll(exp, '');
    return Container(
      color: DesignCourseAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: Image(
                            image: NetworkImage(
                              "${course.course_featured_image_link}",
                            ),
                            width: 300,
                            height: 180,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: (MediaQuery.of(context).size.width / 1.2) - 24.0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: DesignCourseAppTheme.nearlyWhite,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32.0),
                              topRight: Radius.circular(32.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color:
                                    DesignCourseAppTheme.grey.withOpacity(0.2),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: SingleChildScrollView(
                            child: Container(
                              constraints: BoxConstraints(
                                  minHeight: infoHeight,
                                  maxHeight: tempHeight > infoHeight
                                      ? tempHeight
                                      : infoHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 32.0, left: 18, right: 18),
                                    child: Text(
                                      '${course.course_name}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        letterSpacing: 0.50,
                                        color: Color(0xff073278),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 8,
                                        top: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          " ${course.course_date}",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w200,
                                            fontSize: 18,
                                            letterSpacing: 0.27,
                                            color: Color(0xff073278),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // AnimatedOpacity(
                                  //   duration: const Duration(milliseconds: 500),
                                  //   opacity: opacity1,
                                  // child:
                                  Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Row(
                                      children: <Widget>[
                                        // Expanded(
                                        //   flex: 1,
                                        //   child: getTimeBoxUI('1', 'Module'),
                                        // ),
                                        Expanded(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            elevation: 50,
                                            shadowColor: Colors.white,
                                            color: Colors.white,
                                            child: Container(
                                              height: 80,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                      child: AutoSizeText(
                                                    "1",
                                                    style: TextStyle(
                                                      color: Color(0xff073278),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    minFontSize: 15,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                                  Center(
                                                      child: AutoSizeText(
                                                    "Module",
                                                    style: TextStyle(
                                                      color: Color(0xff073278),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    minFontSize: 15,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              elevation: 50,
                                              shadowColor: Colors.white,
                                              color: Colors.white,
                                              child: Container(
                                                height: 80,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                        child: AutoSizeText(
                                                      "5",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      minFontSize: 15,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                    Center(
                                                        child: AutoSizeText(
                                                      "Courses",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      minFontSize: 15,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))
                                                  ],
                                                ),
                                              )),
                                        ),

                                        Expanded(
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              elevation: 50,
                                              shadowColor: Colors.white,
                                              color: Colors.white,
                                              child: Container(
                                                height: 80,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                        child: AutoSizeText(
                                                      "1",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      minFontSize: 15,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                    Center(
                                                        child: AutoSizeText(
                                                      "Certificate",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      minFontSize: 15,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ),
                                  Expanded(
                                    child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      opacity: opacity2,
                                      child: Container(
                                        width: double.infinity,
                                        child: Card(
                                          color: Color.fromARGB(
                                              255, 244, 241, 241),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              course_excerpt,
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                letterSpacing: 0.8,
                                                color:
                                                    DesignCourseAppTheme.grey,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: opacity3,
                                    child: GestureDetector(
                                      onTap: () {
                                        joinCourse(context, course.id);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, bottom: 16, right: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(top: 20),
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Color(0xff66C23D),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(16.0),
                                                  ),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                        color:
                                                            Color(0xff66C23D),
                                                        offset: const Offset(
                                                            1.1, 1.1),
                                                        blurRadius: 10.0),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Join Course',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                      letterSpacing: 0.0,
                                                      color:
                                                          DesignCourseAppTheme
                                                              .nearlyWhite,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: SizedBox(
                        width: AppBar().preferredSize.height,
                        height: AppBar().preferredSize.height,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                                AppBar().preferredSize.height),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: DesignCourseAppTheme.nearlyBlack,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget getTimeBoxUI(String text1, String txt2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: DesignCourseAppTheme.nearlyWhite,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: DesignCourseAppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Color(0xff073278),
                ),
              ),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Color(0xff073278),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/////////// Join Course Api////////
  List<JoinCourseResponse> tempJoinCourse = [];

  Future<void> joinCourse(BuildContext context, course_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('isUserId');

    var url = baseUrl +
        ApiEndPoints().joinCourse +
        "&user_id=$userId&course_id=$course_id";
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<JoinCourseResponse> joinCourseResponse = [];
      joinCourseResponse
          .add(JoinCourseResponse.fromjson(jsonDecode(response.body)));

      JoinCourseResponse joinResponse = joinCourseResponse[0];

      await customDialog(context,
          message: joinResponse.message ?? "-",
          title: joinResponse.error_code!);

      Navigator.pop(context);
    }
  }
}

/////////// Single Course Details Api////////
List<SingleCourse> singleCourse = [];
List<SingleCourse> tempSingleCourse = [];

Future<void> singleCourseDetail(BuildContext context, id) async {
  List<SingleCourseDetailResponse>? singleCourseDetailResponse;

  var url = baseUrl + ApiEndPoints().singleCourseDetail + "&course_id=$id";
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<SingleCourseDetailResponse> singleCourseDetailResponse = [];
    List<SingleCourse> singleCourse = [];
    singleCourseDetailResponse
        .add(SingleCourseDetailResponse.fromjson(jsonDecode(response.body)));
    SingleCourseDetailResponse courseDetailRes = singleCourseDetailResponse[0];
    if (courseDetailRes.status == true && courseDetailRes.error_code == "0") {
      if (courseDetailRes.singleCourse != null) {
        var data = courseDetailRes.singleCourse;
        for (var e in data!) {
          singleCourse.add(e);
        }

        tempSingleCourse = singleCourse;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseInfoScreen(),
          ),
        );
      }
    }
  }
}

class SingleCourseDetailResponse {
  bool? status;
  String? error_code;
  List<SingleCourse>? singleCourse;

  SingleCourseDetailResponse({
    this.status,
    this.error_code,
    this.singleCourse,
  });

  SingleCourseDetailResponse.fromjson(Map<String, dynamic> json) {
    singleCourse = <SingleCourse>[];
    status = json['status'];
    error_code = json['error_code'];

    singleCourse =
        (json['data'] as List).map((e) => SingleCourse.fromjson(e)).toList();
  }
}

class SingleCourse {
  String? id;
  String? display_name;
  String? course_date;
  String? course_title;
  String? course_excerpt;
  String? course_name;
  String? course_type;
  String? course_status;
  String? course_content;
  String? course_featured_image_link;
  String? course_link;
  String? course_lesson_link;

  SingleCourse({
    this.id,
    this.display_name,
    this.course_date,
    this.course_title,
    this.course_excerpt,
    this.course_name,
    this.course_type,
    this.course_status,
    this.course_content,
    this.course_featured_image_link,
    this.course_link,
    this.course_lesson_link,
  });

  SingleCourse.fromjson(Map<String, dynamic> json) {
    display_name = json['display_name'];
    course_date = json['course_date'];
    course_title = json['course_title'];
    course_excerpt = json['course_excerpt'];
    course_name = json['course_name'];
    course_type = json['course_type'];
    course_status = json['course_status'];
    course_content = json['course_content'];
    course_featured_image_link = json['course_featured_image_link'];
    course_link = json['course_link'];
    course_lesson_link = json['course_lesson_link'];
  }
}

// Join Group API
class JoinCourseResponse {
  bool? status;
  String? error_code;
  String? message;

  JoinCourseResponse({
    this.status,
    this.error_code,
    this.message,
  });

  JoinCourseResponse.fromjson(Map<String, dynamic> json) {
    status = json['status'];
    error_code = json['error_code'];
    message = json['message'];
  }
}
