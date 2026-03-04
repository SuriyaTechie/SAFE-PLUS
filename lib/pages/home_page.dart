import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../services/voice_service.dart';
import '../utils/nav_utils.dart';
import '../widgets/main_bottom_nav.dart';
import 'contact_list_page.dart';
import 'emergency_page.dart';
import 'emergency_history_page.dart';
import 'login_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Duration _holdDuration = Duration(seconds: 3);
  static const Duration _tick = Duration(milliseconds: 50);

  final _authService = AuthService();
  final _locationService = LocationService();
  final _voiceService = VoiceService();
  final _emergencyService = EmergencyService();

  Timer? _holdTimer;
  Duration _elapsed = Duration.zero;
  bool _loading = false;
  final int _navIndex = 0;

  double get _holdProgress => (_elapsed.inMilliseconds / _holdDuration.inMilliseconds).clamp(0, 1);

  String get _holdLabel {
    final secondsLeft = (_holdDuration - _elapsed).inMilliseconds / 1000;
    final shown = secondsLeft < 0 ? 0.0 : secondsLeft;
    return '${shown.toStringAsFixed(1)}S HOLD';
  }

  Future<void> _triggerEmergency() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final userId = _authService.currentUserId();
      if (userId == null) {
        throw Exception('No logged-in user found.');
      }

      final position = await _locationService.getCurrentLocation();
      final audioFile = await _voiceService.createDummyAudioFile();

      final result = await _emergencyService.triggerEmergency(
        audioFile: audioFile,
        latitude: position.latitude,
        longitude: position.longitude,
        userId: userId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('SOS sent: ${result['message'] ?? 'Success'}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _elapsed = Duration.zero;
        });
      }
    }
  }

  void _startHold() {
    if (_loading) return;

    _holdTimer?.cancel();
    setState(() => _elapsed = Duration.zero);

    _holdTimer = Timer.periodic(_tick, (timer) {
      final next = _elapsed + _tick;
      if (next >= _holdDuration) {
        timer.cancel();
        setState(() => _elapsed = _holdDuration);
        _triggerEmergency();
        return;
      }
      setState(() => _elapsed = next);
    });
  }

  void _cancelHold() {
    if (_loading) return;
    _holdTimer?.cancel();
    setState(() => _elapsed = Duration.zero);
  }

  Future<void> _handleNavTap(int index) async {
    if (index == 0) return;

    if (index == 1) {
      Navigator.pushReplacement(context, noAnimationRoute(const EmergencyPage()));
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(context, noAnimationRoute(const EmergencyHistoryPage()));
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
    Navigator.pushReplacement(context, noAnimationRoute(const LoginPage()));
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildSosControl(),
                    const SizedBox(height: 28),
                    const Text(
                      'MANAGEMENT & SECURITY',
                      style: TextStyle(
                        color: Color(0xFF9AA8BF),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      iconBg: const Color(0xFFFFECEF),
                      iconColor: const Color(0xFFE61D3C),
                      icon: Icons.people_outline,
                      title: 'Emergency Contacts',
                      subtitle: '4 Active Guardians',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ContactListPage()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      iconBg: const Color(0xFFEAF0FF),
                      iconColor: const Color(0xFF3365E3),
                      icon: Icons.history,
                      title: 'Safety History',
                      subtitle: 'No recent incidents',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EmergencyHistoryPage()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      iconBg: const Color(0xFFF1ECFF),
                      iconColor: const Color(0xFF6D4BEA),
                      icon: Icons.auto_awesome_outlined,
                      title: 'AIntelligent Shield',
                      subtitle: 'Active - Low Profile',
                      onTap: () {},
                    ),
                    _buildMenuCard(
                      iconBg: const Color(0xFFE8F8EF),
                      iconColor: const Color(0xFF0FA35B),
                      icon: Icons.lock_outline,
                      title: 'Security Audit',
                      subtitle: 'Permissions up to date',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _handleBack,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF4A566A)),
        ),
        const SizedBox(width: 8),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD9C5),
            borderRadius: BorderRadius.circular(23),
          ),
          child: const Icon(Icons.person, color: Color(0xFFB17756)),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GOOD MORNING',
                style: TextStyle(
                  color: Color(0xFF9EACC0),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Suriya',
                style: TextStyle(
                  color: Color(0xFF0D2047),
                  fontWeight: FontWeight.w800,
                  fontSize: 34,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8EF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: Color(0xFF10A660), size: 16),
              SizedBox(width: 6),
              Text(
                'SECURE',
                style: TextStyle(
                  color: Color(0xFF10A660),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFF3F6FB),
            child: Icon(Icons.location_on_outlined, color: Color(0xFF49658B)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STATUS',
                  style: TextStyle(
                    color: Color(0xFF9AA8BF),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Home Safe - Downtown',
                  style: TextStyle(
                    color: Color(0xFF10254C),
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Color(0xFFA7B3C6)),
        ],
      ),
    );
  }

  Widget _buildSosControl() {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _startHold(),
          onTapUp: (_) => _cancelHold(),
          onTapCancel: _cancelHold,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1E1E8),
                ),
              ),
              Container(
                width: 236,
                height: 236,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFECC8D5),
                ),
              ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 6),
                  color: const Color(0xFFD41145),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _loading ? Icons.hourglass_bottom : Icons.wifi_tethering,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.location_on_outlined, color: Colors.white, size: 38),
                    const SizedBox(height: 12),
                    const Text(
                      'S O S',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _loading ? 'SENDING ALERT...' : 'HOLD FOR HELP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 34, height: 2, color: const Color(0xFFE03860)),
            const SizedBox(width: 10),
            Text(
              _loading ? 'SENDING...' : _holdLabel,
              style: const TextStyle(
                color: Color(0xFF0D2047),
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.1,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 34, height: 2, color: const Color(0xFFE03860)),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: _loading ? null : _holdProgress,
              backgroundColor: const Color(0xFFE3E7F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD41145)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F2348),
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6E7F9A),
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more, color: Color(0xFFA7B3C6)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return MainBottomNav(
      currentIndex: _navIndex,
      onTap: _handleNavTap,
    );
  }
}
