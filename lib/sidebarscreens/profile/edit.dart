// ignore_for_file: non_constant_identifier_names, unused_import
import 'dart:convert';
import 'package:ofc_learn_v2/api/api.dart';
import 'package:ofc_learn_v2/comman/custome_dialog.dart';
import 'package:ofc_learn_v2/groups/feed.dart';
import 'package:ofc_learn_v2/sidebarscreens/profile/profile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Edit extends StatefulWidget {
  @override
  _Edit createState() => _Edit();
}

class _Edit extends State<Edit> with TickerProviderStateMixin {
  int _currentIndex = 1;
  bool isLoading = false;
  final _firstnamecontroller = TextEditingController();
  final _nicknamecontroller = TextEditingController();
  final _lastnamecontroller = TextEditingController();
  final _userIdcontroller = TextEditingController();

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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

  void editprofile(
    BuildContext context,
    userId,
    firstName,
    nickName,
    lastName,
    _formattedDate,
    genderDropdownValue,
    countryDropdownValue,
    regionalDropdownValue,
  ) async {
    List<ProfileEditResponse> profileEditResponse;
    setState(() {
      isLoading = true;
    });
    var url = baseUrl + ApiEndPoints().editprofile;
    print("_formattedDate");
    print(_formattedDate);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('isUserId');

    Map editprofileParams = {
      'user_id': userId.toString(),
      'first_name': firstName,
      'last_name': lastName,
      'nick_name': nickName,
      'date_of_birth': _formattedDate,
      'gender': genderDropdownValue,
      'country': countryDropdownValue,
      'regional': regionalDropdownValue,
    };

    var response = await http.post(Uri.parse(url), body: editprofileParams);
    setState(() {
      isLoading = false;
    });
    print(response.body);
    if (response.statusCode == 200) {
      profileEditResponse = <ProfileEditResponse>[];
      profileEditResponse
          .add(ProfileEditResponse.fromJson(jsonDecode(response.body)));

      ProfileEditResponse profileEditRes = profileEditResponse[0];

      await customDialog(
        context,
        message: profileEditRes.message,
      );

      setState(() {
        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Profile(),
          ),
        );
      });
    } else {
      print('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    String _formattedDate = DateFormat('MM/dd/yyyy').format(_selectedDate);

    return Column(
      children: <Widget>[
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_currentIndex == 1) ...[
                    Text(
                      "Edit Profile Information",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff073278),
                        fontSize: 20,
                      ),
                    ),
                  ] else if (_currentIndex == 2) ...[
                    Text(
                      "Edit Age Group Information",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff073278),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => onTappedBar(1),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: Color(0xff073278),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ButtonStyle(),
                  ),
                  TextButton(
                    onPressed: () => onTappedBar(2),
                    child: Text(
                      'Age Group',
                      style: TextStyle(
                        color: Color(0xff073278),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ButtonStyle(),
                  ),
                ],
              ),
              Column(
                children: [
                  if (_currentIndex == 1) ...[
                    Column(
                      children: [
                        TextField(
                          controller: _firstnamecontroller,
                          decoration: InputDecoration(
                            labelText: 'First name',
                          ),
                        ),
                        //     ),
                        SizedBox(
                          height: 20,
                        ),

                        TextField(
                          controller: _nicknamecontroller,
                          decoration: InputDecoration(
                            labelText: 'Nick name',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        TextField(
                          controller: _lastnamecontroller,
                          decoration: InputDecoration(labelText: 'Last name'),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "$_formattedDate",
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
                          height: 20,
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
                                        color: Color.fromARGB(255, 42, 41, 41),
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
                          height: 20,
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
                                      value: countryDropdownValue,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      isExpanded: true,
                                      elevation: 16,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 42, 41, 41),
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
                          height: 20,
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                  // flex: 1,
                                  child: DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                // alignedDropdown: true,
                                child: DropdownButton<String>(
                                  // isDense: true,
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
                          height: 20,
                        ),
                      ],
                    ),
                  ] else if (_currentIndex == 2) ...[
                    About(),
                  ],
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Color(0xff66C23D),
                    ),
                    onPressed: () {
                      editprofile(
                          context,
                          _userIdcontroller.text,
                          _firstnamecontroller.text,
                          _nicknamecontroller.text,
                          _lastnamecontroller.text,
                          _formattedDate,
                          genderDropdownValue,
                          countryDropdownValue,
                          regionalDropdownValue);
                    },
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Change',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                  ),
                ],
              ),
            ]),
          ),
        )
      ],
    );
  }
}

enum SingingCharacter { first, secound, thired, four }

class About extends StatefulWidget {
  About({Key? key}) : super(key: key);

  @override
  _About createState() => _About();
}

class _About extends State<About> {
  SingingCharacter? _character = SingingCharacter.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            SizedBox(
              width: 15,
            ),
            Text(
              "Age Groups",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        ListTile(
          title: const Text('5-8 year olds'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.first,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('9-12 year olds'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.secound,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('13-18 year olds'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.thired,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('19+ year olds'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.four,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

// class Country extends StatefulWidget {
//   const Country({Key? key}) : super(key: key);

//   @override
//   State<Country> createState() => _Country();
// }

// class _Country extends State<Country> {
//   String dropdownValue = 'Country';

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 DropdownButton<String>(
//                   value: dropdownValue,
//                   icon: const Icon(Icons.arrow_drop_down),
//                   isExpanded: true,
//                   elevation: 16,
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 42, 41, 41),
//                   ),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       dropdownValue = newValue!;
//                     });
//                   },
//                   items: <String>[
//                     'Country',
//                     'Afghanistan',
//                     'Albania',
//                     'Algeria',
//                     'Andorra',
//                     'India',
//                     'USA',
//                   ].map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Container(
//                         child: Text(
//                           value,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Regional extends StatefulWidget {
//   const Regional({Key? key}) : super(key: key);

//   @override
//   State<Regional> createState() => _Regional();
// }

// class _Regional extends State<Regional> {
//   String dropdownValue2 = 'Regional';

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 DropdownButton<String>(
//                   value: dropdownValue2,
//                   icon: const Icon(Icons.arrow_drop_down),
//                   isExpanded: true,
//                   elevation: 16,
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 42, 41, 41),
//                   ),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       dropdownValue2 = newValue!;
//                     });
//                   },
//                   items: <String>[
//                     'Regional',
//                     'FJ-fiji football assocition',
//                     'NC',
//                     'NZ',
//                     'PF',
//                   ].map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Container(
//                         child: Text(
//                           value,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ProfileEditResponse {
  bool status;
  String error_code;
  String message;

  ProfileEditResponse({
    required this.status,
    required this.error_code,
    required this.message,
  });

  factory ProfileEditResponse.fromJson(Map<String, dynamic> json) {
    return ProfileEditResponse(
      status: json['status'],
      error_code: json['error_code'],
      message: json['message'],
    );
  }
}
