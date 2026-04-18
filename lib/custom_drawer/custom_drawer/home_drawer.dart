// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/app_theme.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:ofc_learn_v2/navigation_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeDrawer extends StatefulWidget {
  const HomeDrawer(
      {Key? key,
      this.screenIndex,
      this.iconAnimationController,
      this.callBackIndex})
      : super(key: key);

  final AnimationController? iconAnimationController;
  final DrawerIndex? screenIndex;
  final Function(DrawerIndex)? callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList>? drawerList;
  var futureProfileDetails;
  @override
  void initState() {
    setDrawerListArray();
    setState(() {
      futureProfileDetails = profileGetList(context);
    });

    super.initState();
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: 'Home',
        icon: Icon(Icons.home),
      ),
      DrawerList(
        index: DrawerIndex.PROFILE,
        labelName: 'Profile',
        icon: Icon(Icons.person),
      ),
      DrawerList(
        index: DrawerIndex.CONNECTIONS,
        labelName: 'Connections',
        icon: Icon(Icons.contact_mail),
      ),
      DrawerList(
        index: DrawerIndex.GROUPS,
        labelName: 'Groups',
        icon: Icon(Icons.groups),
      ),
      DrawerList(
        index: DrawerIndex.COURSES,
        labelName: 'Courses',
        icon: Icon(Icons.golf_course),
      ),
      DrawerList(
        index: DrawerIndex.CPD_POINTS,
        labelName: 'CPD Points',
        icon: Icon(Icons.point_of_sale),
      ),
      DrawerList(
        index: DrawerIndex.RANKS,
        labelName: 'Ranks',
        icon: Icon(Icons.group_work),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite.withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(1.0 -
                            (widget.iconAnimationController!.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(
                            Tween<double>(begin: 0.0, end: 24.0)
                                    .animate(CurvedAnimation(
                                        parent: widget.iconAnimationController!,
                                        curve: Curves.fastOutSlowIn))
                                    .value /
                                360,
                          ),
                          child: FutureBuilder<ProfileDetails>(
                              future: futureProfileDetails,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: AppTheme.grey
                                                    .withOpacity(0.6),
                                                offset: const Offset(2.0, 4.0),
                                                blurRadius: 8),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(60.0)),
                                          child: Image.network(
                                              "${snapshot.data!.profile_image}",
                                              // width: 300,
                                              // height: 150,
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, left: 8),
                                        child: Text(
                                          "${snapshot.data!.user_nicKname}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff073278),
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('No data found'));
                                }

                                return Center(
                                    child: CircularProgressIndicator());
                              }),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: Color(0xff073278),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: Color(0xff073278),
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Log Out',
                  style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xff073278)),
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(
                  Icons.power_settings_new,
                  color: Color(0xff073278),
                ),
                onTap: () {
                  onTapped();
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ],
      ),
    );
  }

  void onTapped() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", false);
    Navigator.pushNamed(context, 'splashscreen');
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index!);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName,
                              color: widget.screenIndex == listData.index
                                  ? Color(0xff073278)
                                  : AppTheme.nearlyBlack),
                        )
                      : Icon(listData.icon?.icon,
                          color: widget.screenIndex == listData.index
                              ? Color(0xff073278)
                              : AppTheme.nearlyBlack),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index
                          ? Color(0xff073278)
                          : AppTheme.nearlyBlack,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) *
                                (1.0 -
                                    widget.iconAnimationController!.value -
                                    1.0),
                            0.0,
                            0.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 0.75 - 64,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Color(0xff073278).withOpacity(0.2),
                              borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    NavigationHomeScreen(indexScreen);

    if (indexScreen == DrawerIndex.HOME ||
        indexScreen == DrawerIndex.COURSES ||
        indexScreen == DrawerIndex.GROUPS) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationHomeScreen(indexScreen),
        ),
      );
    } else {
      widget.callBackIndex!(indexScreen);
    }
  }

  Future<ProfileDetails> profileGetList(BuildContext context) async {
    final url = baseUrl + ApiEndPoints().profileGetList;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('isUserId');

    final response = await http.get(Uri.parse("$url&user_id=$user_id"));
    print(response.body);
    if (response.statusCode == 200) {
      return ProfileDetails.fromJson(jsonDecode(response.body));
    } else {
      throw customDialog(context, message: "Data not found", title: 'Error');
    }
  }
}

/////////////////////////////////////////////////////
enum DrawerIndex {
  HOME,
  PROFILE,
  CONNECTIONS,
  GROUPS,
  COURSES,
  CPD_POINTS,
  RANKS
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
}

/////////////////////////////////////////////////////////////////////

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
  String? profile_image;
  String? cover_image;

  ProfileDetails(
      {this.status,
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
      this.profile_image,
      this.cover_image});

  factory ProfileDetails.fromJson(Map<String, dynamic> json) {
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

      profile_image: json["Data"]["profile_image"],
      cover_image: json["Data"]["cover_image"],
    );
  }
}
