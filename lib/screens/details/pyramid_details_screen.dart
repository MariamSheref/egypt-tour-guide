import 'package:flutter/material.dart';

class PyramidDetailsScreen extends StatelessWidget {
  const PyramidDetailsScreen({super.key});


  final Color primary = const Color(0xff002046);
  final Color gold = const Color(0xfffecc87);


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xfff8f9fa),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.only(bottom: 100),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [


              // Top Bar
              Padding(
                padding: const EdgeInsets.all(20),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    Icon(
                      Icons.menu,
                      color: primary,
                    ),


                    Text(
                      "Smart Heritage",
                      style: TextStyle(
                        color: primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),


                    const CircleAvatar(
                      radius:20,
                      backgroundImage:
                      AssetImage(
                        "assets/images/profile.jpg",
                      ),
                    )

                  ],
                ),
              ),



              // Hero Image

              Stack(

                children: [

                  Container(

                    height: 530,

                    decoration: const BoxDecoration(

                      image: DecorationImage(

                        image: AssetImage(
                          "assets/images/pyramid.jpg",
                        ),

                        fit: BoxFit.cover,

                      ),

                    ),

                  ),



                  Positioned(

                    bottom:20,
                    left:20,
                    right:20,


                    child: Container(

                      padding:
                      const EdgeInsets.all(20),

                      decoration: BoxDecoration(

                        color:
                        Colors.white.withOpacity(.85),

                        borderRadius:
                        BorderRadius.circular(25),

                      ),


                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [


                          Row(

                            children: [

                              Container(

                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal:10,
                                  vertical:5,
                                ),

                                decoration:BoxDecoration(

                                  color:gold,

                                  borderRadius:
                                  BorderRadius.circular(20),

                                ),


                                child:const Text(

                                  "UNESCO World Heritage",

                                  style:TextStyle(
                                    fontSize:10,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),

                                ),

                              ),


                              const SizedBox(width:10),


                              const Text(
                                "⭐ 4.9 (12k Reviews)",
                                style:
                                TextStyle(
                                  fontSize:12,
                                ),
                              )


                            ],
                          ),



                          const SizedBox(height:10),



                          Text(

                            "Pyramids of Giza",

                            style:TextStyle(

                              color:primary,

                              fontSize:28,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),



                          const SizedBox(height:5),



                          const Row(

                            children: [

                              Icon(
                                Icons.location_on,
                                size:16,
                              ),

                              Text(
                                "Al Giza Desert, Egypt",
                              )

                            ],
                          )

                        ],
                      ),
                    ),

                  )

                ],
              ),




              const SizedBox(height:20),




              // Buttons

              Padding(

                padding:
                const EdgeInsets.symmetric(
                    horizontal:20
                ),

                child: Column(

                  children: [


                    ElevatedButton.icon(

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        const Color(0xff7c571e),

                        minimumSize:
                        const Size(
                            double.infinity,
                            80
                        ),

                        shape:
                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(20),

                        ),

                      ),


                      onPressed:(){},


                      icon:
                      const Icon(
                        Icons.view_in_ar,
                        color:Colors.white,
                      ),


                      label:
                      const Text(

                        "Start AR Experience",

                        style:TextStyle(
                          color:Colors.white,
                          fontSize:18,
                        ),

                      ),

                    ),



                    const SizedBox(height:15),



                    Row(

                      children: [

                        Expanded(

                          child:
                          _smallButton(
                            Icons.auto_awesome,
                            "Ask AI Guide",
                          ),

                        ),


                        const SizedBox(width:15),


                        Expanded(

                          child:
                          _smallButton(
                            Icons.confirmation_number,
                            "Book Tickets",
                          ),

                        ),

                      ],
                    )

                  ],
                ),
              ),




              const SizedBox(height:30),




              // Description

              Padding(

                padding:
                const EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [


                    Text(

                      "The Eternal Wonder",

                      style:TextStyle(

                        color:primary,

                        fontSize:24,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    const SizedBox(height:10),



                    const Text(

                      "The Giza Necropolis stands as a testament to the architectural prowess of the Old Kingdom's Fourth Dynasty. As the only remaining wonder of the ancient world, these sandstone giants have witnessed four millennia of human history.",


                      style:TextStyle(

                        fontSize:16,

                        height:1.6,

                        color:Colors.grey,

                      ),

                    )

                  ],
                ),
              )



            ],
          ),
        ),
      ),
    );
  }




  Widget _smallButton(
      IconData icon,
      String text
      ){

    return Container(

      height:75,

      decoration:BoxDecoration(

        border:
        Border.all(
          color:primary,
        ),

        borderRadius:
        BorderRadius.circular(20),

      ),

      child:Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color:primary,
          ),

          Text(
            text,
            style:TextStyle(
              color:primary,
              fontSize:12,
            ),
          )

        ],
      ),
    );
  }

}