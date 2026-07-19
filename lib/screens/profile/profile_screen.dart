import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';


class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: AppColors.surface,


      appBar: AppBar(

        backgroundColor: AppColors.surface,

        elevation: 0,

        iconTheme: const IconThemeData(
          color: AppColors.primary,
        ),


        title: Text(

          "Profile",

          style: AppText.titleLg(
            color: AppColors.primary,
          ),

        ),

      ),




      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(
          AppSpacing.containerMargin,
        ),


        child: Column(

          children: [



            // Profile Header

            Container(

              width: double.infinity,


              padding:
              const EdgeInsets.all(24),


              decoration: BoxDecoration(

                color:
                AppColors.surfaceContainerLowest,


                borderRadius:
                BorderRadius.circular(
                  AppRadius.lg,
                ),


                boxShadow:[

                  BoxShadow(

                    color:
                    Colors.black.withOpacity(0.06),

                    blurRadius:15,

                    offset:
                    const Offset(0,5),

                  )

                ],


              ),



              child:Column(

                children:[



                  CircleAvatar(

                    radius:45,


                    backgroundColor:
                    AppColors.primaryContainer,


                    child:
                    const Icon(

                      Icons.person,

                      size:50,

                      color:
                      AppColors.onPrimaryContainer,

                    ),

                  ),



                  const SizedBox(height:15),




                  Text(

                    "Mariam",

                    style:
                    AppText.headlineLgMobile(

                      color:
                      AppColors.primary,

                    ),

                  ),




                  const SizedBox(height:5),




                  Text(

                    "Heritage Explorer",

                    style:
                    AppText.bodyMd(),

                  ),



                ],

              ),

            ),





            const SizedBox(height:25),






            // Preferences


            Align(

              alignment:
              Alignment.centerLeft,


              child:Text(

                "Your Preferences",

                style:
                AppText.titleLg(

                  color:
                  AppColors.primary,

                ),

              ),

            ),



            const SizedBox(height:15),





            profileCard(

              icon:
              Icons.location_on_outlined,

              title:
              "Location",

              value:
              "Cairo, Egypt",

            ),




            profileCard(

              icon:
              Icons.account_balance_wallet_outlined,

              title:
              "Budget",

              value:
              "500 EGP",

            ),




            profileCard(

              icon:
              Icons.access_time,

              title:
              "Available Time",

              value:
              "Half Day",

            ),





            profileCard(

              icon:
              Icons.interests,

              title:
              "Interests",

              value:
              "History, Museums, Culture",

            ),







            const SizedBox(height:30),






            // Settings


            Align(

              alignment:
              Alignment.centerLeft,


              child:Text(

                "Settings",

                style:
                AppText.titleLg(

                  color:
                  AppColors.primary,

                ),

              ),

            ),



            const SizedBox(height:15),






            settingTile(

              icon:
              Icons.notifications_outlined,

              title:
              "Notifications",

            ),




            settingTile(

              icon:
              Icons.language,

              title:
              "App Language",

              trailing:
              "English",

            ),





            settingTile(

              icon:
              Icons.info_outline,

              title:
              "About Smart Heritage",

            ),




          ],

        ),

      ),


    );


  }






  Widget profileCard({

    required IconData icon,

    required String title,

    required String value,

  }){


    return Container(

      margin:
      const EdgeInsets.only(
        bottom:12,
      ),


      padding:
      const EdgeInsets.all(16),


      decoration:
      BoxDecoration(

        color:
        AppColors.surfaceContainer,


        borderRadius:
        BorderRadius.circular(
          AppRadius.dflt,
        ),

      ),



      child:Row(

        children:[



          Container(

            padding:
            const EdgeInsets.all(10),


            decoration:
            BoxDecoration(

              color:
              AppColors.secondaryContainer,


              shape:
              BoxShape.circle,

            ),


            child:
            Icon(

              icon,

              color:
              AppColors.onSecondaryContainer,

            ),

          ),



          const SizedBox(width:15),




          Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children:[


              Text(

                title,

                style:
                AppText.bodyMd(),

              ),



              const SizedBox(height:4),




              Text(

                value,

                style:
                AppText.titleLg(

                  color:
                  AppColors.primary,

                ),

              )

            ],

          )


        ],

      ),

    );


  }








  Widget settingTile({

    required IconData icon,

    required String title,

    String? trailing,

  }){


    return Container(

      margin:
      const EdgeInsets.only(
        bottom:12,
      ),


      decoration:
      BoxDecoration(

        color:
        AppColors.surfaceContainerLowest,


        borderRadius:
        BorderRadius.circular(
          AppRadius.dflt,
        ),

      ),


      child:
      ListTile(

        leading:
        Icon(

          icon,

          color:
          AppColors.primary,

        ),


        title:
        Text(

          title,

          style:
          AppText.bodyLg(

            color:
            AppColors.onSurface,

          ),

        ),



        trailing:
        trailing != null
            ? Text(
              trailing,
              style:
              AppText.bodyMd(),
            )
            : const Icon(
              Icons.arrow_forward_ios,
              size:16,
            ),


      ),


    );


  }


}