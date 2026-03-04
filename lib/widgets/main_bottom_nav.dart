import 'package:flutter/material.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['HOME', 'ALERTS', 'HISTORY', 'MAP', 'PROFILE'];
    const icons = [
      Icons.home_outlined,
      Icons.notifications_none,
      Icons.history,
      Icons.map_outlined,
      Icons.account_circle_outlined,
    ];

    return Container(
      height: 66,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE3E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(labels.length, (index) {
          final selected = currentIndex == index;
          final color = selected ? const Color(0xFFE72A4D) : const Color(0xFFA1AEC2);

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Icon(icons[index], color: color, size: 22),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      height: 14,
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
