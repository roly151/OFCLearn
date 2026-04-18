import 'package:flutter/material.dart';
import 'package:ofc_learn_v2/app_theme.dart';
import 'package:ofc_learn_v2/home_screen.dart';
import 'package:ofc_learn_v2/sidebarscreens/rank.dart';
import 'package:ofc_learn_v2/sidebarscreens/CPDpoint.dart';
import 'package:ofc_learn_v2/sidebarscreens/connection.dart';
import 'package:ofc_learn_v2/sidebarscreens/profile/profile.dart';
import './custom_drawer/custom_drawer/drawer_user_controller.dart';
import './custom_drawer/custom_drawer/home_drawer.dart';

class NavigationHomeScreen extends StatefulWidget {
  var indexScreen;
  NavigationHomeScreen(this.indexScreen);
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    if (widget.indexScreen != "" && widget.indexScreen == DrawerIndex.HOME) {
      drawerIndex = DrawerIndex.HOME;
      screenView = MyHomePage(0);
    } else if (widget.indexScreen != "" &&
        widget.indexScreen == DrawerIndex.COURSES) {
      drawerIndex = DrawerIndex.COURSES;
      screenView = MyHomePage(1);
    } else if (widget.indexScreen != "" &&
        widget.indexScreen == DrawerIndex.GROUPS) {
      drawerIndex = DrawerIndex.GROUPS;
      screenView = MyHomePage(3);
    } else {
      drawerIndex = DrawerIndex.HOME;
      screenView = MyHomePage(0);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
            },
            screenView: screenView,
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = MyHomePage(0);
          });
          break;
        case DrawerIndex.PROFILE:
          setState(() {
            screenView = Profile();
          });
          break;
        case DrawerIndex.CONNECTIONS:
          setState(() {
            screenView = Connection();
          });
          break;
        case DrawerIndex.GROUPS:
          setState(() {
            screenView = MyHomePage(3);
          });
          break;
        case DrawerIndex.COURSES:
          setState(() {
            screenView = MyHomePage(1);
          });
          break;
        case DrawerIndex.CPD_POINTS:
          setState(() {
            screenView = CPDpoint();
          });
          break;
        case DrawerIndex.RANKS:
          setState(() {
            screenView = Rank();
          });
          break;
        case DrawerIndex.RANKS:
          setState(() {
            screenView = Rank();
          });
          break;
        default:
          break;
      }
    }
  }
}
