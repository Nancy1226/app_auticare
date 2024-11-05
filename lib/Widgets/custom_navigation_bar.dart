import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavBarItem(
              icon: Icons.home,
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            _NavBarItem(
              icon: Icons.grid_view,
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            _NavBarItem(
              icon: Icons.chat_bubble_outline,
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
            ),
            _NavBarItem(
              icon: Icons.person_outline,
              isSelected: selectedIndex == 3,
              onTap: () => onItemSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF6A62B7) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}