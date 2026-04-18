// ignore_for_file: non_constant_identifier_names, unrelated_type_equality_checks
import 'dart:convert';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPassword createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController forgotEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayColor: Colors.black,
      overlayOpacity: 0.7,
      overlayWidget: Center(
        child: SpinKitCubeGrid(
          color: Color(0xff66C23D),
          size: 60.0,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Container(
          child: Scaffold(
            backgroundColor: Color(0xFF063278),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 35, right: 35),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Please enter your email address',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: forgotEmail,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Email Address",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required*';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 350,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: Color(0xff66C23D),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  fPassword(context);
                                },
                                child: isLoading != true
                                    ? Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      )
                                    : const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void fPassword(BuildContext context) async {
    List<ForgotResponse>? forgotResponse;

    if (_formKey.currentState!.validate()) {
      final url = baseUrl + ApiEndPoints().fPassowrd;

      Map fPassowrdParams = {
        'user_email': forgotEmail.text,
      };

      var response = await http.post(Uri.parse(url), body: fPassowrdParams);

      if (response.statusCode == 200) {
        forgotResponse = <ForgotResponse>[];
        forgotResponse.add(ForgotResponse.fromJson(jsonDecode(response.body)));

        ForgotResponse userResponse = forgotResponse[0];
  setState(() {
            isLoading = false;
          });
        await customDialog(context,
            message: userResponse.message ?? "-",
            title: userResponse.status == true ? "Success" : "Faild");

        if (userResponse.status == true && userResponse.error_code == "0") {
            setState(() {
            isLoading = false;
          });
          Navigator.pushNamed(context, 'login');
        }
      } else {
        customDialog(context, message: "Data not found", title: 'Error');
      }
    }
     setState(() {
            isLoading = false;
          });
  }
}

class ForgotResponse {
  bool? status;
  String? error_code;
  String? code;
  String? message;

  ForgotResponse({
    this.status,
    this.error_code,
    this.code,
    this.message,
  });

  factory ForgotResponse.fromJson(Map<String, dynamic> json) {
    return ForgotResponse(
      status: json['status'],
      error_code: json['error_code'],
      code: json['code'],
      message: json['message'],
    );
  }
}
