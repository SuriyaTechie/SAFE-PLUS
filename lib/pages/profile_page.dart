import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/nav_utils.dart';
import '../widgets/main_bottom_nav.dart';
import 'contact_list_page.dart';
import 'emergency_history_page.dart';
import 'emergency_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'map_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  late String _fullName;
  late String _phone;

  @override
  void initState() {
    super.initState();
    final profile = _authService.currentProfile();
    _fullName = profile['name'] ?? 'Sarah Jenkins';
    _phone = profile['phone'] ?? '+1 (555) 012-3456';
  }

  Future<void> _handleNavTap(BuildContext context, int index) async {
    if (index == 4) return;

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
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await _authService.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
  }

  Future<void> _openEditProfileDialog() async {
    final nameController = TextEditingController(text: _fullName);
    final phoneController = TextEditingController(text: _phone);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  <String, String>{
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                  },
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();

    if (!mounted || result == null) return;

    final nextName = (result['name'] ?? '').trim();
    final nextPhone = (result['phone'] ?? '').trim();

    if (nextName.isEmpty || nextPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone cannot be empty.')),
      );
      return;
    }

    try {
      await _authService.updateProfile(
        fullName: nextName,
        phone: nextPhone,
      );
      if (!mounted) return;
      setState(() {
        _fullName = nextName;
        _phone = nextPhone;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is connected and will be expanded soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => _handleBack(context),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3A4F)),
                      ),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Color(0xFF0F1E35),
                        fontWeight: FontWeight.w800,
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(0xFFF2B69D),
                      child: Icon(Icons.person, color: Color(0xFF6E3E34), size: 64),
                    ),
                    Positioned(
                      right: -2,
                      bottom: 2,
                      child: InkWell(
                        onTap: _openEditProfileDialog,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF526277),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _fullName,
                  style: const TextStyle(
                    color: Color(0xFF111F36),
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  _phone,
                  style: const TextStyle(
                    color: Color(0xFF677A94),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _SectionTitle('ACCOUNT'),
              const SizedBox(height: 6),
              _groupCard(
                children: [
                  _rowTile(
                    title: 'Edit Profile',
                    icon: Icons.person_outline_rounded,
                    onTap: _openEditProfileDialog,
                  ),
                  _divider(),
                  _rowTile(
                    title: 'Notifications',
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _showComingSoon('Notifications'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _SectionTitle('SAFETY'),
              const SizedBox(height: 6),
              _groupCard(
                children: [
                  _rowTile(
                    title: 'Manage Contacts',
                    icon: Icons.group_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ContactListPage()),
                      );
                    },
                  ),
                  _divider(),
                  _rowTile(
                    title: 'Privacy Settings',
                    icon: Icons.lock_outline_rounded,
                    onTap: () => _showComingSoon('Privacy Settings'),
                  ),
                  _divider(),
                  _rowTile(
                    title: 'Medical ID',
                    icon: Icons.medical_information_outlined,
                    onTap: () => _showComingSoon('Medical ID'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _SectionTitle('SYSTEM'),
              const SizedBox(height: 6),
              _groupCard(
                children: [
                  _rowTile(
                    title: 'Help & Support',
                    icon: Icons.help_outline_rounded,
                    onTap: () => _showComingSoon('Help & Support'),
                  ),
                  _divider(),
                  _rowTile(
                    title: 'App Settings',
                    icon: Icons.settings_outlined,
                    onTap: () => _showComingSoon('App Settings'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _signOut(context),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Color(0xFF394E68),
                    fontWeight: FontWeight.w700,
                    fontSize: 23,
                  ),
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 4,
        onTap: (index) => _handleNavTap(context, index),
      ),
    );
  }

  Widget _groupCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E5EC)),
    );
  }

  Widget _rowTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE3E8EF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF4B5C73)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0E1D34),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 19, color: Color(0xFF97A4B6)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9BA8BA),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        fontSize: 12,
      ),
    );
  }
}
