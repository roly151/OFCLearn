// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ofc_learn_v2/sidebarscreens/profile/editprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> with TickerProviderStateMixin {
  var user_id, first_name, last_name, nick_name;
  var futureProfileDetails;
  @override
  void initState() {
    futureProfileDetails = profileGetList(context);
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
      body: FutureBuilder<ProfileDetails>(
          future: futureProfileDetails,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Text(
                                    "Profile",
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
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Base",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff073278),
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // ElevatedButton(
                                        //   onPressed: () {
                                        //     Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             Editprofile(),
                                        //       ),
                                        //     );
                                        //   },
                                        //   child: Text(
                                        //     "Edit",
                                        //   ),
                                        //   style: ElevatedButton.styleFrom(
                                        //     primary: Color(0xff66C23D),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        left: 16,
                                        right: 16,
                                        bottom: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Name",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 110,
                                        ),
                                        Text(
                                          "${snapshot.data!.first_name}",
                                          // "SeanDouglas12",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff073278),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        left: 16,
                                        right: 16,
                                        bottom: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Last Name",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                        ),
                                        Text(
                                          "${snapshot.data!.last_name}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff073278),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        left: 16,
                                        right: 16,
                                        bottom: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Nickname",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                        ),
                                        Text(
                                          "${snapshot.data!.user_nicKname}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff073278),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        left: 16,
                                        right: 16,
                                        bottom: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date of Birth",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 60,
                                        ),
                                        Text(
                                          "${snapshot.data!.ofc_date_of_birth}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff073278),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        left: 16,
                                        right: 16,
                                        bottom: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Gender",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 95,
                                        ),
                                        Text(
                                          "${snapshot.data!.ofc_gender}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff073278),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        left: 16,
                                        right: 16,
                                        bottom: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Country",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90,
                                        ),
                                        Text(
                                          "${snapshot.data!.ofc_country}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff073278),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        left: 16,
                                        right: 16,
                                        bottom: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Regional \n Organisation",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${snapshot.data!.ofc_regional_organisation}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff073278),
                                              fontSize: 15,
                                            ),
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
          }),
    ));
  }

  Future<ProfileDetails> profileGetList(BuildContext context) async {
    final url = baseUrl + ApiEndPoints().profileGetList;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');

    final response = await http.get(Uri.parse("$url&user_id=$user_id"));
    if (response.statusCode == 200) {
      return ProfileDetails.fromJson(jsonDecode(response.body));
    } else {
      throw customDialog(context, message: "Data not found", title: 'Error');
    }
  }
}

class ProfileDetails {
  bool? status;
  String? error_code;
  String? message;
  int? iD;
  String? user_nicKname;
  String? first_name;

  String? last_name;
  String? ofc_country;
  String? ofc_gender;
  String? ofc_date_of_birth;
  // String? ofc_age_groups;
  String? ofc_regional_organisation;

  ProfileDetails({
    this.status,
    this.error_code,
    this.message,
    this.iD,
    this.user_nicKname,
    this.first_name,
    this.last_name,
    this.ofc_country,
    this.ofc_gender,
    this.ofc_date_of_birth,
    // this.ofc_age_groups,
    this.ofc_regional_organisation,
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) {
    print("hhhhhhhh");
    print(json["Data"]["ofc_date_of_birth"]);
    return ProfileDetails(
      status: json['status'],
      error_code: json['error_code'],
      message: json['message'],
      iD: json['Data']['ID'],
      user_nicKname: json['Data']['user_nicKname'],
      first_name: json['Data']['first_name'],
      last_name: json['Data']['last_name'],
      ofc_country: json["Data"]["ofc_country"],
      ofc_gender: json['Data']['ofc_gender'],
      ofc_date_of_birth: json["Data"]["ofc_date_of_birth"],
      // ofc_age_groups: json["Data"]["ofc_age_groups"],
      ofc_regional_organisation: json["Data"]["ofc_regional_organisation"],
    );
  }
}
