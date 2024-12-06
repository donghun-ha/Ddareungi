import 'package:ddareungi_web/view/rebalance_ai.dart';
import 'package:flutter/material.dart';
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
  bool isHeaderVisible = false;

  final DataInsightHandler controller = Get.put(DataInsightHandler());

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() {
        isHeaderVisible =
            scrollController.offset > MediaQuery.of(context).size.height * 0.8;
      });
    });
    fetchStationData();
  }

  void fetchStationData() {
    const String userRegion = "송파구";
    controller.fetchStationPredictions(userRegion);
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
                  const SizedBox(height: 20),
                  _buildStationCharts(controller.stationData),
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
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _buildStationCharts(Map<String, List<dynamic>> stationData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: stationData.entries.map((entry) {
          final stationCode = entry.key;
          final predictions = entry.value;

          return Column(
            children: [
              // CR_COUNT 차트
              _buildStationChart(
                title: "CR Count for $stationCode",
                data: predictions,
                valueKey: "cr_count",
              ),
              const SizedBox(height: 20),
              // FILL_COUNT 차트
              _buildStationChart(
                title: "Fill Count for $stationCode",
                data: predictions,
                valueKey: "fill_count",
              ),
              const SizedBox(height: 40),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStationChart({
    required String title,
    required List<dynamic> data,
    required String valueKey,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // 상단 숫자 제거
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) {
                            return const Text('');
                          }
                          return Text(
                            data[value.toInt()]["time"],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        final index = entry.key.toDouble();
                        final value = entry.value[valueKey].toDouble();
                        return FlSpot(index, value);
                      }).toList(),
                      isCurved: true,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
