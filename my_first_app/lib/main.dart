import 'package:flutter/material.dart';

void main() {  //entry point of code
  runApp(Homescreen());    //what to run
}


//flutter - build the screen design
//class - blueprint extends widgetname

class Homescreen extends StatelessWidget {
  @override

    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(

          appBar: AppBar(title: Text("whatsapp📞")),


          body: Center(
            child: Text("welcome to my first flutter app"),
          ),

        ), //screenstructure 
      ); //everything on screen together we get output
    }


}
