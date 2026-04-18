// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:ofc_learn_v2/groups/home_design_course.dart';
import 'package:ofc_learn_v2/groups/models/category.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Discussions extends StatefulWidget {
  var group;
  var form;

  Discussions(this.group, this.form);
  @override
  State<Discussions> createState() => _Discussions();
}

class _Discussions extends State<Discussions> {
  final ImagePicker _picker = ImagePicker();
  File? image;
  var group;

  var isLoading = false;
  @override
  void initState() {
    super.initState();
    discussionsPostList(context, widget.group);
  }

  final List<String> items = [
    'Normal',
    'Sticky',
  ];
  String? selectedValue;
  String genderDropdownValue = 'Normal';

///////////// GroupDiscussions API Calling /////////////
  ///
  List<DiscussionsPostList> discussionsList = [];
  List<DiscussionsPostList> tempdiscussionsList = [];

  Future<void> discussionsPostList(BuildContext context, group) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var user_id = prefs.getInt('isUserId');

    setState(() {
      isLoading = true;
    });
    var url = baseUrl +
        ApiEndPoints().discussionsPostList +
        "&group_id=$group&user_id=$user_id&type=d";

    var response = await http.get(Uri.parse(url));
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      List<DiscussionsListResponse> discussionsListResponse = [];

      discussionsListResponse
          .add(DiscussionsListResponse.fromJson(jsonDecode(response.body)));

      DiscussionsListResponse userResponse = discussionsListResponse[0];

