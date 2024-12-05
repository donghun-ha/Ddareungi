import 'package:ddareungi_web/view/data_insights.dart';
import 'package:ddareungi_web/view/rebalance_ai.dart';
import 'package:ddareungi_web/vm/profile_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ddareungi_web/constants/color.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final ProfileHandler controller = Get.put(ProfileHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            drawerContents(context), // Drawer
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              header(context),
              // Main Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Manage your personal information and account settings here.",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            color: rebalanceAiClr,
                          ),
                        ),
                        const SizedBox(height: 32),
                        profileDetails(context),
                      ],
                    ),
                  );
                }),
              ),
              // Footer
              footer(context),
            ],
          ),
        ],
      ),
      backgroundColor: backClr,
    );
  }

  // Header Widget
  Widget header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => Profile());
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

  // Profile Details Section
  Widget profileDetails(BuildContext context) {
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
          profileDetailRow("Email", controller.id.value),
          const Divider(),
          profileDetailRow("Region", controller.region.value),
        ],
      ),
    );
  }

  // Profile Detail Row
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

  // Drawer Widget (Reused)
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
              Get.off(() => Profile(), transition: Transition.noTransition);
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

  // Footer Widget
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
