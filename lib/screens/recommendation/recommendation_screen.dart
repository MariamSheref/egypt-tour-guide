import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';


class RecommendationScreen extends StatelessWidget {

  const RecommendationScreen({
    super.key,
  });


  final List<Map<String, dynamic>> places = const [

    {
      "name": "Pyramids of Giza",
      "location": "Giza, Egypt",
      "image": "assets/images/pyramid.jpg",
      "rating": "4.9",
      "price": "300 EGP",
      "category": "History",
    },


    {
      "name": "Karnak Temple",
      "location": "Luxor, Egypt",
      "image": "assets/images/karnak.jpg",
      "rating": "4.8",
      "price": "250 EGP",
      "category": "Architecture",
    },


    {
      "name": "Valley of the Kings",
      "location": "Luxor, Egypt",
      "image": "assets/images/valley.jpg",
      "rating": "4.7",
      "price": "400 EGP",
      "category": "History",
    },


  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: AppColors.surface,


      appBar: AppBar(

        backgroundColor: AppColors.surface,

        elevation:0,

        iconTheme:
        const IconThemeData(
          color: AppColors.primary,
        ),


        title: Text(

          "AI Recommendations",

          style: AppText.titleLg(
            color:AppColors.primary,
          ),

        ),

      ),



      body: Padding(

        padding:
        const EdgeInsets.all(
          AppSpacing.containerMargin,
        ),


        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [



            Text(

              "Wonders selected for you",

              style:
              AppText.headlineLgMobile(
                color:AppColors.primary,
              ),

            ),



            const SizedBox(height:8),



            Text(

              "Based on your interests, budget and available time",

              style:
              AppText.bodyMd(),

            ),



            const SizedBox(height:25),





            Expanded(

              child:ListView.builder(


                itemCount:
                places.length,


                itemBuilder:(context,index){


                  final place =
                  places[index];



                  return GestureDetector(


                    onTap:(){


                      Navigator.pushNamed(

                        context,

                        "/details",

                        arguments:place,

                      );


                    },



                    child:
                    RecommendationCard(

                      place:place,

                    ),


                  );


                },


              ),

            )



          ],

        ),

      ),


    );

  }

}







class RecommendationCard extends StatelessWidget {


  final Map<String,dynamic> place;



  const RecommendationCard({

    super.key,

    required this.place,

  });



  @override
  Widget build(BuildContext context) {


    return Container(

      margin:
      const EdgeInsets.only(
        bottom:20,
      ),



      height:180,



      decoration:BoxDecoration(


        color:
        AppColors.surfaceContainerLowest,


        borderRadius:
        BorderRadius.circular(
          AppRadius.md,
        ),


        boxShadow:[

          BoxShadow(

            color:
            Colors.black.withOpacity(0.08),

            blurRadius:10,

            offset:
            const Offset(0,5),

          )

        ],

      ),



      child:Row(


        children:[



          ClipRRect(

            borderRadius:
            const BorderRadius.only(

              topLeft:
              Radius.circular(24),

              bottomLeft:
              Radius.circular(24),

            ),


            child:
            Image.asset(

              place["image"],

              width:130,

              height:180,

              fit:BoxFit.cover,

            ),

          ),






          Expanded(

            child:
            Padding(

              padding:
              const EdgeInsets.all(16),


              child:
              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[



                  Text(

                    place["name"],

                    style:
                    AppText.titleLg(

                      color:
                      AppColors.primary,

                    ),

                  ),



                  const SizedBox(height:8),




                  Row(

                    children:[


                      const Icon(

                        Icons.location_on,

                        size:16,

                        color:
                        AppColors.secondary,

                      ),


                      const SizedBox(width:4),



                      Expanded(

                        child:Text(

                          place["location"],

                          style:
                          AppText.bodyMd(),

                        ),

                      )


                    ],

                  ),





                  const Spacer(),





                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,


                    children:[



                      Container(

                        padding:
                        const EdgeInsets.symmetric(

                          horizontal:10,

                          vertical:5,

                        ),


                        decoration:
                        BoxDecoration(

                          color:
                          AppColors.secondaryContainer,

                          borderRadius:
                          BorderRadius.circular(20),

                        ),


                        child:
                        Text(

                          place["price"],

                          style:
                          AppText.labelMd(

                            color:
                            AppColors.onSecondaryContainer,

                          ),

                        ),

                      ),





                      Row(

                        children:[


                          const Icon(

                            Icons.star,

                            size:18,

                            color:
                            Colors.amber,

                          ),


                          Text(

                            place["rating"],

                            style:
                            AppText.labelMd(),

                          )

                        ],

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