import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../services/voice_service.dart';
import '../utils/nav_utils.dart';
import '../widgets/main_bottom_nav.dart';
import 'emergency_history_page.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> with TickerProviderStateMixin {
  final _locationService = LocationService();
  final _voiceService = VoiceService();
  final _emergencyService = EmergencyService();
  final _authService = AuthService();

  late final AnimationController _pulseController;
  late final AnimationController _spinController;
  late final AnimationController _uploadController;
  late final AnimationController _cancelCountdownController;
  late final AnimationController _holdCancelController;

  bool _sending = false;
  bool _alertCanceled = false;
  String _status = 'Broadcasting SOS';
  double _uploadProgress = 0.75;
  int _secondsRemaining = 10;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _uploadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )
      ..addListener(_onUploadTick)
      ..repeat(reverse: true);

    _cancelCountdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )
      ..addListener(_onCountdownTick)
      ..forward();

    _holdCancelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _cancelAlert();
        }
      });
  }

  void _onUploadTick() {
    if (!_sending || !mounted) return;
    final animated = 0.62 + (_uploadController.value * 0.3);
    setState(() => _uploadProgress = animated);
  }

  void _onCountdownTick() {
    if (!mounted) return;
    final remaining = (10 * (1 - _cancelCountdownController.value)).ceil();
    final fixed = remaining < 0 ? 0 : remaining;
    if (fixed != _secondsRemaining) {
      setState(() => _secondsRemaining = fixed);
    }
  }

  Future<void> _triggerEmergency() async {
    if (_sending || _alertCanceled) return;

    setState(() {
      _sending = true;
      _status = 'Collecting live location and audio';
      _uploadProgress = 0.1;
    });

    try {
      final userId = _authService.currentUserId();
      if (userId == null) {
        throw Exception('No logged-in user found.');
      }

      final position = await _locationService.getCurrentLocation();
      final audioFile = await _voiceService.createDummyAudioFile();

      if (!mounted) return;
      setState(() {
        _status = 'Sharing live audio and location';
        _uploadProgress = 0.75;
      });

      final result = await _emergencyService.triggerEmergency(
        audioFile: audioFile,
        latitude: position.latitude,
        longitude: position.longitude,
        userId: userId,
      );

      if (!mounted) return;
      setState(() {
        _status = 'Help is on the way';
        _uploadProgress = 1;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('SOS sent: ${result['message'] ?? 'Success'}')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Emergency failed';
        _uploadProgress = 0.15;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _onHoldCancelStart(LongPressStartDetails _) {
    if (_alertCanceled) return;
    _holdCancelController.forward(from: 0);
  }

  void _onHoldCancelEnd(LongPressEndDetails _) {
    if (_alertCanceled) return;
    if (_holdCancelController.status != AnimationStatus.completed) {
      _holdCancelController.reset();
    }
  }

  void _cancelAlert() {
    if (_alertCanceled) return;

    setState(() {
      _alertCanceled = true;
      _status = 'Alert canceled';
      _uploadProgress = 0;
      _secondsRemaining = 0;
    });

    _cancelCountdownController.stop();
    _uploadController.stop();
    _spinController.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency alert canceled.')),
    );
  }

  void _handleNavTap(int index) {
    if (index == 1) return;

    if (index == 0) {
      Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
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
    Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    _uploadController.removeListener(_onUploadTick);
    _uploadController.dispose();
    _cancelCountdownController.removeListener(_onCountdownTick);
    _cancelCountdownController.dispose();
    _holdCancelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _alertCanceled ? const Color(0xFF94A3B8) : const Color(0xFFE11D48);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.04,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBWdGD1CR8g5JLoT0JtxyvugpOfZxfCqWv7PncV1lC7kBGBPTdPxi0SV9TBe4OD7GMGyWJlJoiVfKTpGmw_HyJUa9o8pRy64Xlyxwy2vO-W0BHD71BDqNx3q3GvPm61Nn_rIwaZEC6-nrgCNsIuPeJ2hQiVltwpRIUT8Yq6kkxV6xndpNysDOBBQ1Xl1iKLxt2W3H2ZV7XKzNp8GTEah0XCyPEAl72_i6DhkkhYmAPnxvHhMlw0abWUaHT7Cxy7KWDBjyHjI7TixaQ',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _handleBack,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF94A3B8)),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'SAFEPULSE',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Emergency info panel coming soon.')),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        icon: const Icon(Icons.info_outline, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          'Emergency Active',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (_, __) {
                                  final t = Curves.easeInOutSine.transform(_pulseController.value);
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 12 + (t * 10),
                                        height: 12 + (t * 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE11D48).withValues(alpha: 0.25 * (1 - t)),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const CircleAvatar(
                                        radius: 4,
                                        backgroundColor: Color(0xFFE11D48),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'BROADCASTING SOS',
                                style: TextStyle(
                                  color: Color(0xFFE11D48),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, __) {
                            final t = Curves.easeInOutSine.transform(_pulseController.value);
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 290 + (t * 8),
                                  height: 290 + (t * 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE11D48).withValues(alpha: 0.06),
                                  ),
                                ),
                                Container(
                                  width: 230 + (t * 6),
                                  height: 230 + (t * 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.18)),
                                  ),
                                ),
                                Container(
                                  width: 196 + (t * 4),
                                  height: 196 + (t * 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.3)),
                                  ),
                                ),
                                Container(
                                  width: 166,
                                  height: 166,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFFFE4E6)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x11000000),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 132,
                                      height: 132,
                                      decoration: BoxDecoration(
                                        color: _alertCanceled
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFFE11D48),
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x55E11D48),
                                            blurRadius: 16,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.sos,
                                        color: Colors.white,
                                        size: 54,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _alertCanceled ? 'Alert canceled' : 'Help is on the way',
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Responders are viewing your profile',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RotationTransition(
                              turns: _spinController,
                              child: Icon(
                                Icons.sync,
                                color: progressColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _status,
                              style: TextStyle(
                                color: progressColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: _uploadProgress.clamp(0, 1),
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'UPLOADING SIGNAL',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              '${(_uploadProgress * 100).round()}%',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
                  decoration: const BoxDecoration(
                    color: Color(0x80FFFFFF),
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _alertCanceled ? null : _triggerEmergency,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shadowColor: const Color(0x66E11D48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: Icon(_sending ? Icons.sync : Icons.call),
                          label: Text(
                            _sending ? 'Calling Emergency Services...' : 'Call Emergency Services',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onLongPressStart: _onHoldCancelStart,
                        onLongPressEnd: _onHoldCancelEnd,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 66,
                                  height: 66,
                                  child: CircularProgressIndicator(
                                    value: 1 - _cancelCountdownController.value,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFB7185)),
                                    strokeWidth: 4,
                                  ),
                                ),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$_secondsRemaining',
                                        style: const TextStyle(
                                          color: Color(0xFF334155),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const Text(
                                        'SEC',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 8,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'HOLD TO CANCEL ALERT',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 160,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: _holdCancelController.value,
                                  minHeight: 5,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE11D48)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your emergency data is being encrypted and shared with local dispatch and your safety contacts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 1,
        onTap: _handleNavTap,
      ),
    );
  }
}

