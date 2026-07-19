import 'package:flutter/material.dart';

class ArReconstructionScreen extends StatefulWidget {
  const ArReconstructionScreen({super.key});

  @override
  State<ArReconstructionScreen> createState() =>
      _ArReconstructionScreenState();
}


class _ArReconstructionScreenState extends State<ArReconstructionScreen>
    with SingleTickerProviderStateMixin {


  late AnimationController controller;
  late Animation<double> floatingAnimation;


  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);


    floatingAnimation = Tween<double>(
      begin: 0,
      end: -15,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

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


          // Background
          Container(

            decoration: const BoxDecoration(

              image: DecorationImage(

                image: AssetImage(
                  "assets/images/sphinx.jpg",
                ),

                fit: BoxFit.cover,

              ),

            ),

          ),



          Container(
            color: Colors.white.withOpacity(0.55),
          ),




          SafeArea(

            child: Column(

              children: [



                // Header

                Padding(

                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),

                  child: Row(

                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [


                      const Text(

                        "SMART HERITAGE",

                        style: TextStyle(

                          color: Color(0xff002046),

                          fontSize: 22,

                          fontWeight: FontWeight.w800,

                        ),

                      ),



                      Container(

                        width: 40,
                        height: 40,

                        decoration: BoxDecoration(

                          color: Colors.white.withOpacity(.3),

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: Colors.black12,
                          ),

                        ),


                        child: const Icon(

                          Icons.translate,

                          color: Color(0xff002046),

                        ),

                      )

                    ],

                  ),

                ),



                const Spacer(),



                // AR Phone

                AnimatedBuilder(

                  animation: floatingAnimation,

                  builder: (context, child){

                    return Transform.translate(

                      offset: Offset(
                        0,
                        floatingAnimation.value,
                      ),

                      child: child,

                    );

                  },


                  child: Container(

                    width: 290,

                    height: 550,


                    decoration: BoxDecoration(

                      color: Colors.black,

                      borderRadius:
                          BorderRadius.circular(45),

                      border: Border.all(

                        color: const Color(0xff1b365d),

                        width: 8,

                      ),

                      boxShadow: const [

                        BoxShadow(

                          blurRadius: 25,

                          color: Colors.black45,

                        )

                      ],

                    ),


                    child: ClipRRect(

                      borderRadius:
                          BorderRadius.circular(35),


                      child: Stack(

                        children: [



                          // Real Image

                          Positioned.fill(

                            child: Image.asset(

                              "assets/images/sphinx_close.jpg",

                              fit: BoxFit.cover,

                            ),

                          ),



                          // Hologram Overlay

                          Positioned.fill(

                            child: Opacity(

                              opacity: .8,

                              child: Image.asset(

                                "assets/images/sphinx_hologram.png",

                                fit: BoxFit.contain,

                              ),

                            ),

                          ),




                          // AR Scanner line

                          Positioned(

                            top: 250,

                            left: 0,

                            right: 0,

                            child: Container(

                              height: 2,

                              decoration:
                                  const BoxDecoration(

                                gradient: LinearGradient(

                                  colors: [

                                    Colors.transparent,

                                    Color(0xffffcc87),

                                    Colors.transparent,

                                  ],

                                ),

                              ),

                            ),

                          ),




                          // HUD

                          Padding(

                            padding:
                                const EdgeInsets.all(20),

                            child: Column(

                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,


                              children: [


                                Row(

                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [


                                    Container(

                                      padding:
                                          const EdgeInsets.symmetric(

                                        horizontal: 12,

                                        vertical: 6,

                                      ),


                                      decoration:
                                          BoxDecoration(

                                        color:
                                            const Color(0xff002046),

                                        borderRadius:
                                            BorderRadius.circular(20),

                                      ),


                                      child: const Row(

                                        children: [

                                          Icon(

                                            Icons.circle,

                                            size: 8,

                                            color:
                                                Color(0xffffcc87),

                                          ),

                                          SizedBox(width: 5),


                                          Text(

                                            "AR ACTIVE",

                                            style: TextStyle(

                                              color: Colors.white,

                                              fontSize: 10,

                                            ),

                                          )

                                        ],

                                      ),

                                    ),



                                    const Icon(

                                      Icons.view_in_ar,

                                      color: Colors.white,

                                    )


                                  ],

                                ),



                                const Align(

                                  alignment:
                                      Alignment.bottomLeft,

                                  child: Text(

                                    "Object ID: SPX_001\nPeriod: Old Kingdom",

                                    style: TextStyle(

                                      color: Colors.white,

                                      fontSize: 11,

                                    ),

                                  ),

                                )

                              ],

                            ),

                          )

                        ],

                      ),

                    ),

                  ),

                ),



                const Spacer(),




                // Bottom Card

                Container(

                  margin:
                      const EdgeInsets.all(20),

                  padding:
                      const EdgeInsets.all(25),


                  decoration: BoxDecoration(

                    color: Colors.white.withOpacity(.85),

                    borderRadius:
                        BorderRadius.circular(30),

                  ),


                  child: Column(

                    children: [


                      const Text(

                        "AR Monument\nReconstruction",

                        textAlign: TextAlign.center,

                        style: TextStyle(

                          color: Color(0xff002046),

                          fontSize: 28,

                          fontWeight: FontWeight.bold,

                        ),

                      ),



                      const SizedBox(height: 10),



                      const Text(

                        "Witness the past come to life through cutting-edge Augmented Reality.",

                        textAlign: TextAlign.center,

                        style: TextStyle(

                          color: Colors.black54,

                          fontSize: 15,

                        ),

                      ),



                      const SizedBox(height: 20),



                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          dot(false),

                          dot(true),

                          dot(false),

                          dot(false),

                        ],

                      ),



                      const SizedBox(height: 20),



                      SizedBox(

                        width: double.infinity,

                        height: 55,

                        child: ElevatedButton(

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                const Color(0xff002046),

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius.circular(30),

                            ),

                          ),


                          onPressed: () {},


                          child: const Text(

                            "Continue Discovery  →",

                            style: TextStyle(

                              color: Colors.white,

                              fontSize: 16,

                            ),

                          ),

                        ),

                      ),



                      TextButton(

                        onPressed: () {},

                        child: const Text(

                          "SKIP TO EXPLORE",

                          style: TextStyle(

                            color: Colors.black54,

                          ),

                        ),

                      )

                    ],

                  ),

                )

              ],

            ),

          )

        ],

      ),

    );

  }



  Widget dot(bool active){

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 4),

      width: active ? 45 : 15,

      height: 6,

      decoration: BoxDecoration(

        color: active
            ? const Color(0xff7c571e)
            : Colors.grey.shade300,

        borderRadius:
            BorderRadius.circular(20),

      ),

    );

  }

}