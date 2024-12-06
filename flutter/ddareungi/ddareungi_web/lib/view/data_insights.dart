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

  Widget _buildStationCharts(Map<String, List<dynamic>> stationData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: stationData.entries.map((entry) {
          final stationCode = entry.key;
          final predictions = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                _buildStationChart(
                  title: "$stationCode 대여/반납 예측",
                  data: predictions,
                  valueKey: "cr_count",
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                _buildStationChart(
                  title: "$stationCode 재배치 필요량",
                  data: predictions,
                  valueKey: "fill_count",
                  color: Colors.green,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStationChart({
    required String title,
    required List<dynamic> data,
    required String valueKey,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: _getMinY(data, valueKey),
                  maxY: _getMaxY(data, valueKey),
                  clipData: const FlClipData.all(),
                  backgroundColor: Colors.white,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 20,
                    drawVerticalLine: true,
                    verticalInterval: 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length)
                            return const Text('');
                          return Text(
                            data[value.toInt()]["time"],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value[valueKey].toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      barWidth: 2,
                      color: color,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 2,
                          color: Colors.white,
                          strokeWidth: 1.5,
                          strokeColor: color,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
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

  double _getMinY(List<dynamic> data, String valueKey) {
    double min = double.infinity;
    for (var item in data) {
      if (item[valueKey].toDouble() < min) {
        min = item[valueKey].toDouble();
      }
    }
    return (min - 10).floorToDouble();
  }

  double _getMaxY(List<dynamic> data, String valueKey) {
    double max = double.negativeInfinity;
    for (var item in data) {
      if (item[valueKey].toDouble() > max) {
        max = item[valueKey].toDouble();
      }
    }
    return (max + 10).ceilToDouble();
  }

  Widget _buildFixedHeader(BuildContext context) {
    return AnimatedOpacity(
      opacity: isHeaderVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: 80,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(
                () => const RebalanceAi(),
                transition: Transition.noTransition,
              ),
              child: Image.asset(
                "images/logo.png",
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

Widget footer(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Text(
      "© Copyright 2024 CycleSync",
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    ),
  );
}
