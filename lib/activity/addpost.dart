// ignore_for_file: non_constant_identifier_names, must_be_immutable, deprecated_member_use, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addpost extends StatefulWidget {
  var post_type;

  Addpost(this.post_type);

  @override
  State<Addpost> createState() => _AddpostState();
}

TextEditingController content = TextEditingController();

class _AddpostState extends State<Addpost> {
  final ImagePicker _picker = ImagePicker();
  File? image;

  void clearText() {
    setState(() {
      content.clear();
    });
  }

  @override
  void initState() {
    clearText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF063278),
        title: Text("Add Post"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                activityAddPost(
                  context,
                );
              },
              style: TextButton.styleFrom(
                primary: Color(0xFF063278),
                backgroundColor: Colors.white,
              ),
              child: Text(
                'POST',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: content,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Write somthing here...',
                ),
              ),
            ),
            image == null
                ? Text("")
                : Image.file(
                    image!,
                    height: 200,
                    width: 200,
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          XFile? pickedImage =
              await _picker.pickImage(source: ImageSource.gallery);
          setState(() {
            image = File(pickedImage!.path);
          });
        },
        child: Icon(
          Icons.camera_alt_rounded,
        ),
        backgroundColor: Color(0xFF063278),
      ),
    );
  }

////////// Api Implementation For Add Post   //////////
  void activityAddPost(
    BuildContext context,
  ) async {
    List<addPostResponseList> addPostResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt('isUserId');
    Map data = {
      'user_id': id.toString(),
      'object': "user",
      'content': content.text,
      'action': "post_update",
      'type': widget.post_type,
    };
    final url = baseUrl + ApiEndPoints().activityAddPost;
    var response = await http.post(Uri.parse(url), body: data);
    if (response.statusCode == 200) {
      List<addPostResponseList> addPostResponse = [];
      addPostResponse
          .add(addPostResponseList.fromJson(jsonDecode(response.body)));

      addPostResponseList newPostResponse = addPostResponse[0];

      if (newPostResponse.status == "true") {
        await customDialog(
          context,
          message: newPostResponse.message ?? "-",
          title: '${newPostResponse.status == "true" ? "Success" : "Error"}',
        );
        // clearText();
        setState(() {
          Navigator.pushNamed(context, 'home');
        });
      }
    } else {
      customDialog(context, message: "Data not found", title: 'Error');
    }
  }
}

/////////// Model ///////////
class addPostResponseList {
  addPostResponseList({
    this.status,
    this.error_code,
    this.message,
  });

  String? status;
  String? error_code;
  String? message;

  factory addPostResponseList.fromJson(Map<String, dynamic> json) {
    return addPostResponseList(
        status: json["status"],
        error_code: json["error_code"],
        message: json["message"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "error_code": error_code,
      "message": message,
    };
  }
}
