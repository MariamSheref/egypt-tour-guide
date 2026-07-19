import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/category_chips.dart';


class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.surface,


      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(
            AppSpacing.containerMargin,
          ),


          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children: [


              // Top Bar

              Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,


                children: [


                  Row(

                    children: [


                      Icon(
                        Icons.menu,
                        color: AppColors.primary,
                      ),


                      const SizedBox(width: 10),



                      Text(

                        "Smart Heritage",

                        style:
                        AppText.titleLg(
                          color: AppColors.primary,
                        ),

                      ),


                    ],
                  ),




                  const CircleAvatar(

                    radius:20,

                    backgroundImage:
                    AssetImage(
                      "assets/images/profile.jpg",
                    ),

                  ),


                ],
              ),




              const SizedBox(
                height: 35,
              ),




              Text(

                "Good morning, Alexander",

                style:
                AppText.headlineLgMobile(
                  color: AppColors.primary,
                ),

              ),




              const SizedBox(height:8),




              Text(

                "Where shall history take you today?",

                style:
                AppText.bodyMd(),

              ),





              const SizedBox(height:20),





              // Search Bar

              TextField(

                decoration:
                InputDecoration(

                  hintText:
                  "Search ancient wonders...",


                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),


                  filled:true,


                  fillColor:
                  AppColors.surfaceContainer,


                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(
                      AppRadius.full,
                    ),

                    borderSide:
                    BorderSide.none,

                  ),

                ),
              ),




              const SizedBox(height:25),




              // Categories

              const CategoryChips(),





              const SizedBox(height:30),





              Text(

                "AI-Recommended Wonders",

                style:
                AppText.titleLg(
                  color: AppColors.primary,
                ),

              ),





              const SizedBox(height:15),




              SizedBox(

                height:420,


                child:
                ListView(

                  scrollDirection:
                  Axis.horizontal,


                  children: [


                    _recommendationCard(

                      "assets/images/pyramid.jpg",

                      "Pyramids of Giza",

                      "Cairo, Egypt",

                      "4.9",

                    ),




                    _recommendationCard(

                      "assets/images/karnak.jpg",

                      "Karnak Temple",

                      "Luxor, Egypt",

                      "4.8",

                    ),




                    _recommendationCard(

                      "assets/images/sphinx.jpg",

                      "Great Sphinx",

                      "Giza, Egypt",

                      "4.7",

                    ),


                  ],

                ),

              ),



            ],
          ),
        ),
      ),
    );
  }





  Widget _recommendationCard(

      String image,
      String title,
      String location,
      String rating,

      ){

    return Container(

      width:280,

      margin:
      const EdgeInsets.only(
        right:16,
      ),


      decoration:
      BoxDecoration(

        borderRadius:
        BorderRadius.circular(
          AppRadius.md,
        ),

        image:
        DecorationImage(

          image:
          AssetImage(image),

          fit:BoxFit.cover,

        ),

      ),



      child:
      Container(

        padding:
        const EdgeInsets.all(16),


        decoration:
        BoxDecoration(

          borderRadius:
          BorderRadius.circular(
            AppRadius.md,
          ),


          gradient:
          const LinearGradient(

            begin:
            Alignment.bottomCenter,

            end:
            Alignment.topCenter,

            colors: [

              Colors.black54,

              Colors.transparent,

            ],

          ),

        ),



        child:
        Column(

          mainAxisAlignment:
          MainAxisAlignment.end,


          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [


            Text(

              title,

              style:
              const TextStyle(

                color:Colors.white,

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(height:5),




            Text(

              location,

              style:
              const TextStyle(

                color:Colors.white70,

              ),

            ),




            Text(

              "⭐ $rating",

              style:
              const TextStyle(

                color:Colors.white,

              ),

            ),

          ],
        ),
      ),
    );
  }

}