// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'dart:convert';

import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  bool isChecked = false;
  var passwordVisible = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController conEmail = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController conPassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController userName = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String countryDropdownValue = 'Country';
  String genderDropdownValue = 'Gender';
  String regionalDropdownValue = 'Regional';

  @override
  Widget build(BuildContext context) {
    String _formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    return Form(
      key: _formKey,
      child: Container(
        child: Scaffold(
          backgroundColor: Color.fromARGB(241, 243, 241, 243),
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
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Create an Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff073278),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enter your details here',
                                style: TextStyle(
                                  color: Color(0xff073278),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: email,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Email*';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: conEmail,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Confirm Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Confirm Email*';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: password,
                            style: TextStyle(),
                            obscureText: passwordVisible ? false : true,
                            decoration: InputDecoration(
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
                                return 'Please enter your Password*';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: conPassword,
                            style: TextStyle(),
                            obscureText: passwordVisible ? false : true,
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Confirm Password",
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
                                return 'Please enter your Confirm Password*';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: name,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "First name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Name*';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: lastName,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Last Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Surname*';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: userName,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Username",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Username*';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // DOB(),
                          Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  " $_formattedDate",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    minimumSize: const Size.fromHeight(40),
                                    backgroundColor: Color(0xff28C0D6),
                                  ),
                                  onPressed: () => _selectDate(context),
                                  child: Text('Select date of birth'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: DropdownButtonHideUnderline(
                                        child: ButtonTheme(
                                      // alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        // isDense: true,
                                        value: genderDropdownValue,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        isExpanded: true,
                                        elevation: 16,
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 42, 41, 41),
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            genderDropdownValue = newValue!;
                                          });
                                        },
                                        items: <String>[
                                          'Gender',
                                          'Male',
                                          'Female',
                                          'Other'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Container(
                                              child: Text(
                                                value,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )))
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: DropdownButtonHideUnderline(
                                        child: ButtonTheme(
                                      child: DropdownButton<String>(
                                        value: countryDropdownValue,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        isExpanded: true,
                                        elevation: 16,
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 42, 41, 41),
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            countryDropdownValue = newValue!;
                                          });
                                        },
                                        items: <String>[
                                          'Country',
                                          'Afghanistan',
                                          'Albania',
                                          'Algeria',
                                          'American Samoa',
                                          'Andorra',
                                          'Angola',
                                          'Antigua and Barbuda',
                                          'Argentina',
                                          'Armenia',
                                          'Australia',
                                          'Austria',
                                          'Azerbaijan',
                                          'Bahamas',
                                          'Bahrain',
                                          'Bangladesh',
                                          'Barbados',
                                          'Belarus',
                                          'Belgium',
                                          'Belize',
                                          'Benin',
                                          'Bhutan',
                                          'Bolivia',
                                          'Bosnia and Herzegovina',
                                          'Botswana',
                                          'Brazil',
                                          'Brunei',
                                          'Bulgaria',
                                          'Burundi',
                                          'Cambodia',
                                          'Cameroon',
                                          'Canada',
                                          'Cape Verde',
                                          'Central African Republic',
                                          'Chad',
                                          'Chile',
                                          'China',
                                          'Colombi',
                                          'Comoros',
                                          'Congo Brazzaville)',
                                          'Congo',
                                          'Cook Islands',
                                          'Costa Rica',
                                          'Cote dIvoire',
                                          'Croatia',
                                          'Cuba',
                                          'Cyprus',
                                          'Czech Republic',
                                          'Denmark',
                                          'Djibouti',
                                          'Dominica',
                                          'Dominican Republic',
                                          'East Timor (Timor Timur)',
                                          'Ecuador',
                                          'Egypt',
                                          'El Salvador',
                                          'Equatorial Guinea',
                                          'Eritrea',
                                          'Estonia',
                                          'Ethiopia',
                                          'Fiji',
                                          'Finland',
                                          'France',
                                          'Gabon',
                                          'Gambia, The',
                                          'Georgia',
                                          'Germany',
                                          'Ghana',
                                          'Greece',
                                          'Grenada',
                                          'Guatemala',
                                          'Guinea',
                                          'Guinea-Bissau',
                                          'Guyana',
                                          'Haiti',
                                          'Honduras',
                                          'Hungary',
                                          'Iceland',
                                          'India',
                                          'Indonesia',
                                          'Iran',
                                          'Iraq',
                                          'Ireland',
                                          'Israel',
                                          'Italy',
                                          'Jamaica',
                                          'Japan',
                                          'Jordan',
                                          'Kazakhstan',
                                          'Kenya',
                                          'Kiribati',
                                          'Korea, North',
                                          'Korea, South',
                                          'Kuwait',
                                          'Kyrgyzstan',
                                          'Laos',
                                          'Latvia',
                                          'Lebanon',
                                          'Lesotho',
                                          'Liberia',
                                          'Libya',
                                          'Liechtenstein',
                                          'Lithuania',
                                          'Luxembourg',
                                          'Macedonia',
                                          'Madagascar',
                                          'Malawi',
                                          'Malaysia',
                                          'Maldives',
                                          'Mali',
                                          'Malta',
                                          'Marshall Islands',
                                          'Mauritania',
                                          'Mauritius',
                                          'Mexico',
                                          'Micronesia',
                                          'Moldova',
                                          'Monaco',
                                          'Mongolia',
                                          'Morocco',
                                          'Mozambique',
                                          'Myanmar',
                                          'Namibia',
                                          'Nauru',
                                          'Nepal',
                                          'Netherlands',
                                          'New Caledonia',
                                          'New Zealand',
                                          'Nicaragua',
                                          'Niger',
                                          'Nigeria',
                                          'Norway',
                                          'Oman',
                                          'Pakistan',
                                          'Palau',
                                          'Panama',
                                          'Papua New Guinea',
                                          'Paraguay',
                                          'Peru',
                                          'Philippines',
                                          'Poland',
                                          'Portugal',
                                          'Qatar',
                                          'Romania',
                                          'Russia',
                                          'Rwanda',
                                          'Saint Kitts and Nevis',
                                          'Saint Lucia',
                                          'Saint Vincent',
                                          'Samoa',
                                          'San Marino',
                                          'Sao Tome and Principe',
                                          'Saudi Arabia',
                                          'Senegal',
                                          'Serbia and Montenegro',
                                          'Seychelles',
                                          'Sierra Leone',
                                          'Singapore',
                                          'Slovakia',
                                          'Slovenia',
                                          'Solomon Islands',
                                          'Somalia',
                                          'South Africa',
                                          'Spain',
                                          'Sri Lanka',
                                          'Sudan',
                                          'Suriname',
                                          'Swaziland',
                                          'Sweden',
                                          'Switzerland',
                                          'Syria',
                                          'Tahiti',
                                          'Taiwan',
                                          'Tajikistan',
                                          'Tanzania',
                                          'Thailand',
                                          'Togo',
                                          'Tonga',
                                          'Trinidad and Tobago',
                                          'Tunisia',
                                          'Turkey',
                                          'Turkmenistan',
                                          'Tuvalu',
                                          'Uganda',
                                          'Ukraine',
                                          'United Arab Emirates',
                                          'United Kingdom',
                                          'United States',
                                          'Uruguay',
                                          'Uzbekistan',
                                          'Vanuatu',
                                          'Vatican City',
                                          'Venezuela',
                                          'Vietnam',
                                          'Yemen',
                                          'Zambia',
                                          'Zimbabwe',
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Container(
                                              child: Text(
                                                value,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                    child: DropdownButtonHideUnderline(
                                        child: ButtonTheme(
                                  child: DropdownButton<String>(
                                    value: regionalDropdownValue,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    elevation: 16,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 42, 41, 41),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        regionalDropdownValue = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'Regional',
                                      'FJ - Fiji Football Association',
                                      'NC - Comité Provincial Football Iles Loyauté',
                                      'NC - Comité Provincial Nord de Football',
                                      'NC - Comité Provincial Sud de Football',
                                      'NZ - Northern Football',
                                      'NZ - Waikato/Bay of Plenty',
                                      'NZ - Central Football',
                                      'NZ - Capital Football',
                                      'NZ - Mainland Football',
                                      'NZ - Football South',
                                      'Other',
                                      'PF - Australes',
                                      'PF - Iles de la Société',
                                      'PF - Iles Sous Le Vent',
                                      'PF - Marquises',
                                      'PF - Tuamotu',
                                      'PNG - Bouganville Football Federation',
                                      'PNG - Goroka Soccer Association',
                                      'PNG - Hekari Soccer Association',
                                      'PNG - Kimbe Soccer Association',
                                      'PNG - Koupa Soccer Association',
                                      'PNG - Lae Football Association',
                                      'PNG - Lahi Soccer Association',
                                      'PNG - Madang Soccer Association',
                                      'PNG - Manus Soccer Association',
                                      'PNG - Mendi Soccer Association',
                                      'PNG - Mt Hagen Soccer Association',
                                      'PNG - NBPOL Soccer Association',
                                      'PNG - NCDPSSA',
                                      'PNG - Port Moresby Soccer Association',
                                      'PNG - Simbu Soccer Association',
                                      'PNG - Tabubil Soccer Association',
                                      'PNG - Wabag Soccer Association',
                                      'PNG - Wau Soccer Association',
                                      'SB - Central Islands Football Association',
                                      'SB - Guadalcanal Football Association',
                                      'SB - Honiara Football Association',
                                      'SB - Isabel Football Association',
                                      'SB - Lauru Football Association',
                                      'SB - Makira Ulawa Football Association',
                                      'SB - Malaita Football Association',
                                      'SB - Renbel Football Association',
                                      'SB - Temotu Football Association',
                                      'SB - Western Football Association',
                                      'TO - Eua',
                                      'TO - Haapai',
                                      'TO - Tongatapu',
                                      'TO - Vavau',
                                      'VU - Penama FA',
                                      'VU - Torba FA',
                                      'VU - Luganville FA',
                                      'VU - Wanma FA',
                                      'VU - Port Vila FA',
                                      'VU - Malampa FA',
                                      'VU - Shefa FA',
                                      'VU - Tafea FA',
                                      'WS - Savaii HUB',
                                      'WS - Upolu HUB',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Container(
                                          child: Text(
                                            value,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )))
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Color(0xff66C23D),
                            ),
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              registrationOfuser(
                                context,
                                _formattedDate,
                              );
                            },
                            child: isLoading != true
                                ? Text(
                                    'Create Account',
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
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: "I agree to the ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                )),
                                            TextSpan(
                                              text: "Terms of Service",
                                              style: TextStyle(
                                                color: Color(0xff073278),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              recognizer:
                                                  new TapGestureRecognizer()
                                                    ..onTap = () =>
                                                        Navigator.pushNamed(
                                                            context,
                                                            'termsandcondition'),
                                            ),
                                            TextSpan(
                                              text: " and ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "Privacy Policy",
                                              style: TextStyle(
                                                color: Color(0xff073278),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              recognizer:
                                                  new TapGestureRecognizer()
                                                    ..onTap = () =>
                                                        Navigator.pushNamed(
                                                            context,
                                                            'privacypolicy'),
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
                            height: 10,
                          ),
                        ],
                      ),
                    )
                  ])))
            ],
          ),
        ),
      ),
    );
  }

