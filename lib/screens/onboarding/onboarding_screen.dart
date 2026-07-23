import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;


  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(controller);


    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );


    controller.forward();
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/karnak.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),


          // Dark Overlay
          Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),



          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [


                  // Header Logo
                  Row(
                    children: [

                      Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: const Color(0xff002046),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.account_balance,
                          color: Color(0xffffcc87),
                        ),
                      ),


                      const SizedBox(width: 10),


                      const Text(
                        "Smart Heritage",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      )

                    ],
                  ),



                  const Spacer(),



                  // Glass Card
                  FadeTransition(
                    opacity: fadeAnimation,

                    child: SlideTransition(
                      position: slideAnimation,

                      child: Container(

                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(

                          color: Colors.white.withValues(alpha: 0.75),

                          borderRadius:
                              BorderRadius.circular(30),

                          border: Border.all(
                            color: Colors.white54,
                          ),

                        ),


                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [


                            const Text(
                              "Discover the Secrets of History",

                              style: TextStyle(
                                color: Color(0xff002046),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),



                            const SizedBox(height: 15),



                            const Text(
                              "Journey through time with AI-curated "
                              "historical insights. Uncover hidden "
                              "narratives behind the world's most "
                              "iconic monuments with our digital oasis "
                              "of knowledge.",

                              style: TextStyle(
                                color: Color(0xff44474e),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),



                            const SizedBox(height: 30),



                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,

                              children: [


                                // Indicators
                                Row(
                                  children: [

                                    Container(
                                      width: 32,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xff7c571e),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    ),


                                    const SizedBox(width: 5),


                                    indicator(),


                                    const SizedBox(width: 5),


                                    indicator(),

                                  ],
                                ),




                                // Next Button
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(
                                      context, '/home'),
                                  child: Container(
                                    height: 55,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 25,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient:
                                          const LinearGradient(
                                        colors: [
                                          Color(0xff7c571e),
                                          Color(0xffffcc87),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          "NEXT",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                )

                              ],
                            )

                          ],
                        ),

                      ),
                    ),
                  ),



                  const SizedBox(height: 25),



                  // Footer
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: const [

                      Icon(
                        Icons.verified,
                        color: Colors.white70,
                        size: 18,
                      ),

                      SizedBox(width: 8),

                      Text(
                        "Verified World Heritage Guide",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      )

                    ],
                  ),


                  const SizedBox(height: 20),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }



  Widget indicator(){

    return Container(
      width: 8,
      height: 8,

      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );

  }

}