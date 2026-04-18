// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';

import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Connection extends StatefulWidget {
  @override
  _Connection createState() => _Connection();
}

class _Connection extends State<Connection> {
  final List<String> items = [
    'Recently Active',
    'Newest Members',
    'Alphabetical',
  ];
  String? selectedValue;
  var futureConnectionList;
  @override
  void initState() {
    futureConnectionList = connectionGetList(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            backgroundColor: Color.fromARGB(255, 241, 240, 240),
            appBar: AppBar(
              backgroundColor: const Color(0xFF063278),
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Image.asset('assets/images/logo.png',
                          width: 100, height: 55, fit: BoxFit.fill),
                    ),
                  ),
                ],
              ),
            ),
            body: FutureBuilder<ConnectionList>(
                future: futureConnectionList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Text(
                                "Connection",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff073278),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 950,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Container(
                                        child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                        ),
                                        Center(),
                                        Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(snapshot
                                                    .data!.friend_image
                                                    .toString()),
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          snapshot.data!.friend_display_name
                                              .toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            height: 1.5,
                                            color: Color(0xff073278),
                                            fontSize: 22,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Joined Nov 2021 . ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "Active 2 hours ago",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "0 followers",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.speaker_group_sharp,
                                                  size: 30,
                                                ),
                                                onPressed: () => {},
                                                color: Colors.grey,
                                              ),
                                            ), //Flexible
                                            SizedBox(
                                              width: 10,
                                            ), //SizedBox
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.person_add,
                                                  size: 30,
                                                ),
                                                onPressed: () => {},
                                                color: Colors.grey,
                                              ), //Container
                                            ), //Flexible
                                            SizedBox(
                                              width: 10,
                                            ), //SizedBox
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.email,
                                                  size: 30,
                                                ),
                                                onPressed: () => {},
                                                color: Colors.grey,
                                              ), ////Container
                                            ) //Flexible
                                          ], //<Widget>[]
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('No data found'));
                  }

                  return Center(child: CircularProgressIndicator());
                })));
  }
}

Future<ConnectionList> connectionGetList(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var user_id = prefs.getInt('isUserId');

  final url = baseUrl + ApiEndPoints().connectionGetList;

  final response = await http.get(Uri.parse(
      // "https://readyforyourreview.com/SeanDouglas12/wp-json/coinapi/v1/mobile?task=get_connection&user_id=2706"));
      "$url&user_id=$user_id"));

  if (response.statusCode == 200) {
    return ConnectionList.fromJson(jsonDecode(response.body));
  } else {
    throw customDialog(context, message: "Data not found", title: 'Error');
  }
}

class ConnectionList {
  bool? status;
  String? error_code;
  String? message;
  String? friend_id;
  String? friend_display_name;
  String? friend_image;

  ConnectionList({
    this.status,
    this.error_code,
    this.message,
    this.friend_id,
    this.friend_display_name,
    this.friend_image,
  });

  factory ConnectionList.fromJson(Map<String, dynamic> json) {
    return ConnectionList(
      status: json['status'],
      error_code: json['error_code'],
      message: json['message'],
      friend_id: json["data"]["friend_id"],
      friend_display_name: json['data']['friend_display_name'],
      friend_image: json['data']['friend_image'],
    );
  }
}
