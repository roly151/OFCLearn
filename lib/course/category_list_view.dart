import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/course/course_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({Key? key, this.callBack}) : super(key: key);

  final Function()? callBack;
  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    print("callBack");
    getPreviusCourseList(context);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  /////////// Previous Event List API /////////////
  List<CoursesListData> coursesListData = [];
  List<CoursesListData> tempCoursesListData = [];

  Future<void> getPreviusCourseList(
    BuildContext context,
  ) async {
    var url = baseUrl + ApiEndPoints().previusCourseList;
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');
    var response = await http.get(Uri.parse("$url&user_id=$user_id"));

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      List<CoursesListDataResponse> coursesListDataResponse = [];
      coursesListDataResponse
          .add(CoursesListDataResponse.fromJson(jsonDecode(response.body)));
      CoursesListDataResponse coursePreResponse = coursesListDataResponse[0];

      if (coursePreResponse.status == true &&
          coursePreResponse.error_code == "0") {
        if (coursePreResponse.coursesListData != null) {
          var data = coursePreResponse.coursesListData;
          List<CoursesListData> coursesListData = [];

          for (var e in data!) {
            coursesListData.add(e);
          }
          setState(() {
            tempCoursesListData = coursesListData;
          });
          print("eeeee");
          print(tempCoursesListData);
        }
      }
    }
  }

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Container(
          height: 135,
          width: double.infinity,
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : FutureBuilder<bool>(
                    future: getData(),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 0, bottom: 0, right: 16, left: 16),
                          itemCount: tempCoursesListData.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            final int count = tempCoursesListData.length;
                            final Animation<double> animation =
                                Tween<double>(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                        parent: animationController!,
                                        curve: Interval(
                                            (1 / count) * index, 1.0,
                                            curve: Curves.fastOutSlowIn)));
                            animationController?.forward();

                            return CategoryView(
                              courseList: tempCoursesListData[index],
                              animation: animation,
                              animationController: animationController,
                              // callback: widget.callBack,
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ));
  }
}

class CategoryView extends StatelessWidget {
  CategoryView({
    Key? key,
    this.courseList,
    this.animationController,
    this.animation,
    // this.callback
  }) : super(key: key);

  // final VoidCallback? callback;
  final courseList;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    // print()
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
            opacity: animation!,
            child: Transform(
              transform: Matrix4.translationValues(
                  100 * (1.0 - animation!.value), 0.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                // onTap: callback,
                child: GestureDetector(
                  onTap: () async {
                    await singleCourseDetail(context, courseList!.id);
                  },
                  child: SizedBox(
                    width: 280,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 48,
                              ),
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    //set border radius more than 50% of height and width to make circle
                                  ),
                                  shadowColor: Colors.white,
                                  color: Colors.white,
                                  elevation: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      // color: HexColor('#F8FAFB'),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0)),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 48 + 24.0,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              // color: HexColor('#F8FAFB'),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(16.0)),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: AutoSizeText(
                                                    "${courseList.course_title}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      letterSpacing: 0.27,
                                                      color: Color(0xff073278),
                                                    ),
                                                    minFontSize: 10,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Text(
                                                      '0%',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 15,
                                                        letterSpacing: 0.27,
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'complete',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 15,
                                                        letterSpacing: 0.27,
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    AutoSizeText(
                                                      'Last Activity',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 8,
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                      minFontSize: 8,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(width: 5),
                                                    AutoSizeText(
                                                      " ${courseList.course_date}",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 8,
                                                        color:
                                                            Color(0xff073278),
                                                      ),
                                                      minFontSize: 8,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 24, bottom: 24, left: 16),
                            child: Row(
                              children: <Widget>[
                                ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16.0)),
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Image(
                                        image: NetworkImage(courseList
                                            .course_featured_image_link
                                            .toString()),
                                        fit: BoxFit.fill,
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }
}

class CoursesListDataResponse {
  bool? status;
  String? error_code;
  String? message;
  List<CoursesListData>? coursesListData;

  CoursesListDataResponse({
    this.status,
    this.error_code,
    this.message,
    this.coursesListData,
  });

  CoursesListDataResponse.fromJson(Map<String, dynamic> json) {
    coursesListData = <CoursesListData>[];
    status = json['status'];
    error_code = json['error_code'];
    message = json['message'];
    json['data'].forEach((v) {
      coursesListData!.add(CoursesListData.fromjson(v));
    });
  }
}

/////////// Previous Event List API Model/////////////
class CoursesListData {
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

  CoursesListData({
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

  CoursesListData.fromjson(Map<String, dynamic> json) {
    id = json['ID'];
    display_name = json['display_name'];
    course_date = json['course_date'];
    course_title = json['course_title'];
    course_excerpt = json['course_excerpt'];
    course_name = json['course_name'];
    course_type = json['course_type'];
    course_status = json['course_status'];
    course_content = json['course_content'];
    course_featured_image_link = json["course_featured_image_link"];
    course_link = json['course_link'];
    course_lesson_link = json['course_lesson_link'];
  }
}
