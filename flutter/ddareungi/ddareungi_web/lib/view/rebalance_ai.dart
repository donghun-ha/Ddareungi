import 'dart:convert';
import 'package:ddareungi_web/model/manage.dart';
import 'package:ddareungi_web/model/station.dart';
import 'package:ddareungi_web/utils/responsive_config.dart';
import 'package:ddareungi_web/view/data_insights.dart';
import 'package:ddareungi_web/vm/manage_handler.dart';
import 'package:ddareungi_web/vm/station_controller.dart';
import 'package:flutter/material.dart';
import 'package:ddareungi_web/constants/color.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_framework/responsive_framework.dart';

class RebalanceAi extends StatefulWidget {
  const RebalanceAi({super.key});

  @override
  State<RebalanceAi> createState() => _RebalanceAiState();
}

class _RebalanceAiState extends State<RebalanceAi> {
  final ScrollController scrollController = ScrollController();
  final MapController mapController = MapController();
  final StationController stationController = StationController();
  late Future<List<Station>> futureStations;
  Future<List<Manage>>? futureManageData;
  bool isHeaderVisible = false;

  Station? selectedStation; // 스테이션 정보

  @override
  void initState() {
    super.initState();
    futureStations = fetchStations();
    scrollController.addListener(() {
      setState(() {
        isHeaderVisible =
            scrollController.offset > MediaQuery.of(context).size.height * 0.8;
      });
    });
  }

  void onStationSelected(Station station) {
    if (selectedStation?.name != station.name) {
      setState(() {
        selectedStation = station;
        futureManageData =
            ManageHandler().fetchManageDataByStationName(station.name);
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<List<Station>> fetchStations() async {
    final url = Uri.parse('http://127.0.0.1:8000/map/stations');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map<Station>((json) => Station.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                myStation(context),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: mapFuntion(context, mapController, futureStations),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                hintText(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                stationName(context, futureStations, mapController, (station) {
                  setState(() {
                    selectedStation = station;
                  });
                }),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                analysisResults(context, selectedStation, futureManageData),
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
}

// 고정 헤더
Widget _buildFixedHeader(BuildContext context) {
  return Container(
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
  );
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
 Get.off(() => const CompanyIntro(), transition: Transition.noTransition);
            // 다른 기능 추가 가능
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(0, 0),
          ),
          child: Text(
            "COMPANY INTRO",
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
            "images/ddareungi.png",
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

// Text Widget
Widget myStation(BuildContext context) {
  return Padding(
    padding:
        EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width * 0.54, 0),
    child: Text(
      "My Management Area",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: MediaQuery.of(context).size.height * 0.05,
      ),
    ),
  );
}

// 스테이션 클릭
Widget stationName(BuildContext context, Future<List<Station>> futureStations,
    MapController mapController, Function(Station) onStationSelected) {
  return FutureBuilder<List<Station>>(
    future: futureStations,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        final stations = snapshot.data!;
        final displayedStations = stations.take(3).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayedStations.map((station) {
            return GestureDetector(
              onTap: () {
                mapController.move(LatLng(station.lat, station.lng), 15.0);
                onStationSelected(station); // 부모 상태 업데이트 콜백 호출
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFFFE1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB0E0E6),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  station.name,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      } else {
        return const Text('No stations available');
      }
    },
  );
}

// flutter Map
Widget mapFuntion(BuildContext context, MapController mapController,
    Future<List<Station>> futureStations) {
  return FutureBuilder<List<Station>>(
    future: futureStations,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        final stations = snapshot.data!;
        int colorIndex = 0; // 초기값 설정
        final markers = stations.map((station) {
          // 마커 색상 배열 정의
          final List<Color> markerColors = [
            Colors.green,
            Colors.blue,
            Colors.red
          ];
          colorIndex = (colorIndex + 1) % markerColors.length; // 0, 1, 2 반복
          return Marker(
            point: LatLng(station.lat, station.lng),
            width: 80, // 넓이를 더 크게 설정
            height: 80, // 높이를 더 크게 설정
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 투명 배경
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.location_on,
                  color: markerColors[colorIndex],
                  size: 40,
                ),
              ],
            ),
          );
        }).toList();

        return FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: LatLng(37.517653, 127.105453),
            initialZoom: 15,
            minZoom: 9,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.ddareungi.web',
            ),
            MarkerLayer(markers: markers),
          ],
        );
      } else {
        return const Center(child: Text('No data available'));
      }
    },
  );
}

Widget hintText(BuildContext context) {
  return Text(
    "The map moves when the button below is clicked.",
    style: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: MediaQuery.of(context).size.height * 0.02,
      color: logintxtClr,
    ),
  );
}

String convertStandardTime(String standardTime) {
  if (standardTime.length != 6) return standardTime; // 기본적으로 길이 체크

  String month = standardTime.substring(0, 2);
  String day = standardTime.substring(2, 4);
  String hour = standardTime.substring(4, 6);

  return '$month월 $day일 $hour시';
}

Widget analysisResults(
    BuildContext context, Station? selectedStation, cachedManageData) {
  final manageHandler = ManageHandler();

  if (selectedStation == null) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              0, 0, MediaQuery.of(context).size.width * 0.6, 0),
          child: Text(
            "Station Analytics",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height * 0.04,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "Click a station to see the details.",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.025,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  // 캐싱된 데이터를 사용
  if (cachedManageData == null || selectedStation.name != cachedManageData) {
    cachedManageData ??=
        manageHandler.fetchManageDataByStationName(selectedStation.name);
  }

  return FutureBuilder<List<Manage>>(
    future: cachedManageData,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text("Error: ${snapshot.error}");
      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        final manageData = snapshot.data!;
        final rebalancingTimes = manageData
            .where((data) => data.fillCount > 0)
            .map((data) => convertStandardTime(data.standardTime.toString()))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  0, 0, MediaQuery.of(context).size.width * 0.6, 0),
              child: Text(
                "Station Analytics - ${selectedStation.name}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.04,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rebalancing Required Times",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (rebalancingTimes.isEmpty)
                    Text(
                      "향후 24시간 동안 재배치가 필요하지 않습니다.",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        color: Colors.black54,
                      ),
                    )
                  else
                    Column(
                      children: rebalancingTimes.map((time) {
                        return Text(
                          "Time: $time",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        );
      } else {
        return const Center(
          child: Text("향후 24시간 동안 재배치가 필요하지 않습니다."),
        );
      }
    },
  );
}

// Footer
Widget footer(BuildContext context) {
  return Column(
    children: [
      Text(
        "© Copyright 2024 CycleSync",
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.02,
        ),
      )
    ],
  );
}
