// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  bool isLoading = false;
  var passwordVisible = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();

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
            body: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 70),
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 35, right: 35),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign in to OFC Learn',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: userEmail,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Email",
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
                                height: 20,
                              ),
                              TextFormField(
                                controller: userPassword,
                                style: TextStyle(),
                                obscureText: passwordVisible ? false : true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required*';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, 'forgotpassword');
                                    },
                                    child: Text(
                                      'Forgot Password',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Color(0xff28C0D6),
                                      ),
                                    ),
                                    style: ButtonStyle(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
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
                                  loginUser(context);
                                },
                                child: isLoading != true
                                    ? Text(
                                        'Login',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account ?",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'register');
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Color(0xff28C0D6),
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ButtonStyle(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 70,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Center(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style: TextStyle(
                                            color: Color(0xff28C0D6),
                                            fontSize: 15,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(
                                                  context, 'termsandcondition');
                                            },
                                        ),
                                        TextSpan(
                                          text: ' & ',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: Color(0xff28C0D6),
                                            fontSize: 15,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(
                                                  context, 'privacypolicy');
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
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

  void loginUser(BuildContext context) async {
    List<LoginResponse>? loginResponse;

    if (_formKey.currentState!.validate()) {
      final url = baseUrl + ApiEndPoints().login;

      Map loginParams = {
        'user_email': userEmail.text,
        'password': userPassword.text,
      };

      var response = await http.post(Uri.parse(url), body: loginParams);

      if (response.statusCode == 200) {
        loginResponse = <LoginResponse>[];
        loginResponse.add(LoginResponse.fromJson(jsonDecode(response.body)));

        setState(() {
          isLoading = false;
        });
        LoginResponse userResponse = loginResponse[0];

        if (userResponse.status == "true" && userResponse.error_code == "0") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isLoggedIn", true);
          prefs.setInt("isUserId", userResponse.user_id as int);

          var status = prefs.getBool('isLoggedIn');
          if (status == true) {
            Navigator.pushNamed(context, 'home');
          } else {
            print('dfklhjlgdf');
          }
        } else {
          customDialog(context,
              message: userResponse.message ?? "-", title: "Faild");
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

class LoginResponse {
  String? status;
  String? error_code;
  int? user_id;
  String? password;
  String? message;

  LoginResponse({
    this.status,
    this.error_code,
    this.user_id,
    this.password,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      error_code: json['error_code'],
      user_id: json['User_ID'],
      password: json['password'],
      message: json['message'],
    );
  }
}
