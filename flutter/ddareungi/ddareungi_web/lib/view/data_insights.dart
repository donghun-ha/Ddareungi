import 'package:ddareungi_web/view/rebalance_ai.dart';
import 'package:flutter/material.dart';
import 'package:ddareungi_web/constants/color.dart';
import 'package:get/get.dart';
import 'package:ddareungi_web/vm/data_insight_handler.dart';
import 'package:fl_chart/fl_chart.dart';

class DataInsight extends StatefulWidget {
  const DataInsight({super.key});

  @override
  State<DataInsight> createState() => _DataInsightState();
}

class _DataInsightState extends State<DataInsight> {
  final ScrollController scrollController = ScrollController();
  bool isHeaderVisible = false; // 고정 헤더 표시 여부

  final DataInsightHandler controller = Get.put(DataInsightHandler()); // 핸들러 등록

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() {
        isHeaderVisible =
            scrollController.offset > MediaQuery.of(context).size.height * 0.8;
      });
    });
    fetchStationData(); // 데이터 로드
  }

  void fetchStationData() {
    // 로그인한 유저의 지역 정보 사용
    const String userRegion = "송파구"; // 실제로는 로그인 핸들러에서 가져올 데이터
    controller.fetchStationData(userRegion);
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return Stack(
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
                  _buildStationChart(controller.stationData), // 차트 추가
                  footer(context),
                ],
              ),
            ),
            Visibility(
              visible: isHeaderVisible,
              child: _buildFixedHeader(context),
            ),
          ],
        );
      }),
      backgroundColor: backClr,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // 차트 위젯
  Widget _buildStationChart(List<dynamic> stationData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '정류소 주차 공간',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: stationData.asMap().entries.map((entry) {
                    int index = entry.key;
                    var data = entry.value;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data["parking_lot"].toDouble(),
                          width: 20,
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index >= stationData.length)
                            return const Text('');
                          return Text(
                            stationData[index]["station_code"],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
