import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  double _rotateX = 0;
  double _rotateY = 0;

  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _handleMouseMove(PointerEvent details, Size size) {
    setState(() {
      // Inclinación suave basada en la posición del puntero
      _rotateX = (details.localPosition.dy / size.height - 0.5) * -0.2;
      _rotateY = (details.localPosition.dx / size.width - 0.5) * 0.2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: MouseRegion(
        onHover: (event) => _handleMouseMove(event, size),
        onExit: (_) => setState(() {
          _rotateX = 0;
          _rotateY = 0;
        }),
        child: Stack(
          children: [
            // 1. LUCES DE FONDO DIFUMINADAS (Efecto Bloom)
            Positioned(
              top: -150,
              left: -150,
              child: _BlurLight(
                color: Colors.blue.withValues(alpha: 0.15),
                size: 500,
              ),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: _BlurLight(
                color: Colors.indigo.withValues(alpha: 0.12),
                size: 600,
              ),
            ),

            // 2. CONTENIDO PRINCIPAL CON PERSPECTIVA
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspectiva 3D
                  ..rotateX(_rotateX)
                  ..rotateY(_rotateY),
                alignment: FractionalOffset.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono Flotante
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatController.value * -25),
                          child: child,
                        );
                      },
                      child: _buildLogo(),
                    ),
                    const SizedBox(height: 48),

                    // Título con Kerning ajustado
                    const Text(
                      "STOCKMASTER",
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtítulo
                    Text(
                      "La nueva era del control de inventarios.\nGestión inteligente, resultados impecables.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Botón de Acción
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),

            // 3. FOOTER GRUPAL
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "---  GRUPO 26  ---",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 12,
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: const Icon(
        Icons.inventory_2_rounded,
        size: 90,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/login'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "COMENZAR",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para las luces de fondo con desenfoque real
class _BlurLight extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurLight({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}