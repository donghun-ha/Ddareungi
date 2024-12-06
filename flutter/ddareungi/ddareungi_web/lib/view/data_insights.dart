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
                _buildCombinedChart(
                  title: "$stationCode 대여/반납 예측건수",
                  data: predictions,
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

  Widget _buildCombinedChart({
    required String title,
    required List<dynamic> data,
  }) {
    double maxValue = 0;
    double minValue = double.infinity;

    // 최대/최소값 계산
    for (var item in data) {
      if (item["rent"].toDouble() > maxValue) {
        maxValue = item["rent"].toDouble();
      }
      if (item["restore"].toDouble() > maxValue) {
        maxValue = item["restore"].toDouble();
      }
      if (item["rent"].toDouble() < minValue) {
        minValue = item["rent"].toDouble();
      }
      if (item["restore"].toDouble() < minValue) {
        minValue = item["restore"].toDouble();
      }
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLegend("대여", Colors.blue),
                const SizedBox(width: 16),
                _buildLegend("반납", Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: minValue - 20,
                  maxY: maxValue + 20,
                  clipData: const FlClipData.all(),
                  backgroundColor: Colors.white,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    drawVerticalLine: true,
                    verticalInterval: 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 0.8,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 0.8,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          '시간',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) {
                            return const Text('');
                          }
                          return Text(
                            data[value.toInt()]["time"],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
                          entry.value["rent"].toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      barWidth: 2.5,
                      color: Colors.blue,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 1.5,
                          strokeColor: Colors.blue,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.2),
                            Colors.blue.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value["restore"].toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      barWidth: 2.5,
                      color: Colors.red,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 1.5,
                          strokeColor: Colors.red,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.2),
                            Colors.red.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStationChart({
    required String title,
    required List<dynamic> data,
    required String valueKey,
    required Color color,
  }) {
    double maxValue = 0;
    double minValue = double.infinity;

    for (var item in data) {
      if (item[valueKey].toDouble() > maxValue) {
        maxValue = item[valueKey].toDouble();
      }
      if (item[valueKey].toDouble() < minValue) {
        minValue = item[valueKey].toDouble();
      }
    }

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
                  minY: minValue - 20,
                  maxY: maxValue + 20,
                  clipData: const FlClipData.all(),
                  backgroundColor: Colors.white,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    drawVerticalLine: true,
                    verticalInterval: 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 0.8,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 0.8,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          '시간',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) {
                            return const Text('');
                          }
                          return Text(
                            data[value.toInt()]["time"],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
                      barWidth: 2.5,
                      color: color,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 1.5,
                          strokeColor: color,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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
