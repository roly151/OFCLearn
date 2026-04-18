// ignore_for_file: non_constant_identifier_names,

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/groups/course_info_screen.dart';
import 'package:ofc_learn_v2/comman/comment.dart';
import 'package:ofc_learn_v2/activity/home_design_course.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:ofc_learn_v2/groups/models/category.dart';
import 'package:ofc_learn_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Feed extends StatefulWidget {
  var group;
  Feed(this.group);
  @override
  State<Feed> createState() => _Feed();
}

var isLoading = false;
var _isLiked = false;
var searchQuery = '';
var postFieldValue = '';

///////////// GroupFeed API Calling /////////////

class _Feed extends State<Feed> {
  var commentType = "A";

  @override
  void initState() {
    super.initState();
    feedGroupGetList(context, widget.group);
  }

  List<FeedGetList> feedGetList = [];
  List<FeedGetList> tempFeedGetList = [];

  Future<void> feedGroupGetList(BuildContext context, group) async {
    List<FeedGetListResponse> feedGetListResponse;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');
    setState(() {
      isLoading = true;
    });

    var url = baseUrl +
        ApiEndPoints().feedGroupGetList +
        "&group_id=$group&user_id=$user_id&search=$searchQuery&type=f";

    var response = await http.get(Uri.parse(url));
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      List<FeedGetListResponse> feedGetListResponse = [];

      feedGetListResponse
          .add(FeedGetListResponse.fromJson(jsonDecode(response.body)));

      FeedGetListResponse userResponse = feedGetListResponse[0];

      if (userResponse.status == "true" && userResponse.error_code == "0") {
        if (userResponse.feedGetList != null) {
          List<FeedGetList> feedGetList = [];

          var data = userResponse.feedGetList;

          for (var e in data!) {
            feedGetList.add(e);
          }
          setState(() {
            tempFeedGetList = feedGetList;
          });
        }
      }
    } else {
      customDialog(context, message: "Data not found", title: 'Error');
    }
  }

  Future<void> PostFeed() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');

    var url = baseUrl +
        ApiEndPoints().add_feed_in_group +
        "&item_id=${widget.group}&user_id=$user_id&content=$postFieldValue";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await customDialog(context, message: "Feed is added successfully", title: 'Success');

      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => CourseInfoScreen(widget.group),
        ),
      );
    } else {
      await customDialog(context, message: "Faild to add feed", title: 'Error');
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
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
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage('assets/images/supportIcon.png'),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (text) {
                          setState(() {
                            postFieldValue = text;
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Write somthing here...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if(postFieldValue != ""){
                          PostFeed();
                        }
                      },
                      child: Text(
                        "Post",
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff66C23D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.93,
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor('#F8FAFB'),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                          height: 60,
                          child: Icon(
                            Icons.search,
                            // color: HexColor('#B9BABC')
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                  if (value.length >= 3 || value.isEmpty) {
                                    feedGroupGetList(context, widget.group);
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
                                labelText: searchQuery.isNotEmpty &&
                                        searchQuery.length < 3
                                    ? 'Please enter minimum 3 characters'
                                    : 'Search for group',
                                border: InputBorder.none,
                                helperStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  // color: HexColor('#B9BABC'),
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
        ),
        Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  children: <Widget>[
                    Container(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: ScrollPhysics(parent: null),
                          shrinkWrap: true,
                          itemCount: tempFeedGetList.length,
                          itemBuilder: (BuildContext context, int index) {
                            FeedGetList feedGetList = tempFeedGetList[index];

                            RegExp exp = RegExp(r"<[^>]*>",
                                multiLine: true, caseSensitive: true);
                            String content_text =
                                feedGetList.content!.replaceAll(exp, '');

                            bool _like_c_user = feedGetList.like_c_user == true;

                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                height: 300,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                          ),
                                          CircleAvatar(
                                            radius: 20,
                                            child: Image(
                                              image: NetworkImage(feedGetList
                                                  .image_link
                                                  .toString()),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "${feedGetList.user_name}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff073278)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              "${feedGetList.date_recorded}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff073278)),
                                            ),
                                          ),
                                        ]),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10, right: 10),
                                            child: AutoSizeText(
                                              "${content_text}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
                                                  color: Color(0xff073278)),
                                              minFontSize: 15,
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Row(children: [
                                      // IconButton(
                                      //   onPressed: () async {
                                          // setState(() {
                                          //   if (_isLiked) {
                                          //     _isLiked = false;
                                          //   } else {
                                          //     _isLiked = true;
                                          //   }
                                          //   activityLikePostList(
                                          //     context,
                                          //     _isLiked,
                                          //     feedGetList.id,
                                          //   );
                                          // });
                                      //   },
                                      //   icon: _like_c_user == true
                                      //       ? Icon(
                                      //           Icons.favorite,
                                      //           color: Colors.red,
                                      //         )
                                      //       : Icon(
                                      //           Icons.favorite,
                                      //           color: Color(0xff073278),
                                      //         ),
                                      //   iconSize: 30.0,
                                      // ),

                                    
                                      // IconButton(
                                      //     icon: const Icon(
                                      //       Icons.comment_outlined,
                                      //     ),
                                      //     onPressed: () => {
                                      //           Navigator.push(
                                      //             context,
                                      //             MaterialPageRoute(
                                      //               builder: (context) =>
                                      //                   Postcomment(
                                      //                       feedGetList.id,
                                      //                       commentType),
                                      //             ),
                                      //           ),
                                      //         },
                                      //     color: Color(0xff073278)),
                                      // Text(
                                      //   "${feedGetList.total_comment}",
                                      //   style: TextStyle(
                                      //     color: Color(0xff073278),
                                      //   ),
                                      // ),
                                    // ]),
                                    // Column(
                                    //   children: [
                                    //     Container(
                                    //         padding: const EdgeInsets.only(
                                    //             left: 15, right: 15),
                                    //         child: Align(
                                    //           alignment: Alignment.centerLeft,
                                    //           child: Text(
                                    //             "${feedGetList.like_count}",
                                    //             style: TextStyle(
                                    //               fontWeight: FontWeight.w500,
                                    //               fontSize: 12,
                                    //               color: Color(0xff073278),
                                    //             ),
                                    //             overflow: TextOverflow.ellipsis,
                                    //             maxLines: 1,
                                    //           ),
                                    //         ))
                                    //   ],
                                    // ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
