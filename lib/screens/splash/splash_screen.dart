import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  double loadingWidth = 0.5;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  
    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );

    controller.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => loadingWidth = 1.0);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/pyramids.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),


          // Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900.withValues(alpha: 0.2),
                  Colors.blue.shade900.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),


          // Content
          Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    // Logo
                    Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white30,
                        ),
                      ),

                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),


                    const SizedBox(height: 25),


                    // Title
                    const Text(
                      "Smart Heritage",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),


                    const SizedBox(height: 8),


                    // Subtitle
                    const Text(
                      "ANCIENT WONDERS. FUTURE DISCOVERY.",
                      style: TextStyle(
                        color: Color(0xffffcc87),
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),


                    const SizedBox(height: 50),


                    // Loading Bar
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: 250 * loadingWidth,
                      height: 3,

                      decoration: BoxDecoration(
                        color: const Color(0xffffcc87),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffffcc87)
                                .withValues(alpha: 0.8),
                            blurRadius: 8,
                          )
                        ],
                      ),
                    ),


                    const SizedBox(height: 20),


                    const Text(
                      "Curating your journey...",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),


          // Bottom Badge
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,

            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Icon(
                      Icons.verified,
                      color: Color(0xffffcc87),
                      size: 16,
                    ),

                    SizedBox(width: 8),

                    Text(
                      "UNESCO Explorer Verified",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
