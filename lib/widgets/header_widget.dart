import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onHomePressed;
  final VoidCallback onProfilePressed;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.onBackPressed,
    required this.onHomePressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBackPressed,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: onHomePressed,
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: onProfilePressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}