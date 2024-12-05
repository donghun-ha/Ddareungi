import 'package:ddareungi_web/model/responsive_config.dart';
import 'package:ddareungi_web/view/rebalance_ai.dart';
import 'package:flutter/material.dart';
import 'package:ddareungi_web/constants/color.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DataInsight extends StatefulWidget {
  const DataInsight({super.key});

  @override
  State<DataInsight> createState() => _DataInsightState();
}

class _DataInsightState extends State<DataInsight> {
  final ScrollController scrollController = ScrollController();
  bool isHeaderVisible = false; // 고정 헤더 표시 여부

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() {
        // 두 번째 화면부터 헤더 표시
        isHeaderVisible =
            scrollController.offset > MediaQuery.of(context).size.height * 0.8;
      });
    });
  }

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
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Stack(
                  children: [
                    firstScrollRight(context),
                    firstScrollLeft(context),
                    firstScrollDrawer(context),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.5),
                SizedBox(height: MediaQuery.of(context).size.height * 0.5),
                footer(context),
              ],
            ),
          ),
          Visibility(
            visible: isHeaderVisible,
            child: _buildFixedHeader(context),
          ),
        ],
      ),
      backgroundColor: backClr,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // 고정 헤더
  Widget _buildFixedHeader(BuildContext context) {
    return AnimatedOpacity(
      opacity: isHeaderVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        height: 80,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => const RebalanceAi(),
                    transition: Transition.noTransition);
              },
              child: Image.asset(
                "images/logo.png",
                width: MediaQuery.of(context).size.width * 0.2,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Drawer Widget
Widget drawerContents(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
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
            alignment: Alignment.centerLeft,
            minimumSize: const Size(0, 0),
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
            Get.off(() => const DataInsight(),
                transition: Transition.noTransition);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(0, 0),
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
            // 다른 기능 추가 가능
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(0, 0),
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
            // 로그아웃 기능 추가
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(0, 0),
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

// 첫 번째 화면 우측 레이아웃
Widget firstScrollRight(BuildContext context) {
  return ResponsiveBreakpoints.builder(
    breakpoints: ResponsiveConfig.breakpoints,
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Image.asset(
            "images/dataInsights.png",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
          ),
        ),
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

// 첫 번째 화면 좌측 로고
Widget firstScrollLeft(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          Get.to(() => const RebalanceAi(),
              transition: Transition.noTransition); // 로고 클릭 시 이동
        },
        child: Image.asset(
          "images/logo.png",
          width: MediaQuery.of(context).size.width * 0.2,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

// 첫 번째 화면 메뉴 버튼
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

// Footer
Widget footer(BuildContext context) {
  return Container(
    child: Column(
      children: [
        Text(
          "© Copyright 2024 CycleSync",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.02,
          ),
        )
      ],
    ),
  );
}
