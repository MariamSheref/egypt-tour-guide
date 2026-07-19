import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';


class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}


class _QuestionnaireScreenState extends State<QuestionnaireScreen> {


  final TextEditingController ageController =
      TextEditingController();

  final TextEditingController budgetController =
      TextEditingController();


  String? location;
  String? availableTime;


  List<String> selectedInterests = [];


  final List<String> interests = [

    "History",
    "Museums",
    "Architecture",
    "Culture",
    "Adventure",
    "Photography",

  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: AppColors.surface,


      appBar: AppBar(

        backgroundColor: AppColors.surface,

        elevation: 0,

        title: Text(
          "Plan Your Journey",
          style: AppText.titleLg(
            color: AppColors.primary,
          ),
        ),

        iconTheme: const IconThemeData(
          color: AppColors.primary,
        ),

      ),



      body: SingleChildScrollView(

        padding: const EdgeInsets.all(
          AppSpacing.containerMargin,
        ),


        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,


          children: [



            Text(
              "Tell us about yourself",
              style: AppText.headlineLgMobile(
                color: AppColors.primary,
              ),
            ),



            const SizedBox(height: 8),



            Text(
              "We will use your preferences to create "
              "AI-powered heritage recommendations.",
              style: AppText.bodyMd(),
            ),



            const SizedBox(
              height: 30,
            ),





            // Age

            buildTextField(

              controller: ageController,

              label: "Age",

              icon: Icons.person_outline,

              keyboard:
              TextInputType.number,

            ),



            const SizedBox(height:20),





            // Budget

            buildTextField(

              controller: budgetController,

              label: "Budget (EGP)",

              icon:
              Icons.account_balance_wallet_outlined,

              keyboard:
              TextInputType.number,

            ),




            const SizedBox(height:20),





            // Location

            Text(
              "Your Location",
              style: AppText.titleLg(
                color: AppColors.primary,
              ),
            ),


            const SizedBox(height:10),


            DropdownButtonFormField<String>(

              value: location,


              decoration:
              inputDecoration(
                Icons.location_on_outlined,
              ),


              items:[

                "Cairo",
                "Giza",
                "Luxor",
                "Aswan",
                "Alexandria",

              ].map((city){

                return DropdownMenuItem(

                  value:city,

                  child:Text(city),

                );

              }).toList(),


              onChanged:(value){

                setState(() {

                  location=value;

                });

              },

            ),





            const SizedBox(height:20),




            // Time


            Text(
              "Available Time",
              style: AppText.titleLg(
                color: AppColors.primary,
              ),
            ),



            const SizedBox(height:10),



            DropdownButtonFormField<String>(

              value: availableTime,


              decoration:
              inputDecoration(
                Icons.access_time,
              ),



              items:[

                "1-2 Hours",
                "Half Day",
                "Full Day",
                "Multiple Days",

              ].map((time){

                return DropdownMenuItem(

                  value:time,

                  child:Text(time),

                );

              }).toList(),



              onChanged:(value){

                setState(() {

                  availableTime=value;

                });

              },


            ),





            const SizedBox(height:30),






            Text(

              "Your Interests",

              style: AppText.titleLg(
                color: AppColors.primary,
              ),

            ),




            const SizedBox(height:15),




            Wrap(

              spacing:10,

              runSpacing:10,


              children: interests.map((interest){


                bool selected =
                selectedInterests.contains(
                  interest,
                );



                return FilterChip(


                  label:Text(
                    interest,
                  ),


                  selected:selected,


                  selectedColor:
                  AppColors.secondaryContainer,



                  backgroundColor:
                  AppColors.surfaceContainer,



                  labelStyle:
                  TextStyle(

                    color:selected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,

                    fontWeight:
                    FontWeight.w500,

                  ),



                  onSelected:(value){


                    setState(() {


                      if(value){

                        selectedInterests.add(
                          interest,
                        );

                      }
                      else{

                        selectedInterests.remove(
                          interest,
                        );

                      }


                    });


                  },


                );

              }).toList(),


            ),





            const SizedBox(height:40),






            // Button


            Container(

              width:double.infinity,

              height:55,


              decoration:BoxDecoration(

                gradient:
                AppColors.goldGradient,


                borderRadius:
                BorderRadius.circular(
                  AppRadius.full,
                ),

              ),



              child:ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.transparent,

                  shadowColor:
                  Colors.transparent,

                ),



                onPressed:(){


                  // هنا بعدين نروح recommendation


                },



                child:Text(

                  "Find My Journey",

                  style:
                  AppText.titleLg(
                    color:Colors.white,
                  ),

                ),

              ),


            ),



          ],

        ),

      ),


    );

  }







  Widget buildTextField({

    required TextEditingController controller,

    required String label,

    required IconData icon,

    TextInputType? keyboard,

  }){


    return TextField(

      controller:controller,

      keyboardType:keyboard,


      decoration:
      inputDecoration(icon)
          .copyWith(
            labelText:label,
          ),


    );

  }







  InputDecoration inputDecoration(
      IconData icon
      ){

    return InputDecoration(

      prefixIcon:
      Icon(
        icon,
        color:AppColors.primary,
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


    );

  }


}