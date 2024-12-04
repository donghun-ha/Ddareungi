import 'package:ddareungi_web/model/responsive_config.dart';
import 'package:ddareungi_web/view/data_insights.dart';
import 'package:flutter/material.dart';
import 'package:ddareungi_web/constants/color.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_framework/responsive_framework.dart';

class RebalanceAi extends StatefulWidget {
  const RebalanceAi({super.key});

  @override
  State<RebalanceAi> createState() => _RebalanceAiState();
}

class _RebalanceAiState extends State<RebalanceAi> {
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final bool isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final double initialZoom = isMobile
        ? 10.0
        : isTablet
            ? 10.5
            : 11.0;

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
            SizedBox(height: MediaQuery.of(context).size.height * 0.5),
            mapFuntion(context, mapController, initialZoom),
          ],
        ),
      ),
      backgroundColor: backClr,
    );
  }
} // End

// Functions

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
            "images/ddareungi.png",
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
                    "따릉이 재배치로",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "더 나은 서비스를 제공하세요!",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Text(
                    '서울시 자전거 대여소 데이터를 분석하여 최적의 재배치 시간을 추천합니다.',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.023,
                      color: rebalanceAiClr,
                    ),
                  ),
                  Text(
                    '효율적인 운영과 이용자 편의를 동시에 만족시키는 통합 관리 플랫폼.',
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

// Map functions
Widget mapFuntion(
    BuildContext context, MapController mapController, double initialZoom) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.8,
    height: MediaQuery.of(context).size.height * 0.8,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
    child: FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(37.514575, 127.106597),
        initialZoom: initialZoom,
        minZoom: 9,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.ddareungi.web',
        )
      ],
    ),
  );
}