////////// Api Implementation For RegistrationApi  //////////
  void registrationOfuser(
    BuildContext context,
    _formattedDate,
  ) async {
    List<RegisterResponseList> registerResponse;
    Map data = {
      'user_email': email.text,
      'confirm_email': conEmail.text,
      'password': password.text,
      'confirm_password': conPassword.text,
      'name': name.text,
      'last_name': lastName.text,
      'user_name': userName.text,
      'date_birth': _formattedDate,
      'gender': genderDropdownValue,
      'country': countryDropdownValue,
      'regional_organisation': regionalDropdownValue,
    };

    if (_formKey.currentState!.validate()) {
      final url = baseUrl + ApiEndPoints().register;
      var response = await http.post(Uri.parse(url), body: data);

      if (response.statusCode == 200) {
        List<RegisterResponseList> registerResponse = [];
        registerResponse
            .add(RegisterResponseList.fromJson(jsonDecode(response.body)));
        context.loaderOverlay.hide();
        RegisterResponseList newresponseList = registerResponse[0];

        if (registerResponse != null) {
          setState(() {
            isLoading = false;
          });
          await customDialog(context,
              message: newresponseList.message ?? "-",
              title: '${newresponseList.status == true ? "Success" : "Error"}');
          if (newresponseList.status == true) {
            setState(() {
              isLoading = false;
            });
            Navigator.pushNamed(context, 'login');
          }
        }

        print('success');
      } else {
        context.loaderOverlay.hide();
        customDialog(context, message: "Data not found", title: 'Error');
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}

/////////// Model ///////////
class RegisterResponseList {
  RegisterResponseList({
    this.status,
    this.error_code,
    this.userid,
    this.user_name,
    this.password,
    this.user_email,
    this.message,
  });

  bool? status;
  String? error_code;
  int? userid;
  String? user_name;
  String? password;
  String? user_email;
  String? message;

  factory RegisterResponseList.fromJson(Map<String, dynamic> json) {
    return RegisterResponseList(
        status: json["status"],
        error_code: json["error_code"],
        userid: json["user_id"],
        user_name: json["user_name"],
        password: json["password"],
        user_email: json["user_email"],
        message: json["message"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "error_code": error_code,
      "user_id": userid,
      "user_name": user_name,
      "password": password,
      "user_email": user_email,
      "message": message,
    };
  }
}
