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
    final bool isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return Scaffold(
      appBar: (isMobile || isTablet)
          ? AppBar(
              title: const Text('따릉이 지도'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
      drawer: (isMobile || isTablet) ? _buildDrawer(colorScheme) : null,
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline, width: 1),
        ),
        child: ResponsiveRowColumn(
          layout: isDesktop
              ? ResponsiveRowColumnType.ROW
              : ResponsiveRowColumnType.COLUMN,
          children: [
            if (isDesktop)
              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.1),
                    border: Border(
                      right: BorderSide(color: colorScheme.outline, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: _buildDesktopMenu(colorScheme),
                ),
              ),
            ResponsiveRowColumnItem(
              rowFlex: isDesktop ? 4 : 1,
              columnFlex: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 16 : 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              onMapReady: () {
                                _mapController.move(
                                  const LatLng(37.514575, 127.106597),
                                  isMobile
                                      ? 10.0
                                      : isTablet
                                          ? 10.5
                                          : 11.0,
                                );
                              },
                              minZoom: 9,
                              maxZoom: 18,
                              keepAlive: true,
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
                      Padding(
                        padding: EdgeInsets.all(isDesktop ? 16 : 8),
                        child: Text(
                          '클릭하면 해당 구역으로 이동합니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Container(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        child: _buildDesktopMenu(colorScheme),
      ),
    );
  }

  _buildDesktopMenu(ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary,
                radius: 25,
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: colorScheme.onSurfaceVariant,
                radius: 25,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '송파구 관리자',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 40),
          _buildMenuItem(Icons.grid_view, 'Dashboard', colorScheme.primary),
          _buildMenuItem(Icons.account_balance_wallet_outlined, 'Wallet',
              colorScheme.onSurfaceVariant),
          _buildMenuItem(
              Icons.message_outlined, 'Messages', colorScheme.onSurfaceVariant),
          _buildMenuItem(
              Icons.swap_horiz_outlined, 'Trade', colorScheme.onSurfaceVariant),
          _buildMenuItem(Icons.settings_outlined, 'Account Setting',
              colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  _buildMenuItem(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
