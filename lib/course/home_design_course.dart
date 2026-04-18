import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/course/category_list_view.dart';
import 'package:ofc_learn_v2/course/course_info_screen.dart';
import 'package:ofc_learn_v2/course/models/category.dart';
// import 'package:ofc_learn_v2/course/popular_course_list_view.dart';
import 'package:ofc_learn_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../comman/design_course_app_theme.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:http/http.dart' as http;

class Course extends StatefulWidget {
  @override
  _Course createState() => _Course();
}

class _Course extends State<Course> with TickerProviderStateMixin {
  AnimationController? animationController;
  final scrollController = ScrollController();
  var isLoading = false;
  int page = 1;
  int? choiceChipValue = 323;
  var searchQuery = '';

  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    scrollController.addListener(scrollPagination);
    getCourseList(context, page, choiceChipValue);
    super.initState();
  }

  void onChoiceChipValueChanged(int newValue) {
    setState(() {
      choiceChipValue = newValue;
    });
    tempListCourse = [];
    getCourseList(context, 1, newValue);
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1));
    return true;
  }

  /////////////  Course  API  Calling  /////////////
  List<ListCourse> listCourse = [];
  List<ListCourse> tempListCourse = [];

  Future<void> getCourseList(BuildContext context, page, category) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('isUserId');

    isLoading = true;

    var url = baseUrl +
        ApiEndPoints().courseList +
        "&user_id=$userId&page=$page&category_id=$category&search=$searchQuery";
    var response = await http.get(Uri.parse(url));

    isLoading = false;

    if (response.statusCode == 200) {
      List<CourseListResponse> courseListResponse = [];
      courseListResponse
          .add(CourseListResponse.fromjson(jsonDecode(response.body)));
      CourseListResponse courseResponse = courseListResponse[0];
      if (courseResponse.status == true && courseResponse.error_code == "0") {
        if (courseResponse.listCourse != null) {
          var data = courseResponse.listCourse;
          List<ListCourse> listCourse = [];
          for (var e in data!) {
            listCourse.add(e);
          }

          setState(() {
            tempListCourse = listCourse;
          });
        }
      }
    }
  }

  void scrollPagination() async {
    if (isLoading) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      page = page + 1;
      await getCourseList(context, page, choiceChipValue);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignCourseAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    getAppBarUI(),
                    getSearchBarUI(),
                    getCategoryUI(context),
                    StickyHeader(
                      header: Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 16, right: 16),
                              child: Text(
                                'My Courses',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                  letterSpacing: 0.27,
                                  color: Color(0xff073278),
                                ),
                              ),
                            ),
                            CategoryListView(
                              callBack: () {
                                // moveTo();
                              },
                            ),
                          ],
                        ),
                      ),
                      content: getPopularCourseUI(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPopularCourseUI() {
    return Container(
      height: 500,
      child: Column(
        children: <Widget>[
          Flexible(
            // child: getPopularCourseUI(),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 18, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Explore Courses',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      letterSpacing: 0.27,
                      color: Color(0xff073278),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FutureBuilder<bool>(
                        future: getData(),
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          } else {
                            return GridView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                CategoryView(
                                  tempListCourse: tempListCourse,
                                  animationController: animationController,
                                  scrollController: scrollController,
                                  // callback: widget.callBack,
                                  isLoading: isLoading,
                                ),
                              ],
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 32.0,
                                crossAxisSpacing: 32.0,
                                childAspectRatio: 0.8,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void onScrolling() {
  //   getCourseList(context, page, choiceChipValue);
  // }

  Widget getCategoryUI(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Coaching',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 323
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 323,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    if (selected) {
                      onChoiceChipValueChanged(323);
                    }
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Goalkeeping',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 325
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 325,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    if (selected) {
                      onChoiceChipValueChanged(325);
                    }
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Officials',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 326
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 326,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    if (selected) {
                      onChoiceChipValueChanged(326);
                    }
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Psychological',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 324
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 324,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    if (selected) {
                      onChoiceChipValueChanged(324);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.90,
            height: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor('#F8FAFB'),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(13.0),
                    bottomLeft: Radius.circular(13.0),
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              if (value.length >= 3 || value.isEmpty) {
                                getCourseList(context, page, choiceChipValue);
                              }
                            });
                          },
                          style: TextStyle(
                            fontFamily: 'Hind',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xff073278),
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText:
                                searchQuery.isNotEmpty && searchQuery.length < 3
                                    ? 'Please enter minimum 3 characters'
                                    : 'Search for course',                          
                            border: InputBorder.none,
                            helperStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HexColor('#B9BABC'),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              color: searchQuery.isNotEmpty &&
                                      searchQuery.length < 3
                                  ? HexColor('#FF9494')
                                  : HexColor('#B9BABC'),                            
                            ),
                          ),
                          onEditingComplete: () {},
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(Icons.search, color: HexColor('#B9BABC')),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: SizedBox(),
          )
        ],
      ),
    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Courses',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.27,
                    color: Color(0xff073278),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryView extends StatefulWidget {
  const CategoryView(
      {Key? key,
      this.tempListCourse,
      this.animationController,
      this.animation,
      this.scrollController,
      // this.callback,
      this.isLoading})
      : super(key: key);

  // final VoidCallback? callback;
  final tempListCourse;
  final ScrollController? scrollController;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final isLoading;

  @override
  _CategoryView createState() => _CategoryView();
}

class _CategoryView extends State<CategoryView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      controller: widget.scrollController,
      itemCount: widget.isLoading
          ? widget.tempListCourse.length + 1
          : widget.tempListCourse.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 32.0,
        mainAxisSpacing: 32.0,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        if (index < widget.tempListCourse.length) {
          final int count = widget.tempListCourse.length;
          final Animation<double> animation =
              Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: widget.animationController!,
              curve: Interval((1 / count) * index, 1.0,
                  curve: Curves.fastOutSlowIn),
            ),
          );

          // ListGetGroup getGroup = tempGroupCourse[index];

          widget.animationController?.forward();
          final ListCourse = widget.tempListCourse[index];

          return AnimatedBuilder(
            animation: widget.animationController!,
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 50 * (1.0 - animation.value), 0.0),
                  child: InkWell(
                      splashColor: Colors.transparent,
                      // onTap: widget.callback,
                      child: GestureDetector(
                        onTap: () async {
                          await singleCourseDetail(context, ListCourse!.id);
                        },
                        child: SizedBox(
                          height: 280,
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: HexColor('#F8FAFB'),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(16.0)),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  //set border radius more than 50% of height and width to make circle
                                                ),
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 8,
                                                                left: 16,
                                                                right: 16),
                                                        child: AutoSizeText(                                                          
                                                          "${ListCourse!.post_title}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            letterSpacing: 0.27,
                                                            color: Color(
                                                                0xff073278),
                                                          ),
                                                          minFontSize: 10,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 16,
                                                          right: 16,
                                                        ),
                                                        child: AutoSizeText(
                                                          "${ListCourse!.post_author_name}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            letterSpacing: 0.27,
                                                            color: Color(
                                                                0xff073278),
                                                          ),
                                                          minFontSize: 8,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 48,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 48,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 24, right: 16, left: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0)),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Color(0xff073278)
                                                .withOpacity(0.2),
                                            offset: const Offset(0.0, 0.0),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0)),
                                      child: AspectRatio(
                                        aspectRatio: 1.28,
                                        child: Image(
                                          image: NetworkImage(
                                            "${ListCourse!.post_thumbnail_link}",
                                          ),
                                          width: 300,
                                          height: 180,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                ),
              );
            },
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
