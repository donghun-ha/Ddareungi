import 'package:ddareungi_web/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:ddareungi_web/view/data_insights.dart';
import 'package:ddareungi_web/view/rebalance_ai.dart';

class CompanyIntro extends StatelessWidget {
  const CompanyIntro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final bool isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      appBar: (isMobile || isTablet)
          ? AppBar(
              title: const Text('COMPANY INTRO'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            )
          : null,
      drawer: (isMobile || isTablet) ? _buildDrawer(context) : null,
      body: Row(
        children: [
          if (!isMobile && !isTablet) _buildDrawer(context),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: drawerContents(context),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title,
      VoidCallback onPressed, Color textColor) {
    // 현재 페이지 확인 로직 수정
    bool isCurrentPage = false;
    if (title == "COMPANY INTRO") {
      isCurrentPage = true; // CompanyIntro 페이지에서는 항상 true
    } else if (title == "REBALANCE AI" && Get.currentRoute == '/rebalance-ai') {
      isCurrentPage = false;
    } else if (title == "DATA INSIGHTS" &&
        Get.currentRoute == '/data-insights') {
      isCurrentPage = false;
    }

    return ListTile(
      title: TextButton(
        onPressed: onPressed, // 직접 onPressed 콜백 사용
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size(0, 0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          backgroundColor: isCurrentPage
              ? Colors.orange.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.035,
            fontWeight: FontWeight.bold,
            color: isCurrentPage ? Colors.orange : Colors.black,
          ),
        ),
      ),
    );
  }

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
                  size: MediaQuery.of(context).size.height * 0.04, // 아이콘 크기 조정
                  weight: 100,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(35, 60, 35, 20), // 패딩 조정
          child: Divider(
            color: Colors.black,
            thickness: MediaQuery.of(context).size.height * 0.002,
          ),
        ),
        _buildDrawerItem(
          context,
          "REBALANCE AI",
          () => Get.to(() => const RebalanceAi()),
          Colors.black,
        ),
        _buildDrawerItem(
          context,
          "DATA INSIGHTS",
          () => Get.to(() => const DataInsight()),
          Colors.black,
        ),
        _buildDrawerItem(
          context,
          "COMPANY INTRO",
          () => Get.to(() => const CompanyIntro()),
          Colors.orange, // 기본 색상을 주황색으로 설정
        ),
        _buildDrawerItem(
          context,
          "LOGOUT",
          () {
            // 로그아웃 기능 추가
          },
          Colors.black,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 600,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('images/ddareungi.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CycleSync',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 500,
            child: Text(
              '혁신적인 AI 기술로 더 나은 미래를 만들어갑니다',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Us',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 30),
          _buildInfoGrid(),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth > 800 ? 3 : 1,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.2,
          children: [
            _buildInfoCard(
              icon: Icons.psychology,
              title: 'AI Technology',
              description: '최첨단 AI 기술 개발',
            ),
            _buildInfoCard(
              icon: Icons.analytics,
              title: 'Data Analysis',
              description: '정확한 데이터 분석',
            ),
            _buildInfoCard(
              icon: Icons.trending_up,
              title: 'Innovation',
              description: '지속적인 혁신과 성장',
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
