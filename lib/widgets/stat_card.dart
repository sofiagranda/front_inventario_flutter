import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Tu color #0f172a
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF1E293B), // Tu color #1e293b
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0), // Espacio entre título y valor
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}