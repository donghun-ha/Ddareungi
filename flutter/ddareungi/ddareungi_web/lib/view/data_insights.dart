import 'package:ddareungi_web/model/responsive_config.dart';
import 'package:ddareungi_web/view/rebalance_ai.dart';
import 'package:flutter/material.dart';
import 'package:ddareungi_web/constants/color.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DataInsights extends StatefulWidget {
  const DataInsights({super.key});

  @override
  State<DataInsights> createState() => _DataInsightsState();
}

class _DataInsightsState extends State<DataInsights> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            drawerContents(context),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 첫 번째 스크롤 페이지
            Stack(
              children: [
                firstScrollRight(context),
                firstScrollLeft(context),
                firstScrollDrawer(context),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: backClr,
    );
  }
} // Functions

// Drawer Widget
Widget drawerContents(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, // 세로 정렬
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 30, 0),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.close_outlined,
                size: MediaQuery.of(context).size.height * 0.07,
                weight: 100,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(35, 100, 35, 20),
        child: Divider(
          color: Colors.black,
          thickness: MediaQuery.of(context).size.height * 0.002,
        ),
      ),
      ListTile(
        title: TextButton(
          onPressed: () {
            Get.off(
              () => const RebalanceAi(),
              transition: Transition.noTransition,
            );
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬
            minimumSize: const Size(0, 0), // 최소 크기 제거
          ),
          child: Text(
            "REBALANCE AI",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.06,
              fontWeight: FontWeight.bold,
              color: rebalanceDrawertxtClr,
            ),
          ),
        ),
      ),
      ListTile(
        title: TextButton(
          onPressed: () {
            Get.off(() => const DataInsights(),
                transition: Transition.noTransition);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬
            minimumSize: const Size(0, 0), // 최소 크기 제거
          ),
          child: Text(
            "DATA INSIGHTS",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      ListTile(
        title: TextButton(
          onPressed: () {
            //
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬
            minimumSize: const Size(0, 0), // 최소 크기 제거
          ),
          child: Text(
            "PROFILE",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      ListTile(
        title: TextButton(
          onPressed: () {
            //
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬
            minimumSize: const Size(0, 0), // 최소 크기 제거
          ),
          child: Text(
            "LOGOUT",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ],
  );
}

// rebalance_ai first scroll page
Widget firstScrollRight(BuildContext context) {
  // 배경 레이아웃
  return ResponsiveBreakpoints.builder(
    breakpoints: ResponsiveConfig.breakpoints,
    child: Row(
      children: [
        // 왼쪽 절반: 이미지
        Expanded(
          flex: 1,
          child: Image.asset(
            "../images/datainsights.png",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
          ),
        ),
        // 오른쪽 절반: 콘텐츠
        Expanded(
          flex: 1,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  "images/seoul_bike.png",
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "서울시 따릉이 대여 데이터를",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "한눈에 확인하세요!",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Text(
                    '이 페이지는 관리자에게 대여소 운영 현황을 직관적으로 제공합니다.',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.023,
                      color: rebalanceAiClr,
                    ),
                  ),
                  Text(
                    '스테이션별 대여 및 반납 추세, 시간대별 이용 패턴을 확인할 수 있습니다.',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.023,
                      color: rebalanceAiClr,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// first_page_scroll_right
Widget firstScrollLeft(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft, // 왼쪽 상단에 고정
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Image.asset(
        "images/logo.png",
        width: MediaQuery.of(context).size.width * 0.2,
        fit: BoxFit.contain,
      ),
    ),
  );
}

// first_page_menu
Widget firstScrollDrawer(BuildContext context) {
  return Positioned(
    top: 16,
    right: 16,
    child: Builder(
      builder: (context) => IconButton(
        icon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
          child: Icon(
            Icons.menu,
            size: MediaQuery.of(context).size.height * 0.06,
          ),
        ),
        onPressed: () {
          Scaffold.of(context).openEndDrawer();
        },
      ),
    ),
  );
}
