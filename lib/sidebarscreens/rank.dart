// ignore_for_file: non_constant_identifier_names, unused_local_variable, dead_code

import 'dart:convert';

import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Rank extends StatefulWidget {
  @override
  _Rank createState() => _Rank();
}

class _Rank extends State<Rank> with TickerProviderStateMixin {
  var futureRankList;
  @override
  void initState() {
    futureRankList = getLernerList(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            backgroundColor: Colors.white,
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
            body: FutureBuilder<RankList>(
                future: futureRankList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Stack(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8, left: 8, right: 8),
                          child: SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Text(
                                          "Rank",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff073278),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Text(
                                          "Learner",
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff073278),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 30,
                                            left: 15,
                                            right: 15,
                                            bottom: 30,
                                          ),
                                          child: Row(
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
                                                    snapshot.data!.learner_image
                                                        .toString()),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 15,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        snapshot
                                                            .data!.learner_title
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xff073278),
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('No data found'));
                  }

                  return Center(child: CircularProgressIndicator());
                })));
  }

  Future<RankList> getLernerList(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');

    final url = baseUrl + ApiEndPoints().getLernerList;

    final response = await http.get(Uri.parse("$url&user_id=$user_id"));
    print(response.statusCode);
    if (response.statusCode == 200) {
      return RankList.fromJson(jsonDecode(response.body));
    } else {
      throw customDialog(context,
          message: "No Data Found Please try again", title: 'Error');
    }
  }
}

class RankList {
  bool? status;
  String? error_code;
  String? message;
  String? learner_title;
  String? learner_image;

  RankList({
    this.status,
    this.error_code,
    this.message,
    this.learner_title,
    this.learner_image,
  });

  factory RankList.fromJson(Map<String, dynamic> json) {
    return RankList(
      status: json['status'],
      error_code: json['error_code'],
      message: json['message'],
      learner_title: json["data"]["Learner_title"],
      learner_image: json['data']['learner_image'],
    );
  }
}
