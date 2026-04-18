// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

class Coverphoto extends StatefulWidget {
  @override
  _Coverphoto createState() => _Coverphoto();
}

class _Coverphoto extends State<Coverphoto> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? image;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Change Cover Photo",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff073278),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: Color.fromARGB(255, 248, 246, 246),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10,
                          left: 5,
                          right: 5,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Color(0xff66C23D),
                                    size: 40,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  AutoSizeText(
                                    'Your profile photo will be used on your profile and throughout the site.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                    minFontSize: 10,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
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
                SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: Color.fromARGB(255, 248, 246, 246),
                  child: Container(
                      width: 500,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Drop your image here",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 5,
                              right: 5,
                              bottom: 10,
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: Color(0xff66C23D),
                              ),
                              onPressed: () async {
                                XFile? pickedImage = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() {
                                  image = File(pickedImage!.path);
                                });
                                uploadcoverphoto(context, image);
                              },
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.green),
                                    )
                                  : Text(
                                      'Select your Cover',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void uploadcoverphoto(
    BuildContext context,
    File? image,
  ) async {
    setState(() {
      isLoading = true;
    });

    List<CoverPhotoResponse> coverPhotoResponse;

    var url = baseUrl + ApiEndPoints().uploadcoverphoto;
    print(url);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('isUserId');

    var stream = new http.ByteStream(DelegatingStream.typed(image!.openRead()));

    var length = await image.length();

    var uri = Uri.parse(url);

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile(
      'upload_cover_photo_api',
      stream,
      length,
      filename: basename(image.path),
    );

    request.files.add(multipartFile);
    request.fields['user_id'] = userId.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      print(response);
      print(response.stream);

      setState(() {
        isLoading = false;
      });
      response.stream.transform(utf8.decoder).listen(
        (value) {
          coverPhotoResponse = <CoverPhotoResponse>[];

          coverPhotoResponse
              .add(CoverPhotoResponse.fromJson(jsonDecode(value)));

          CoverPhotoResponse coverPhotoRes = coverPhotoResponse[0];

          customDialog(context, message: coverPhotoRes.message.toString());
          print(jsonDecode(value));
        },
      );
    } else {
      print('error');
    }
  }
}

class CoverPhotoResponse {
  String? status;
  String? error_code;
  String? User_ID;
  String? Cover_Photo_Link;
  String? message;

  CoverPhotoResponse({
    required this.status,
    required this.error_code,
    required this.User_ID,
    required this.Cover_Photo_Link,
    required this.message,
  });

  factory CoverPhotoResponse.fromJson(Map<String, dynamic> json) {
    return CoverPhotoResponse(
      status: json['status'],
      error_code: json['error_code'],
      User_ID: json['User_ID'],
      Cover_Photo_Link: json['Cover_Photo_Link'],
      message: json['message'],
    );
  }
}
