import 'package:auto_size_text/auto_size_text.dart';
import 'package:ofc_learn_v2/events/course_info_screen.dart';
import 'package:ofc_learn_v2/events/models/category.dart';
import 'package:ofc_learn_v2/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ofc_learn_v2/api/api.dart';

class PopularCourseListView extends StatefulWidget {
  const PopularCourseListView({Key? key, this.callBack}) : super(key: key);

  final Function()? callBack;
  @override
  _PopularCourseListViewState createState() => _PopularCourseListViewState();
}

class _PopularCourseListViewState extends State<PopularCourseListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  var isLoading = false;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    getEventList(context);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1));
    return true;
  }

  /////////// Event List API  /////////////
  List<EventListData> eventListData = [];
  List<EventListData> tempEventListData = [];

  Future<void> getEventList(
    BuildContext context,
  ) async {
    isLoading = true;
    var url = baseUrl + ApiEndPoints().eventList;
    var response = await http.get(Uri.parse(url));

    isLoading = false;

    if (response.statusCode == 200) {
      List<EventListResponse> eventListResponse = [];
      eventListResponse
          .add(EventListResponse.fromjson(jsonDecode(response.body)));
      EventListResponse eventResponse = eventListResponse[0];
      if (eventResponse.status == true && eventResponse.error_code == "0") {
        if (eventResponse.eventListData != null) {
          var data = eventResponse.eventListData;
          List<EventListData> eventListData = [];

          for (var e in data!) {
            eventListData.add(e);
          }
          setState(() {
            tempEventListData = eventListData;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return GridView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                CategoryView(
                  tempEventListData: tempEventListData,
                  animationController: animationController,
                  // scrollController: scrollController,
                  callback: widget.callBack,
                  isLoading: isLoading,
                ),
              ],
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 32.0,
                crossAxisSpacing: 32.0,
                childAspectRatio: 0.8,
              ),
            );
          }
        },
      ),
    );
  }
}

class CategoryView extends StatefulWidget {
  const CategoryView({
    Key? key,
    this.tempEventListData,
    this.animationController,
    this.animation,
    this.callback,
    this.isLoading,
  }) : super(key: key);

  final VoidCallback? callback;
  final tempEventListData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final isLoading;

  @override
  _CategoryView createState() => _CategoryView();
}

class _CategoryView extends State<CategoryView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        // controller: widget.scrollController,
        itemCount: widget.isLoading
            ? widget.tempEventListData.length + 1
            : widget.tempEventListData.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 32.0,
          mainAxisSpacing: 32.0,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          if (index < widget.tempEventListData.length) {
            final int count = widget.tempEventListData.length;
            final Animation<double> animation =
                Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );

            // ListGetGroup getGroup = tempGroupCourse[index];
            widget.animationController?.forward();

            final eventListData = widget.tempEventListData[index];
            return AnimatedBuilder(
                animation: widget.animationController!,
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                    opacity: animation,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 50 * (1.0 - animation.value), 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        // onTap: widget.callback,

                        // child: GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseInfoScreen(eventListData!.id),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 280,
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: HexColor('#F8FAFB'),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20.0)),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                elevation: 20,
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 8,
                                                                left: 10,
                                                                right: 10),
                                                        child: AutoSizeText(
                                                          "${eventListData!.event_title}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            letterSpacing: 0.27,
                                                            color: Color(
                                                                0xff073278),
                                                          ),
                                                          minFontSize: 10,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: Row(
                                                          children: <Widget>[
                                                            AutoSizeText(
                                                              "${eventListData!.event_start_date}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                fontSize: 10,
                                                                letterSpacing:
                                                                    0.27,
                                                                color: Color(
                                                                    0xff073278),
                                                              ),
                                                              minFontSize: 8,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 48,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 48,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 24, right: 16, left: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0)),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Color(0xff073278)
                                                .withOpacity(0.2),
                                            offset: const Offset(0.0, 0.0),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0)),
                                      child: AspectRatio(
                                        aspectRatio: 1.28,
                                        child: eventListData
                                                    .event_thumbnail_image_link !=
                                                null
                                            ? Image(
                                                image: NetworkImage(
                                                  "${eventListData!.event_thumbnail_image_link}",
                                                ),
                                                width: 300,
                                                height: 180,
                                                fit: BoxFit.fill,
                                              )
                                            : Image(
                                                image: AssetImage(
                                                    'assets/images/images.png'),
                                                width: double.infinity,
                                                height: 180,
                                                fit: BoxFit.fill,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // ),
                      ),
                    ),
                  );
                });
          } else {
            return Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
