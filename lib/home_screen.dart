import 'package:flutter/material.dart';
import 'package:ofc_learn_v2/activity/home_design_course.dart';
import 'package:ofc_learn_v2/course/home_design_course.dart';
import 'package:ofc_learn_v2/events/home_design_course.dart';
import 'package:ofc_learn_v2/groups/home_design_course.dart';
import 'package:ofc_learn_v2/library/home_design_course.dart';

class MyHomePage extends StatefulWidget {
  var indexValue;
  MyHomePage(this.indexValue);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // List<HomeList> homeList = HomeList.homeList;
  AnimationController? animationController;
  bool multiple = true;
  int _currentIndex = 0;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    _currentIndex = widget.indexValue;
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  final List<Widget> _children = [
    DesignCourseHomeScreen(),
    Course(),
    Events(),
    Groups(),
    Library(),
  ];

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF063278),
      body: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  appBar(),
                  Expanded(
                    child: FutureBuilder<bool>(
                      future: getData(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        } else {
                          return _children[_currentIndex];
                        }
                      },
                    ),
                  ),
                  BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Color(0xFF063278),
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white.withOpacity(.60),
                    selectedFontSize: 14,
                    unselectedFontSize: 14,
                    currentIndex: _currentIndex,
                    onTap: onTappedBar,
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_books),
                        label: 'Courses',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.event),
                        label: 'Events',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.groups),
                        label: 'Groups',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_add),
                        label: 'Library',
                      ),
                    ],
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget appBar() {
    return SizedBox(
      height: AppBar().preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 20),
                child: Image(
                  image: AssetImage(
                    'assets/images/logo.png',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeListView extends StatelessWidget {
  const HomeListView(
      {Key? key,
      // this.listData,
      // this.callBack,
      this.animationController,
      this.animation})
      : super(key: key);

  // final HomeList? listData;
  // final VoidCallback? callBack;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    // Positioned.fill(
                    //   child: Image.asset(
                    //     listData!.imagePath,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.grey.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        // onTap: callBack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
