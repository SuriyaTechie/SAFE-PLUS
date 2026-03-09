import 'package:flutter/material.dart';

import '../utils/phone_utils.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialRelationship,
  });

  final String? initialName;
  final String? initialPhone;
  final String? initialRelationship;

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<String> _relationships = const [
    'Parent',
    'Sibling',
    'Spouse',
    'Friend',
    'Colleague',
    'Neighbor',
  ];
  String? _selectedRelationship;
  bool get _isEditMode => widget.initialName != null || widget.initialPhone != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _phoneController.text =
        widget.initialPhone == null ? '' : (normalizeIndianPhone(widget.initialPhone!) ?? '');
    if (widget.initialRelationship != null &&
        _relationships.contains(widget.initialRelationship)) {
      _selectedRelationship = widget.initialRelationship;
    }
  }

  void _saveContact() {
    final name = _nameController.text.trim();
    final normalizedPhone = normalizeIndianPhone(_phoneController.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a contact name.')),
      );
      return;
    }

    if (normalizedPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid mobile number. Format: +91XXXXXXXXXX')),
      );
      return;
    }

    _phoneController.text = normalizedPhone;
    final actionText = _isEditMode ? 'Updated' : 'Saved';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$actionText $name - $normalizedPhone')),
    );
    Navigator.pop(context, {
      'name': name,
      'phone': normalizedPhone,
      'relationship': _selectedRelationship ?? '',
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 22,
                          color: Color(0xFF283141),
                        ),
                      ),
                    ),
                    Text(
                      _isEditMode ? 'Edit Emergency Contact' : 'Add Emergency Contact',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF232C3D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 30, 18, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 170,
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const CircleAvatar(
                                  radius: 62,
                                  backgroundColor: Color(0xFFE2E1E5),
                                  child: Icon(
                                    Icons.person,
                                    size: 58,
                                    color: Color.fromRGBO(147, 104, 104, 0.9),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  bottom: 2,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Upload action coming soon.')),
                                        );
                                      },
                                      child: Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF0B0B),
                                          borderRadius: BorderRadius.circular(23),
                                          border: Border.all(color: Colors.white, width: 3),
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white, size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Contact Photo',
                              style: TextStyle(
                                fontSize: 33,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF273044),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to upload',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFA58888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'e.g. Sarah Jenkins',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 18),
                    _buildLabel('Phone Number'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '+91 9876543210',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    _buildLabel('Relationship'),
                    const SizedBox(height: 8),
                    _buildRelationshipDropdown(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFEB0303),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3FD30808),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: _saveContact,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isEditMode ? 'Update Contact' : 'Save Contact',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 22,
        color: Color(0xFF2F3440),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2A3141),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 24,
          color: Color(0xFFC9B4B4),
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE9DEE1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDCC8CD), width: 1.2),
        ),
      ),
    );
  }

  Widget _buildRelationshipDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9DEE1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRelationship,
          isExpanded: true,
          hint: const Text(
            'Select relationship',
            style: TextStyle(
              fontSize: 23,
              color: Color(0xFF39414F),
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8F7777), size: 28),
          style: const TextStyle(
            fontSize: 23,
            color: Color(0xFF2F3440),
            fontWeight: FontWeight.w600,
          ),
          items: _relationships
              .map(
                (value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedRelationship = value),
        ),
      ),
    );
  }
}
