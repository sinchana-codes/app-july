import 'package:flutter/material.dart';

void main() {
  runApp(profilescreen());
}

class profilescreen extends StatelessWidget {
  @override
 Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(

      appBar:AppBar(title: Text("profile")),

      
      
      
      body: Center(

        child: Container(
         width: 300,
         padding: EdgeInsets.all(20),
         margin: EdgeInsets.all(20),
         decoration: BoxDecoration(
          color: Colors.lightBlue.shade200,
          borderRadius: BorderRadius.circular(12)
         ),
            
        child: Column(
          mainAxisSize: MainAxisSize.min,

            children: [

              Text("sinchana",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.cyan
              ),
              ),

              SizedBox(height: 20),


              Text("flutter developer"),

              SizedBox(height: 20),


              Text("India📍"),


              SizedBox(height: 15),

              TextButton(onPressed: (){}, child: Text("view details"))





            ],


        ),
        ),
      ),
    ),
  );


  }
}