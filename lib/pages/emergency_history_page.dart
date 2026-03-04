import 'package:flutter/material.dart';

import '../utils/nav_utils.dart';
import '../widgets/main_bottom_nav.dart';
import 'emergency_page.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

class EmergencyHistoryPage extends StatefulWidget {
  const EmergencyHistoryPage({super.key});

  @override
  State<EmergencyHistoryPage> createState() => _EmergencyHistoryPageState();
}

class _EmergencyHistoryPageState extends State<EmergencyHistoryPage> {
  int _activeTab = 0;

  final List<_HistoryItem> _items = const [
    _HistoryItem(
      title: 'EMERGENCY SOS',
      dateTime: 'Oct 24, 2023 - 10:45 PM',
      address: '123 Innovation Dr, San Francisco, CA. Rapid...',
      status: 'TRIGGERED',
      statusColor: Color(0xFFF15B5B),
      timelineIcon: Icons.close_rounded,
      timelineColor: Color(0xFFE05858),
      previewColor: Color(0xFF92A7A3),
    ),
    _HistoryItem(
      title: 'SAFETY CHECK',
      dateTime: 'Oct 22, 2023 - 02:15 PM',
      address: 'Market Street Plaza. User verified safety within the...',
      status: 'CANCELLED',
      statusColor: Color(0xFF879AB0),
      timelineIcon: Icons.close,
      timelineColor: Color(0xFF788AA0),
      previewColor: Color(0xFF8EBDB3),
    ),
    _HistoryItem(
      title: 'MANUAL ALERT',
      dateTime: 'Oct 20, 2023 - 08:30 AM',
      address: 'Golden Gate Park Trail. Precautionary alert sent t...',
      status: 'ACTIVATED',
      statusColor: Color(0xFFF39443),
      timelineIcon: Icons.warning_amber_rounded,
      timelineColor: Color(0xFFF1A253),
      previewColor: Color(0xFF8AA342),
    ),
  ];

  void _handleNavTap(int index) {
    if (index == 2) return;

    if (index == 0) {
      Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(context, noAnimationRoute(const EmergencyPage()));
      return;
    }
    if (index == 3) {
      Navigator.pushReplacement(context, noAnimationRoute(const MapPage()));
      return;
    }
    if (index == 4) {
      Navigator.pushReplacement(context, noAnimationRoute(const ProfilePage()));
    }
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 10),
            _buildTabs(),
            const SizedBox(height: 2),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                itemCount: _items.length,
                itemBuilder: (context, index) => _buildTimelineItem(_items[index], index),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 2,
        onTap: _handleNavTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _circleIconButton(
          Icons.arrow_back_ios_new_rounded,
          onTap: _handleBack,
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Safety History',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2A3B),
              ),
            ),
          ),
        ),
        _circleIconButton(Icons.tune_rounded),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = ['All', 'Triggered', 'Cancelled'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = _activeTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: Container(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? const Color(0xFFEF2828) : const Color(0xFFDDE2E9),
                      width: selected ? 2.2 : 1.2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? const Color(0xFFEF2828) : const Color(0xFF647892),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 21,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimelineItem(_HistoryItem item, int index) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: item.timelineColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.timelineIcon, size: 15, color: item.timelineColor),
                ),
                if (index != _items.length - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: const Color(0xFFD4DAE2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5EAF0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x110D1B2A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Color(0xFF9AA9BD),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.statusColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: item.statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.dateTime,
                      style: const TextStyle(
                        color: Color(0xFF1B2739),
                        fontSize: 33,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.address,
                              style: const TextStyle(
                                color: Color(0xFF33475E),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'View Details  >',
                              style: TextStyle(
                                color: Color(0xFFFA1F1F),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _mapPreview(item.previewColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPreview(Color color) {
    return Container(
      width: 78,
      height: 70,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          Center(
            child: SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1E2A3B), size: 18),
      ),
    );
  }

}

class _HistoryItem {
  final String title;
  final String dateTime;
  final String address;
  final String status;
  final Color statusColor;
  final IconData timelineIcon;
  final Color timelineColor;
  final Color previewColor;

  const _HistoryItem({
    required this.title,
    required this.dateTime,
    required this.address,
    required this.status,
    required this.statusColor,
    required this.timelineIcon,
    required this.timelineColor,
    required this.previewColor,
  });
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..strokeWidth = 1;

    for (double x = 8; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 8; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final routePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(12, size.height - 16)
      ..cubicTo(size.width * 0.35, size.height * 0.45, size.width * 0.6, size.height * 0.85,
          size.width - 12, 12);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
