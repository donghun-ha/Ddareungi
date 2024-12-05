import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ddareungi_web/view/rebalance_ai.dart';
import 'package:ddareungi_web/view/data_insights.dart';
import 'package:ddareungi_web/view/login_screen.dart';
import 'package:ddareungi_web/constants/color.dart';
import 'package:ddareungi_web/vm/profile_handler.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileHandler controller = Get.find<ProfileHandler>();

    return Scaffold(
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: ListView(
          padding: EdgeInsets.zero,
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
                  Get.off(() => const RebalanceAi(),
                      transition: Transition.noTransition);
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
                    color: rebalanceDrawertxtClr, // 메인 화면과 동일한 색상
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
                  Get.off(() => const Profile(),
                      transition: Transition.noTransition);
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
                  Get.offAll(() => LoginScreen(),
                      transition: Transition.noTransition);
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
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              header(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() => profileDetails(context, controller)),
                ),
              ),
              footer(context),
            ],
          ),
        ],
      ),
      backgroundColor: backClr,
    );
  }

  // Header
  Widget header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => const Profile());
            },
            child: Image.asset(
              "images/logo.png",
              width: MediaQuery.of(context).size.width * 0.2,
              fit: BoxFit.contain,
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 32),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Profile Details
  Widget profileDetails(BuildContext context, ProfileHandler controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileDetailRow("ID", controller.id.value),
          const Divider(),
          profileDetailRow("Region", controller.region.value), // 지역 표시
        ],
      ),
    );
  }

  Widget profileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Footer
  Widget footer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "© Copyright 2024 CycleSync",
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.02,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
