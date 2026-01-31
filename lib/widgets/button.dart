import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onClick;
  // El tipo 'button' | 'submit' en Flutter se maneja por la lógica del botón
  final bool isFullWidth; 

  const CustomButton({
    super.key,
    required this.label,
    this.onClick,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Si quieres que se comporte como un bloque (full width) o tamaño contenido
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          // Background: #2563eb
          backgroundColor: const Color(0xFF2563EB),
          // Color del texto: #fff
          foregroundColor: Colors.white,
          // Padding: 10px 16px
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          // Border Radius: 8px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // Border: none
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}