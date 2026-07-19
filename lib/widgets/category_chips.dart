import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}


class _CategoryChipsState extends State<CategoryChips> {

  int selectedIndex = 0;


  final categories = [
    {
      "icon": Icons.explore,
      "title": "All Sites"
    },
    {
      "icon": Icons.account_balance,
      "title": "Museums"
    },
    {
      "icon": Icons.temple_hindu,
      "title": "Temples"
    },
    {
      "icon": Icons.mosque,
      "title": "Mosques"
    },
  ];


  @override
  Widget build(BuildContext context) {

    return SizedBox(

      height: 45,

      child: ListView.builder(

        scrollDirection: Axis.horizontal,

        itemCount: categories.length,

        itemBuilder: (context,index){

          bool selected =
              selectedIndex == index;


          return GestureDetector(

            onTap: (){
              setState(() {
                selectedIndex = index;
              });
            },


            child: Container(

              margin:
              const EdgeInsets.only(right:12),


              padding:
              const EdgeInsets.symmetric(
                horizontal:20,
              ),


              decoration: BoxDecoration(

                borderRadius:
                BorderRadius.circular(30),


                gradient: selected
                    ? const LinearGradient(
                  colors:[
                    Color(0xfffecc87),
                    Color(0xff7c571e),
                  ],
                )

                    : null,


                color:
                selected
                    ? null
                    : Colors.white,


                border:
                selected
                    ? null
                    : Border.all(
                  color:
                  Colors.grey.shade300,
                ),

              ),


              child: Row(

                children: [

                  Icon(
                    categories[index]["icon"]
                    as IconData,

                    size:18,

                    color:
                    selected
                        ? Colors.white
                        : Colors.black87,
                  ),


                  const SizedBox(width:8),


                  Text(

                    categories[index]["title"]
                    as String,


                    style: TextStyle(

                      fontSize:13,

                      fontWeight:
                      FontWeight.w500,


                      color:
                      selected
                          ? Colors.white
                          : Colors.black87,

                    ),
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}