import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/history_service.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _roseController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _roseScale;
  late Animation<double> _roseFade;
  late Animation<double> _textFade;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAndNavigate();
  }

  void _setupAnimations() {
    _roseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _roseScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _roseController, curve: Curves.elasticOut),
    );
    _roseFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _roseController, curve: const Interval(0.0, 0.4)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _roseController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _textController.forward();
    });
  }

  Future<void> _loadAndNavigate() async {
    await HistoryService().load();
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigation(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _roseController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1e3a1e),
              Color(0xFF0A1A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rose emoji with animation
                    AnimatedBuilder(
                      animation:
                          Listenable.merge([_roseController, _pulseController]),
                      builder: (_, __) => FadeTransition(
                        opacity: _roseFade,
                        child: Transform.scale(
                          scale: _roseScale.value * _pulse.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceLight,
                              border: Border.all(
                                color: AppTheme.primary,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '🌹',
                                style: TextStyle(fontSize: 72),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Title
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: const Text(
                          'Detector de\nEnfermedades',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: const Text(
                          'en Hojas de Rosa',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Authors card
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Proyecto de Investigación',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _authorRow('👩‍🔬', 'Kevin Reyes y Jose Ortega'),
                              const SizedBox(height: 6),
                              const Text(
                                'IA · Visión por Computadora',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 2,
                        child: LinearProgressIndicator(
                          backgroundColor: AppTheme.surfaceLight,
                          valueColor:
                              const AlwaysStoppedAnimation(AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cargando modelo...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _authorRow(String emoji, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
