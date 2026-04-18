import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/activity/addpost.dart';
import 'package:ofc_learn_v2/comman/comment.dart';
import 'package:ofc_learn_v2/activity/models/category.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:ofc_learn_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../comman/design_course_app_theme.dart';
import 'package:http/http.dart' as http;

class DesignCourseHomeScreen extends StatefulWidget {
  @override
  _DesignCourseHomeScreenState createState() => _DesignCourseHomeScreenState();
}

class _DesignCourseHomeScreenState extends State<DesignCourseHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  final scrollController = ScrollController();

  int page = 1;
  var isLoading = false;
  var commentType = "A";
  var _isLiked = false;
  var searchQuery = '';
  int? choiceChipValue = 1;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    scrollController.addListener(scrollPagination);
    activityPostList(context, page);
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1));
    return true;
  }

  ///////////// Activity API Calling ////////////
  List<ActivityPostList> activityList = [];
  List<ActivityPostList> tempActivityList = [];

  Future<void> activityPostList(BuildContext context, page) async {
    isLoading = true;
    final url = baseUrl + ApiEndPoints().activityPostList;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('isUserId');

    String scopeVal = '';
    switch (choiceChipValue) {
      case 1:
        scopeVal = '';
        break;
      case 2:
        scopeVal = 'favorites';
        break;
      case 3:
        scopeVal = 'friends';
        break;
      case 4:
        scopeVal = 'groups';
        break;
      case 5:
        scopeVal = 'mentions';
        break;
      case 6:
        scopeVal = 'following';
        break;
      default:
        scopeVal = '';
    }

    var response = await http.get(Uri.parse(
        "$url&user_id=$userId&page=$page&search=$searchQuery&scope=$scopeVal"));

    isLoading = false;

    if (response.statusCode == 200) {
      List<ActivityPostListResponse> activityPostListResponse = [];

      activityPostListResponse
          .add(ActivityPostListResponse.fromJson(jsonDecode(response.body)));

      ActivityPostListResponse userResponse = activityPostListResponse[0];

      if (userResponse.status == "true" && userResponse.error_code == "0") {
        if (userResponse.activityPostList != null) {
          var data = userResponse.activityPostList;
          List<ActivityPostList> activityList = [];

          for (var e in data!) {
            activityList.add(e);
          }
          setState(() {
            tempActivityList = activityList;
          });

        }
      }
    } else {
      customDialog(context, message: "Data not found", title: 'Error');
    }
  }

  ////////// Call Activity API On Scroll //////////
  void scrollPagination() async {
    if (isLoading) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      page = page + 1;
      await activityPostList(context, page);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Pull Down Page Refresh
  Future<void> _pullDownRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      activityPostList(context, 1);
    });
  }

  void onChoiceChipValueChanged(int newValue) {
    setState(() {
      choiceChipValue = newValue;
    });
    tempActivityList = [];
    activityPostList(context, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignCourseAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _pullDownRefresh,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: SingleChildScrollView(
                controller: scrollController,
                child: Column(children: <Widget>[
                  getAppBarUI(),
                  StickyHeader(
                    header: Container(
                      child: getSearchBarUI(context),
                    ),
                    content: Container(
                      child: Column(children: <Widget>[
                        getCategoryUI(context),
                        getPopularCourseUI(),
                      ]),
                    ),
                  )
                ]),
              )),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget PopularCourseListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(parent: null),
              itemCount: tempActivityList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < tempActivityList.length) {
                  final int count = tempActivityList.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController?.forward();
                  final activityList = tempActivityList[index];

                  RegExp exp =
                      RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
                  String content = activityList.content!.replaceAll(exp, '');

                  return AnimatedBuilder(
                    animation: animationController!,
                    builder: (BuildContext context, Widget? child) {
                      return FadeTransition(
                        opacity: animation,
                        child: Transform(
                          transform: Matrix4.translationValues(
                              0.0, 50 * (0.5 - animation.value), 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            child: SizedBox(
                              child: Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: <Widget>[
                                  Container(
                                    child: Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(10),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                              ),
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundImage: NetworkImage(
                                                  "${activityList.author_image}",
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        "${activityList.user_name}",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xff073278)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  "${activityList.date_recorded}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff073278)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: double.infinity,
                                            // height: 150,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                Html(
                                                  data: content,
                                                ),
                                                activityList.image_link != null ? Image(                                               
                                                  image: NetworkImage(
                                                    "${activityList.image_link}",
                                                  ),
                                                  fit: BoxFit.fill,
                                                ) : Image(
                                                  image: AssetImage('assets/images/images.png'),
                                                  width: double.infinity,
                                                  height: 180,
                                                  fit: BoxFit.fill,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () async {                                                 
                                                  if (_isLiked) {
                                                    setState(() {
                                                      _isLiked = false;
                                                      activityLikePostList(
                                                        context,
                                                        activityList.id,
                                                      );
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _isLiked = true;
                                                      activityLikePostList(
                                                        context,
                                                        activityList.id,
                                                      );
                                                    });
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.favorite,
                                                  color:
                                                      activityList.like_c_user!
                                                          ? Colors.red
                                                          : Color(0xff073278),
                                                ),
                                                iconSize: 30.0,
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.comment_outlined,
                                                  size: 30,
                                                ),
                                                onPressed: () => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Postcomment(
                                                              activityList.id,
                                                              commentType),
                                                    ),
                                                  ),
                                                },
                                                color: Color(0xff073278),
                                              ),
                                              Text(
                                                "${activityList.total_comment}",
                                                style: TextStyle(
                                                  color: Color(0xff073278),
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 15),
                                                  child: Text(
                                                    "${activityList.like_count}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Color(0xff073278),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget getPopularCourseUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 18, right: 16),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PopularCourseListView(),
          ],
        ),
      ),
    );
  }

  // void moveTo() {
  //   Navigator.push<dynamic>(
  //     context,
  //     MaterialPageRoute<dynamic>(
  //       builder: (BuildContext context) => CourseInfoScreen(),
  //     ),
  //   );
  // }

  Widget getSearchBarUI(context) {
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
                                activityPostList(context, page);
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
                                    : 'Search for activity',
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
                    'All Updates',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 1
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 1,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {                   
                    setState(() {
                      onChoiceChipValueChanged(1);
                    });
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Likes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 2
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 2,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    setState(() {
                      onChoiceChipValueChanged(2);
                    });
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Connections',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 3
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 3,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    setState(() {
                     onChoiceChipValueChanged(3);
                    });
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Groups',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 4
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 4,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    setState(() {
                      onChoiceChipValueChanged(4);
                    });
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Mentions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 5
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 5,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    setState(() {
                      onChoiceChipValueChanged(5);
                    });
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                ChoiceChip(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  label: Text(
                    'Following',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: choiceChipValue == 6
                          ? Colors.white
                          : Color(0xff073278),
                    ),
                  ),
                  selected: choiceChipValue == 6,
                  selectedColor: Color(0xff073278),
                  backgroundColor: Colors.transparent,
                  onSelected: (bool selected) {
                    setState(
                      () {
                        onChoiceChipValueChanged(6);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Activity',
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
          Container(
            width: 45,
            height: 45,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Addpost("Activity"),
                  ),
                );
              },
              child: const Icon(
                Icons.edit_sharp,
              ),
              backgroundColor: Color(0xFF063278),
            ),
          )
        ],
      ),
    );
  }

  ///////// Like Count API Calling /////////////s
  activityLikePostList(BuildContext context, id) async {
    final url = baseUrl + ApiEndPoints().activityLikePostList;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('isUserId');

    var content = _isLiked == true ? "Unlike" : "Like";
    
    Map<String, String> params = {
      'activity_id': id.toString(),
      'content': content,
      'user_id': userId.toString(),
    };

    var response = await http.post(Uri.parse(url), body: params);

    if (response.statusCode == 200) {
      activityPostList(context, page);
      List<ActivityLikePostListResponse> activityLikePostListResponse = [];

      activityLikePostListResponse.add(
          ActivityLikePostListResponse.fromjson(jsonDecode(response.body)));

      ActivityLikePostListResponse activityLikePostListRes =
          activityLikePostListResponse[0];
    }
  }
}