      if (userResponse.status == "true" && userResponse.error_code == "0") {
        if (userResponse.discussionsPostList != null) {
          var data = userResponse.discussionsPostList;

          for (var e in data!) {
            discussionsList.add(e);
          }
          setState(() {
            tempdiscussionsList = discussionsList;
          });
        }
      }
    } else {
      customDialog(context, message: "Data not found", title: 'Error');
    }
  }

  final _titlecontroller = TextEditingController();
  final _contentcontroller = TextEditingController();
  final _content2controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : Column(
              children: <Widget>[
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
                      Row(children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: 10,
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "All Discussions",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff073278),
                                        fontSize: 15,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                                return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    content: Stack(
                                                        children: <Widget>[
                                                          SingleChildScrollView(
                                                              child: Form(
                                                                  child: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: <
                                                                          Widget>[
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 20,
                                                                    ),
                                                                    Container(
                                                                      height:
                                                                          40,
                                                                      width: 40,
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius:
                                                                            20,
                                                                        backgroundImage:
                                                                            AssetImage('assets/images/userImage.png'),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 20,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10,
                                                                          bottom:
                                                                              20,
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            TextField(
                                                                              controller: _titlecontroller,
                                                                              keyboardType: TextInputType.multiline,
                                                                              maxLines: null,
                                                                              decoration: InputDecoration(
                                                                                border: InputBorder.none,
                                                                                labelText: 'Disscussion Title....',
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      TextField(
                                                                        controller:
                                                                            _contentcontroller,
                                                                        keyboardType:
                                                                            TextInputType.multiline,
                                                                        maxLines:
                                                                            null,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          border:
                                                                              InputBorder.none,
                                                                          labelText:
                                                                              'Type your Discussion Content here....',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      TextField(
                                                                        controller:
                                                                            _content2controller,
                                                                        keyboardType:
                                                                            TextInputType.multiline,
                                                                        maxLines:
                                                                            null,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          border:
                                                                              InputBorder.none,
                                                                          labelText:
                                                                              'Type one and more , Comma seprated....',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    top: 30,
                                                                    left: 20,
                                                                    right: 20,
                                                                    bottom: 10,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                        child:
                                                                            FittedBox(
                                                                          child:
                                                                              FloatingActionButton(
                                                                            onPressed:
                                                                                () async {
                                                                              XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);
                                                                              setState(() {
                                                                                image = File(pickedImage!.path);
                                                                              });
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.camera_alt_rounded,
                                                                              color: Colors.white,
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                        child:
                                                                            FittedBox(
                                                                          child:
                                                                              FloatingActionButton(
                                                                            onPressed:
                                                                                () async {
                                                                              XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                                                                              setState(() {
                                                                                image = File(pickedImage!.path);
                                                                              });
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.file_copy_rounded,
                                                                              color: Colors.white,
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            70,
                                                                        width:
                                                                            80,
                                                                        child: image ==
                                                                                null
                                                                            ? Container(
                                                                                width: 350,
                                                                                height: 180,
                                                                                child: Text(""))
                                                                            : Image.file(
                                                                                image!,
                                                                                width: 350,
                                                                                height: 180,
                                                                              ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          20.0),
                                                                  child: Row(
                                                                      children: [
                                                                        Text(
                                                                            "Type : "),
                                                                        DropdownButton(
                                                                          value:
                                                                              genderDropdownValue,

                                                                          icon:
                                                                              const Icon(Icons.keyboard_arrow_down),
                                                                          onChanged:
                                                                              (String? newValue) {
                                                                            setState(() {
                                                                              genderDropdownValue = newValue!;
                                                                            });
                                                                          },

                                                                          items: <
                                                                              String>[
                                                                            'Normal',
                                                                            'Sticky',
                                                                          ].map<DropdownMenuItem<String>>((String
                                                                              value) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: value,
                                                                              child: Container(
                                                                                child: Text(
                                                                                  value,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          // After selecting the desired option,it will
                                                                          // change button value to selected value
                                                                        ),
                                                                      ]),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        top: 10,
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20,
                                                                        bottom:
                                                                            10,
                                                                      ),
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          newDisscution(
                                                                              context,
                                                                              _contentcontroller.text,
                                                                              _content2controller.text,
                                                                              _titlecontroller.text,
                                                                              widget.form);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Post",
                                                                        ),
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          primary:
                                                                              Color(0xff66C23D),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ])))
                                                        ]));
                                              },
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        size: 15,
                                      ),
                                      label: Text(
                                        'New discussions',
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                          physics: ScrollPhysics(parent: null),
                          shrinkWrap: true,
                          itemCount: tempdiscussionsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            DiscussionsPostList discussions =
                                tempdiscussionsList[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        discussions.user_image.toString(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          " ${discussions.title}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff073278),
                                            fontSize: 15,
                                          ),
                                        ),
                                        AutoSizeText(
                                          "${discussions.user_name} replied ${discussions.date_recorded}, ${discussions.total_member} members",
                                          minFontSize: 12,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color:
                                                Color.fromARGB(255, 87, 91, 97),
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              onPressed: () {},
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
              ],
            ),
    );
  }

  void newDisscution(
      BuildContext context, title, content, content2, form) async {
    List<DisscutionResponse> disscutionResponse;

    setState(() {
      isLoading = true;
    });
    var url = baseUrl + ApiEndPoints().add_dicuscsions;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('isUserId');
    print("ffffff");
    print(form);
    Map editprofileParams = {
      'user_id': userId.toString(),
      'bbp_topic_title': title,
      'bbp_topic_content': content,
      'bbp_stick_topic': content2,
      'bbp_forum_id': form.toString(),
    };

    var response = await http.post(Uri.parse(url), body: editprofileParams);
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      disscutionResponse = <DisscutionResponse>[];
      disscutionResponse
          .add(DisscutionResponse.fromJson(jsonDecode(response.body)));

      DisscutionResponse disscutionRes = disscutionResponse[0];

      await customDialog(
        context,
        message: disscutionRes.message,
      );
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Groups(),
          ),
        );
      });
    } else {
      print('error');
    }
  }
}

class DisscutionResponse {
  String status;
  String error_code;
  String message;

  DisscutionResponse({
    required this.status,
    required this.error_code,
    required this.message,
  });

  factory DisscutionResponse.fromJson(Map<String, dynamic> json) {
    return DisscutionResponse(
      status: json['status'],
      error_code: json['error_code'],
      message: json['message'],
    );
  }
}
