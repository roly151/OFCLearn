// ignore_for_file: unused_local_variable, non_constant_identifier_names
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/groups/course_info_screen.dart';
import 'package:ofc_learn_v2/groups/models/category.dart';
import 'package:ofc_learn_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../comman/design_course_app_theme.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:http/http.dart' as http;

class Groups extends StatefulWidget {
  @override
  _Groups createState() => _Groups();
}

class _Groups extends State<Groups> with TickerProviderStateMixin {
  int? grouptype = 1;

  // int _currentIndex = 1;
  var isLoading = false;
  int page = 1;
  var searchQuery = '';
  final scrollController = ScrollController();

  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    scrollController.addListener(scrollPagination);
    setState(() {
      getGroupList(context, page, grouptype);
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  void onChoiceChipValueChanged(int newValue) {
    setState(() {
      grouptype = newValue;
    });
    tempGroupCourse = [];
    getGroupList(context, 1, newValue);
  }

  void scrollPagination() async {
    if (isLoading) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      page = page + 1;
      await getGroupList(context, page, grouptype);
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ListGetGroup> groupCourse = [];
  List<ListGetGroup> tempGroupCourse = [];

  Future<void> getGroupList(BuildContext context, pages, type) async {
    List<GroupListResponse>? groupListResponse;    
    List<ListGetGroup> groupCourse = [];

    isLoading = true;
    
    final url = baseUrl + ApiEndPoints().getGroupList;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');
 
    var response;
    if (type == 1) {      
      response = await http.get(Uri.parse(
          "$url&user_id=&search=$searchQuery&page=$pages"));
    } else if (type == 2) {         
      response =
          await http.get(Uri.parse("$url&user_id=$user_id&search=$searchQuery&page=$pages"));
    }

    isLoading = false;

    if (response.statusCode == 200) {      
      List<GroupListResponse> groupListResponse = [];
      List<ListGetGroup> listGetGroup = [];

      groupListResponse
          .add(GroupListResponse.fromjson(jsonDecode(response.body)));
      GroupListResponse groupRes = groupListResponse[0];

      if (groupRes.status == "true" && groupRes.error_code == "0") {
        if (groupRes.listGetGroup != null) {
          var data = groupRes.listGetGroup;
          
          for (var e in data!) {
            groupCourse.add(e);
          }
          setState(() {
            tempGroupCourse = groupCourse;
          });
        }
      } else {}
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
                controller: scrollController,
                child: Column(
                  children: [
                    getAppBarUI(),
                    StickyHeader(
                      header: Container(
                        child: getSearchBarUI(context),
                      ),
                      content: Container(
                        child: Column(
                          children: <Widget>[
                            getPopularCourseUI(),
                          ],
                        ),
                      ),
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

  Widget PopularCourseListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return GridView.builder(
                physics: ScrollPhysics(parent: null),
                shrinkWrap: true,
                itemCount: tempGroupCourse.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 32.0,
                  mainAxisSpacing: 32.0,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  if (index < tempGroupCourse.length) {
                    final int count = tempGroupCourse.length;
                    final Animation<double> animation =
                        Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animationController!,
                        curve: Interval((1 / count) * index, 1.0,
                            curve: Curves.fastOutSlowIn),
                      ),
                    );

                    // ListGetGroup getGroup = tempGroupCourse[index];

                    animationController?.forward();
                    final ListGetGroup = tempGroupCourse[index];

                    return AnimatedBuilder(
                      animation: animationController!,
                      builder: (BuildContext context, Widget? child) {
                        return FadeTransition(
                            opacity: animation,
                            child: Transform(
                              transform: Matrix4.translationValues(
                                  0.0, 50 * (1.0 - animation.value), 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                // onTap: callback,
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseInfoScreen(ListGetGroup.id),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                      height: 280,
                                      child: Stack(
                                          alignment:
                                              AlignmentDirectional.bottomCenter,
                                          children: <Widget>[
                                            Container(
                                              child: Column(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            HexColor('#F8FAFB'),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    20.0)),
                                                      ),
                                                      child: Column(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Card(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                //set border radius more than 50% of height and width to make circle
                                                              ),
                                                              elevation: 20,
                                                              child: Container(
                                                                child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              8,
                                                                          left:
                                                                              16,
                                                                          right:
                                                                              16),
                                                                      child:
                                                                          AutoSizeText(
                                                                        "${ListGetGroup.title}",
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          // fontSize: 16,
                                                                          letterSpacing:
                                                                              0.27,
                                                                          color:
                                                                              Color(0xff073278),
                                                                        ),
                                                                        minFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16,
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            " ${ListGetGroup.status}",
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.w200,
                                                                              fontSize: 10,
                                                                              letterSpacing: 0.27,
                                                                              color: Color(0xff073278),
                                                                            ),
                                                                          ),
                                                                          AutoSizeText(
                                                                            " ${ListGetGroup.time}",
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            minFontSize:
                                                                                5,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 10,
                                                                              // fontWeight: FontWeight.w500,
                                                                              height: 1.1,
                                                                              color: Color(0xff073278),
                                                                            ),
                                                                          )
                                                                        ],
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
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 24,
                                                          right: 16,
                                                          left: 16),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  16.0)),
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                            color: Color(
                                                                    0xff073278)
                                                                .withOpacity(
                                                                    0.2),
                                                            offset:
                                                                const Offset(
                                                                    0.0, 0.0),
                                                            blurRadius: 6.0),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  16.0)),
                                                      child: AspectRatio(
                                                        aspectRatio: 1.28,
                                                        child: Image(
                                                          image: NetworkImage(
                                                              // "https://sample-videos.com/img/Sample-png-image-100kb.png",
                                                              // 'https://readyforyourreview.com/SeanDouglas12/wp-content/uploads/2021/08/OFC-Learn-Gradient-Filled-Horizontal-1536x842.png',
                                                              ListGetGroup.image_link
                                                                  .toString()),
                                                          width: 300,
                                                          height: 180,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ])),
                                ),
                              ),
                            ));
                        // );
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
                });
          }
        },
      ),
    );
  }

  Widget getPopularCourseUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Flexible(
          // child:
          PopularCourseListView(
              // callBack: () {
              //   // moveTo();
              // },
              ),
          // )
        ],
      ),
    );
  }

  // void moveTo() {
  //   Navigator.push<dynamic>(
  //     context,
  //     MaterialPageRoute<dynamic>(
  //       builder: (BuildContext context) => CourseInfoScreen('Groups'),
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
                                getGroupList(context, page, grouptype);
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
                            labelText: searchQuery.isNotEmpty && searchQuery.length < 3
                                    ? 'Please enter minimum 3 characters'
                                    : 'Search for group',
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
      padding: const EdgeInsets.only(top: 8, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Groups',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.27,
                      color: Color(0xff073278),
                    ),
                  ),
                ),
                StatefulBuilder(builder: (context, setState) {
                  return Row(
                    children: [
                      ChoiceChip(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        label: Text(
                          'All Groups',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.27,
                            color: grouptype == 1
                                ? Color.fromRGBO(255, 255, 255, 1)
                                : Color(0xff073278),
                          ),
                        ),
                        selected: grouptype == 1,
                        selectedColor: Color(0xff073278),
                        backgroundColor: Colors.transparent,
                        onSelected: (bool selected) {                         
                          if (selected) {
                            onChoiceChipValueChanged(1);
                          }
                        },
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ChoiceChip(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        label: Text(
                          'My Groups',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.27,
                            color:
                                grouptype == 2 ? Colors.white : Color(0xff073278),
                          ),
                        ),
                        selected: grouptype == 2,
                        selectedColor: Color(0xff073278),
                        backgroundColor: Colors.transparent,
                        onSelected: (bool selected) {
                          if (selected) {
                            onChoiceChipValueChanged(2);
                          }
                        },
                      ),
                    ],
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
