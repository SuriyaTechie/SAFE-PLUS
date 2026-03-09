import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/nav_utils.dart';
import '../utils/phone_utils.dart';
import '../widgets/main_bottom_nav.dart';
import 'add_contact_page.dart';
import 'emergency_history_page.dart';
import 'emergency_page.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

class ContactListPage extends StatelessWidget {
  const ContactListPage({super.key});

  static final Map<String, String> _contactPhones = {
    'David Henderson': '+919876543210',
    'Sarah Mitchell': '+919812345678',
    'Marcus Chen': '+919811112222',
    'Dr. Emily Rodriguez': '+919800001111',
  };

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _phoneOf(String name) {
    return _contactPhones[name] ?? '+919999999999';
  }

  Future<void> _dialContact(
    BuildContext context, {
    required String name,
    required String phone,
  }) async {
    final normalized = normalizeIndianPhone(phone);
    if (normalized == null) {
      _showActionSnackBar(context, 'Invalid phone number for $name');
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: normalized,
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showActionSnackBar(context, 'Unable to open dialer for $name');
    }
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
      return;
    }
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

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
  }

  Future<void> _openEditContact(
    BuildContext context, {
    required String name,
    required String phone,
    required String relationship,
  }) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddContactPage(
          initialName: name,
          initialPhone: phone,
          initialRelationship: relationship,
        ),
      ),
    );
    if (result == null) {
      return;
    }

    final normalized = normalizeIndianPhone((result['phone'] ?? '').toString());
    if (normalized != null) {
      _contactPhones[name] = normalized;
      if (context.mounted) {
        _showActionSnackBar(context, '$name number saved: $normalized');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              _buildSearchBox(),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildSectionHeader('TOP CONTACTS', 'PRIORITY'),
                    const SizedBox(height: 10),
                    _buildPriorityCard(
                      name: 'David Henderson',
                      subtitle: 'Spouse - Medical Proxy',
                      avatarColor: const Color(0xFFE4F3FF),
                      avatarLetter: 'D',
                      onCallTap: () => _dialContact(
                        context,
                        name: 'David Henderson',
                        phone: _phoneOf('David Henderson'),
                      ),
                      onMessageTap: () =>
                          _showActionSnackBar(context, 'Opening chat with David Henderson...'),
                    ),
                    const SizedBox(height: 12),
                    _buildPriorityCard(
                      name: 'Sarah Mitchell',
                      subtitle: 'Sister - Emergency Contact',
                      avatarColor: const Color(0xFFFFE9DF),
                      avatarLetter: 'S',
                      onCallTap: () => _dialContact(
                        context,
                        name: 'Sarah Mitchell',
                        phone: _phoneOf('Sarah Mitchell'),
                      ),
                      onMessageTap: () =>
                          _showActionSnackBar(context, 'Opening chat with Sarah Mitchell...'),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionHeader('FAMILY', null),
                    const SizedBox(height: 10),
                    _buildCompactContact(
                      name: 'Marcus Chen',
                      relation: 'Brother',
                      avatarColor: const Color(0xFFFFEFD8),
                      avatarLetter: 'M',
                      lastActionIcon: Icons.edit_rounded,
                      onCallTap: () => _dialContact(
                        context,
                        name: 'Marcus Chen',
                        phone: _phoneOf('Marcus Chen'),
                      ),
                      onLastActionTap: () => _openEditContact(
                        context,
                        name: 'Marcus Chen',
                        phone: _phoneOf('Marcus Chen'),
                        relationship: 'Sibling',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('MEDICAL', null),
                    const SizedBox(height: 10),
                    _buildCompactContact(
                      name: 'Dr. Emily Rodriguez',
                      relation: 'Primary Physician',
                      avatarColor: const Color(0xFFE9F7F2),
                      avatarLetter: 'E',
                      lastActionIcon: Icons.more_vert_rounded,
                      onCallTap: () => _dialContact(
                        context,
                        name: 'Dr. Emily Rodriguez',
                        phone: _phoneOf('Dr. Emily Rodriguez'),
                      ),
                      onLastActionTap: () =>
                          _showActionSnackBar(context, 'More actions coming soon.'),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEB1010),
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (_) => const AddContactPage()),
          );
          final name = (result?['name'] ?? '').toString().trim();
          final phone = normalizeIndianPhone((result?['phone'] ?? '').toString());
          if (name.isNotEmpty && phone != null) {
            _contactPhones[name] = phone;
            if (context.mounted) {
              _showActionSnackBar(context, '$name saved with number $phone');
            }
          }
        },
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: MainBottomNav(
        currentIndex: -1,
        onTap: (index) => _handleNavTap(context, index),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _roundIconButton(
          Icons.arrow_back_ios_new_rounded,
          onTap: () => _handleBack(context),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Hub',
                style: TextStyle(
                  color: Color(0xFF1D2738),
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'ACTIVE SHIELD ON',
                style: TextStyle(
                  color: Color(0xFFFF2A2A),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
        _roundIconButton(
          Icons.settings,
          filled: true,
          onTap: () => _showActionSnackBar(context, 'Settings panel coming soon.'),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4E8EE)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search contacts...',
          hintStyle: TextStyle(
            color: Color(0xFFA3AFBF),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFFAAB5C4)),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? badge) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF93A2B8),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
        const Spacer(),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7E7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Color(0xFFFF4A4A),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriorityCard({
    required String name,
    required String subtitle,
    required Color avatarColor,
    required String avatarLetter,
    required VoidCallback onCallTap,
    required VoidCallback onMessageTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD1D1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AF24A4A),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(letter: avatarLetter, color: avatarColor, online: true),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF1E2839),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7A879B),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.drag_indicator, color: Color(0xFFC4CFDA)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: 'Call',
                  icon: Icons.call,
                  filled: true,
                  onTap: onCallTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  label: 'Message',
                  icon: Icons.chat_bubble,
                  filled: false,
                  onTap: onMessageTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactContact({
    required String name,
    required String relation,
    required Color avatarColor,
    required String avatarLetter,
    required IconData lastActionIcon,
    VoidCallback? onCallTap,
    VoidCallback? onLastActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EBF0)),
      ),
      child: Row(
        children: [
          _avatar(letter: avatarLetter, color: avatarColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF202B3C),
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                ),
                Text(
                  relation,
                  style: const TextStyle(
                    color: Color(0xFF8997AB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _smallCircleIcon(Icons.call, const Color(0xFFEEF1F5), onTap: onCallTap),
          const SizedBox(width: 8),
          _smallCircleIcon(
            lastActionIcon,
            const Color(0xFFEEF1F5),
            onTap: onLastActionTap,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool filled,
    VoidCallback? onTap,
  }) {
    final textColor = filled ? Colors.white : const Color(0xFF233045);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: filled ? const Color(0xFFFF1111) : const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar({
    required String letter,
    required Color color,
    bool online = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: Text(
            letter,
            style: const TextStyle(
              color: Color(0xFF293449),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (online)
          const Positioned(
            right: -1,
            bottom: -1,
            child: CircleAvatar(
              radius: 6,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 5,
                backgroundColor: Color(0xFF20C35A),
              ),
            ),
          ),
      ],
    );
  }

  Widget _roundIconButton(IconData icon, {bool filled = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6EBF1)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? const Color(0xFF1E2940) : const Color(0xFF4A566A),
        ),
      ),
    );
  }

  Widget _smallCircleIcon(IconData icon, Color bg, {VoidCallback? onTap}) {
    final child = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 16, color: const Color(0xFF526176)),
    );
    if (onTap == null) {
      return child;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: child,
    );
  }

}
