import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ofc_learn_v2/sidebarscreens/profile/edit.dart';
import 'package:ofc_learn_v2/sidebarscreens/profile/profilephoto.dart';
import 'package:ofc_learn_v2/sidebarscreens/profile/coverphoto.dart';
import 'package:http/http.dart' as http;

class Editprofile extends StatefulWidget {
  @override
  _Editprofile createState() => _Editprofile();
}

class _Editprofile extends State<Editprofile> with TickerProviderStateMixin {
  int _currentIndex = 1;

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 241, 240, 240),
        appBar: AppBar(
          backgroundColor: Color(0xFF063278),
          elevation: 0,
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff073278),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => onTappedBar(1),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff66C23D),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                              label: Text('Edit'),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton.icon(
                              onPressed: () => onTappedBar(2),
                              icon: Icon(
                                Icons.book,
                                size: 20,
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff66C23D),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              label: Text('Profile Photo'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => onTappedBar(3),
                              icon: Icon(
                                Icons.photo,
                                size: 20,
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff66C23D),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              label: Text('Cover Photo'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          if (_currentIndex == 1) ...[
                            Edit(),
                          ] else if (_currentIndex == 2) ...[
                            Profilephoto(),
                          ] else if (_currentIndex == 3) ...[
                            Coverphoto(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
