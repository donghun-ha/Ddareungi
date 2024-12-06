import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Companyintro extends StatefulWidget {
  const Companyintro({super.key});

  @override
  State<Companyintro> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<Companyintro> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
      drawer: (isMobile || isTablet) ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!isMobile && !isTablet) _buildSidebar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: _buildSidebar(),
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      {'title': 'COMPANY INTOR', 'index': 0},
      {'title': 'DATA INSIGHTS', 'index': 1},
      {'title': 'HOME', 'index': 2},
      {'title': 'LOGOUT', 'index': 3},
    ];

    return Container(
      width: 250,
      color: Colors.white,
      child: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            title: Text(
              item['title'] as String,
              style: TextStyle(
                color: index == _selectedIndex ? Colors.orange : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = item['index'] as int;
              });
              if (ResponsiveBreakpoints.of(context).isMobile ||
                  ResponsiveBreakpoints.of(context).isTablet) {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildMainContent();
      case 1:
        return _buildDataInsights();
      case 2:
        return _buildLogout();
      default:
        return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        // 배경 이미지
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              _buildInfoSection(),
            ],
          ),
        ),
      ],
    );
  }
Widget _buildHeroSection() {
  return Container(
    height: 600,
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 40),
    decoration: BoxDecoration(
      image: DecorationImage(
        image: const AssetImage(
          'images/ddareungi.png',
          ),
        fit: BoxFit.cover,
        alignment: const Alignment(0, 0.3),
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
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

  Widget _buildDataInsights() {
    return const Center(child: Text('Data Insights Page'));
  }


  Widget _buildLogout() {
    return const Center(child: Text('Logout Page'));
  }
}
