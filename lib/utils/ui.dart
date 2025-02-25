import 'package:flutter/material.dart';

Widget beautifulIconButton({
  required IconData icon,
  required VoidCallback onPressed,
  String? tooltip,
}) {
  return Material(
    color: Colors.transparent,
    child: Ink(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    ),
  );
}
