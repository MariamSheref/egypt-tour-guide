import 'package:flutter/material.dart';


class RecommendationCard extends StatelessWidget {

  final String image;
  final String title;
  final String location;
  final String rating;


  const RecommendationCard({

    super.key,

    required this.image,

    required this.title,

    required this.location,

    required this.rating,

  });



  @override
  Widget build(BuildContext context) {


    return Container(

      width:280,

      height:420,


      margin:
      const EdgeInsets.only(right:16),


      decoration: BoxDecoration(

        borderRadius:
        BorderRadius.circular(25),


        image:

        DecorationImage(

          image:
          AssetImage(image),

          fit:
          BoxFit.cover,

        ),

      ),


      child:

      Stack(

        children:[


          Container(

            decoration:

            BoxDecoration(

              borderRadius:
              BorderRadius.circular(25),

              gradient:

              const LinearGradient(

                begin:
                Alignment.topCenter,

                end:
                Alignment.bottomCenter,

                colors:[

                  Colors.transparent,

                  Color(0xaa002046),

                ],

              ),

            ),

          ),



          Positioned(

            top:20,

            right:15,

            child:

            Container(

              padding:
              const EdgeInsets.symmetric(
                horizontal:10,
                vertical:5,
              ),

              decoration:

              BoxDecoration(

                color:
                Colors.white24,

                borderRadius:
                BorderRadius.circular(20),

              ),


              child:Text(
                "⭐ $rating",
                style:
                const TextStyle(
                  color:Colors.white,
                ),
              ),

            ),
          ),



          Positioned(

            bottom:20,

            left:15,

            right:15,

            child:

            Container(

              padding:
              const EdgeInsets.all(15),


              decoration:

              BoxDecoration(

                color:
                Colors.white70,


                borderRadius:
                BorderRadius.circular(20),

              ),


              child:

              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[


                  Text(

                    title,

                    style:
                    const TextStyle(

                      fontSize:18,

                      fontWeight:
                      FontWeight.bold,

                      color:
                      Color(0xff002046),

                    ),
                  ),


                  const SizedBox(height:5),


                  Row(

                    children:[

                      const Icon(
                        Icons.location_on,
                        size:14,
                      ),

                      Text(
                        location,
                        style:
                        const TextStyle(
                          fontSize:12,
                        ),
                      )

                    ],
                  )


                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}