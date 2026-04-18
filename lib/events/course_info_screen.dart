// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ofc_learn_v2/api/api.dart';
import 'package:flutter/material.dart';
import './registerevent.dart';

class CourseInfoScreen extends StatefulWidget {
  final eventId;
  const CourseInfoScreen(this.eventId);

  @override
  _CourseInfoScreenState createState() => _CourseInfoScreenState();
}

class _CourseInfoScreenState extends State<CourseInfoScreen>
    with TickerProviderStateMixin {
  var isLoading = false;

  @override
  void initState() {
    getEventDetails(context, widget.eventId);
    super.initState();
  }

  List<EventDetailsData> eventDetailsData = [];
  List<EventDetailsData> tempEventDetailsData = [];

  /////////// Api implementation for Get Event Details  /////////////
  Future<void> getEventDetails(BuildContext context, eventId) async {
    setState(() {
      isLoading = true;
    });

    var url = baseUrl + ApiEndPoints().eventList;
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<EventDetailsResponse> eventDetailsResponse = [];

      eventDetailsResponse
          .add(EventDetailsResponse.fromjson(jsonDecode(response.body)));
      EventDetailsResponse detailsResponse = eventDetailsResponse[0];
      if (detailsResponse.status == true && detailsResponse.error_code == "0") {
        if (detailsResponse.eventDetailsData != null) {
          tempEventDetailsData = detailsResponse.eventDetailsData!
              .where((event) => event.id == eventId)
              .toList();

          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      EventDetailsData eventDetails = tempEventDetailsData[0];
      return Container(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 205, 203, 203),
          appBar: AppBar(
            backgroundColor: Color(0xFF063278),
          ),
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: SingleChildScrollView(
                  child: Container(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Column(
                        children: [                          
                          Container(
                            child: eventDetails.event_thumbnail_image_link != null ? Image(
                              image: NetworkImage(
                                "${eventDetails.event_thumbnail_image_link}",
                              ),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.fill,
                            ) : Image(
                              image: AssetImage('assets/images/images.png'),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${eventDetails.event_title}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff073278),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.calendar_month,
                                      color: Color(0xff073278),
                                      size: 18,
                                    ),
                                    Text(
                                      "${eventDetails.event_start_date}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                        letterSpacing: 0.20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.public,
                                      color: Color(0xff073278),
                                      size: 18,
                                    ),
                                    Text(
                                      ' New Zealand Standard Time',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                        letterSpacing: 0.20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Your Speaker/s: ${eventDetails.display_name}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff073278),
                                  ),
                                ),
                                Text(
                                  "${eventDetails.event_excerpt}",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${eventDetails.event_content}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Color(0xff66C23D),
                                      ),
                                      child: Text(
                                        'Register Now',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (BuildContext context) =>
                                                Registerevent(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        child: Scaffold(
          backgroundColor: Color(0xffffffff),
          body: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }
  }
}

class EventDetailsResponse {
  bool? status;
  String? error_code;
  List<EventDetailsData>? eventDetailsData;

  EventDetailsResponse({
    this.status,
    this.error_code,
    this.eventDetailsData,
  });

  EventDetailsResponse.fromjson(Map<String, dynamic> json) {
    eventDetailsData = <EventDetailsData>[];
    status = json['status'];
    error_code = json['error_code'];
    eventDetailsData = (json['data'] as List)
        .map((e) => EventDetailsData.fromjson(e))
        .toList();
  }
}

class EventDetailsData {
  String? id;
  String? display_name;
  String? event_start_date;
  String? event_end_date;
  String? event_title;
  String? event_excerpt;
  String? event_name;
  String? event_type;
  String? event_status;
  String? event_content;
  String? event_thumbnail_image_link;
  String? event_link;

  EventDetailsData({
    this.id,
    this.display_name,
    this.event_start_date,
    this.event_end_date,
    this.event_title,
    this.event_excerpt,
    this.event_name,
    this.event_type,
    this.event_status,
    this.event_content,
    this.event_thumbnail_image_link,
    this.event_link,
  });

  EventDetailsData.fromjson(Map<String, dynamic> json) {
    id = json['ID'];
    display_name = json['display_name'];
    event_start_date = json['event_start_date'];
    event_end_date = json['event_end_date'];
    event_title = json['event_title'];
    event_excerpt = json['event_excerpt'];
    event_name = json['event_name'];
    event_type = json['event_type'];
    event_status = json['event_status'];
    event_content = json['event_content'];
    event_thumbnail_image_link = json['event_thumbnail_image_link'];
    event_link = json['event_link'];
  }
}
