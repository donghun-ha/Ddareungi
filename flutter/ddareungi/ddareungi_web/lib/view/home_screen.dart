import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final bool isTablet = ResponsiveBreakpoints.of(context).isTablet;

    final double initialZoom = isMobile
        ? 10.0
        : isTablet
            ? 10.5
            : 11.0;

    return Scaffold(
      appBar: (isMobile || isTablet)
          ? AppBar(
              title: const Text('따릉이 지도'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
      drawer: (isMobile || isTablet) ? _buildDrawer(colorScheme) : null,
      body: Row(
        children: [
          if (!isMobile && !isTablet)
            _buildSidebar(colorScheme), // 모바일/태블릿이 아닌 경우 항상 사이드바 표시
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(37.514575, 127.106597),
                    initialZoom: initialZoom,
                    minZoom: 9,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.ddareungi.web',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildSidebar(ColorScheme colorScheme) {
    final menuItems = [
      {'icon': Icons.grid_view, 'title': 'Dashboard'},
      {'icon': Icons.account_balance_wallet_outlined, 'title': 'Wallet'},
      {'icon': Icons.message_outlined, 'title': 'Messages'},
      {'icon': Icons.swap_horiz_outlined, 'title': 'Trade'},
      {'icon': Icons.settings_outlined, 'title': 'Account Setting'},
    ];

    return Container(
      width: 250,
      color: colorScheme.primaryContainer.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  radius: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  '송파구 관리자',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: Icon(item['icon'] as IconData,
                      color: colorScheme.primary),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    // 메뉴 클릭 시 동작 정의 가능
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Container(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        child: _buildSidebar(colorScheme),
      ),
    );
  }
}
