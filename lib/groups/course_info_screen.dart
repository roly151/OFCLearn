// ignore_for_file: unnecessary_statements, non_constant_identifier_names, unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:ofc_learn_v2/groups/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:ofc_learn_v2/api/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './feed.dart';
import './discussions.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

// ignore: must_be_immutable
class CourseInfoScreen extends StatefulWidget {
  var group_id;

  CourseInfoScreen(this.group_id);

  @override
  _CourseInfoScreenState createState() => _CourseInfoScreenState();
}

class _CourseInfoScreenState extends State<CourseInfoScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 1;
  final ImagePicker _picker = ImagePicker();
  File? image;
  var isLoading = false;
  var isLoading1 = false;

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    singleGroupDetail(widget.group_id);
  }

  /////////// Single Group Details Api////////
  List<SingleGroupList> singleGroupList = [];
  List<SingleGroupList> tempSingleGroup = [];

  void singleGroupDetail(group_id) async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');

    var url = baseUrl +
        ApiEndPoints().getGroupDetails +
        "&group_id=$group_id&user_id=$user_id";

    var response = await http.get(Uri.parse(url));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      List<SingleGroupDetailResponse> singleGroupDetailResponse = [];
      List<SingleGroupList> singleGroupList = [];
      singleGroupDetailResponse
          .add(SingleGroupDetailResponse.fromjson(jsonDecode(response.body)));
      SingleGroupDetailResponse groupDetailRes = singleGroupDetailResponse[0];

      if (groupDetailRes.status == "true" && groupDetailRes.error_code == "0") {
        if (groupDetailRes.singleGroupList != null) {
          var data = groupDetailRes.singleGroupList;

          for (var e in data!) {
            singleGroupList.add(e);
          }
          setState(() {
            tempSingleGroup = singleGroupList;
          });
        }
      }
    }
  }

  ////// Api For Join Group ///////
  void joinGroup(BuildContext context, group_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt('isUserId');

    Map data = {
      'group_id': group_id,
      'user_id': id.toString(),
    };

    final url = baseUrl + ApiEndPoints().joinGroup;
    var response = await http.post(Uri.parse(url), body: data);

    if (response.statusCode == 200) {
      List<JoinGroupResponse> joinGroupResponse = [];
      joinGroupResponse
          .add(JoinGroupResponse.fromJson(jsonDecode(response.body)));
      JoinGroupResponse newjoinresponse = joinGroupResponse[0];

      if (newjoinresponse.status == "true") {
        await customDialog(
          context,
          message: newjoinresponse.message ?? "-",
          title: '${newjoinresponse.status == "true" ? "Success" : "Error"}',
        );
      }
      setState(() {
        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => CourseInfoScreen(group_id),
          ),
        );
      });
    } else {
      customDialog(context, message: "Data not found", title: 'Error');
    }
  }

  void groupUploadPriofile(BuildContext context, File? image, group_id) async {
    List<GroupPhotoResponse> groupPhotoResponse;

    var url = baseUrl + ApiEndPoints().changegroupimage;
    print("wwwwwwww");
    print(group_id);
    print(image);

    var stream = http.ByteStream(DelegatingStream.typed(image!.openRead()));

    var length = await image.length();
    setState(() {
      isLoading1 = true;
    });
    var uri = Uri.parse(url);

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile(
      'upload_cover_photo_api',
      stream,
      length,
      filename: basename(image.path),
    );

    request.files.add(multipartFile);
    request.fields['group_id'] = group_id.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      print(response);
      print(response.stream);

      setState(() {
        isLoading1 = false;
      });
      response.stream.transform(utf8.decoder).listen(
        (value) {
          groupPhotoResponse = <GroupPhotoResponse>[];

          groupPhotoResponse
              .add(GroupPhotoResponse.fromJson(jsonDecode(value)));

          GroupPhotoResponse groupPhotoRes = groupPhotoResponse[0];
         
          customDialog(context, message: groupPhotoRes.message.toString());
        
        },
      );
    } else {
      print('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Container(
                child: Scaffold(
                  backgroundColor: Color.fromARGB(255, 205, 203, 203),
                  appBar: AppBar(
                    backgroundColor: Color(0xFF063278),
                  ),
                  body: Stack(
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8, left: 8, right: 8),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tempSingleGroup.length,
                          itemBuilder: (BuildContext context, int index) {
                            SingleGroupList singleGroup =
                                tempSingleGroup[index];
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: <Widget>[
                                            isLoading1
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator())
                                                : image == null
                                                    ? Image(
                                                        image: NetworkImage(
                                                            // 'https://readyforyourreview.com/SeanDouglas12/wp-content/uploads/2021/08/OFC-Learn-Gradient-Filled-Horizontal-1536x842.png',
                                                            // "https://ofclearn.com/wp-content/uploads/buddypress/groups/4/cover-image/60da8dfc0044b-bp-cover-image.jpg",

                                                            singleGroup
                                                                .image_link
                                                                .toString()),
                                                        width: 350,
                                                        height: 180,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Image.file(
                                                        image!,
                                                        width: 350,
                                                        height: 180,
                                                        fit: BoxFit.fill,
                                                      ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "${singleGroup.title}",
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff073278),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  groupUploadPriofile(context,
                                                      image, singleGroup.id);
                                                },
                                                child: Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Color(0xff66C23D),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                        "${singleGroup.type}",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0XFFFFFFFF))),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "${singleGroup.content}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "${singleGroup.organizer} : ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                      letterSpacing: 0.20,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: NetworkImage(
                                                        "${singleGroup.organizer_image}"
                                                            .toString()),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  ElevatedButton.icon(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                      Icons.lock,
                                                      size: 24.0,
                                                    ),
                                                    label: Text(
                                                        "${singleGroup.status}"),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      singleGroup.have_in_group ==
                                                              "0"
                                                          ? joinGroup(context,
                                                              widget.group_id)
                                                          : null;
                                                    },
                                                    icon: singleGroup
                                                                .have_in_group ==
                                                            "0"
                                                        ? Icon(
                                                            Icons.add,
                                                            size: 24.0,
                                                          )
                                                        : Icon(
                                                            Icons.check,
                                                            size: 24.0,
                                                          ),
                                                    label: singleGroup
                                                                .have_in_group ==
                                                            "0"
                                                        ? Text('Join Group')
                                                        : Text('Member'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => onTappedBar(1),
                                        child: Text(
                                          'Feed',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ButtonStyle(),
                                      ),
                                      TextButton(
                                        onPressed: () => onTappedBar(2),
                                        child: Text(
                                          'Discussions',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ButtonStyle(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    children: [
                                      if (_currentIndex == 1) ...[
                                        Feed(widget.group_id),
                                      ] else if (_currentIndex == 2) ...[
                                        Discussions(
                                          widget.group_id,
                                          singleGroup.forum_id,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class GroupPhotoResponse {
  bool? status;
  String? error_code;
  String? message;

  GroupPhotoResponse({
    required this.status,
    required this.error_code,
    required this.message,
  });

  factory GroupPhotoResponse.fromJson(Map<String, dynamic> json) {
    return GroupPhotoResponse(
      status: json['status'],
      error_code: json['error_code'],
      message: json['message'],
    );
  }
}
