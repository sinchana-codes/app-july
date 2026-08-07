import 'package:flutter/material.dart';

void main() {
  runApp(myportfolio());
}

class myportfolio  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("My Portfolio"),
        ),
        body: Padding(
          padding:EdgeInsets.all(18) ,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: CircleAvatar(
                  radius: 50,
                  
                ),
              ),
              SizedBox(height: 15),
              
              Center(
                child: Text(
                  "sinchana B",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  color: Colors.black38
                  
                  ),
                ),
              ),
              Center(
                child: Text(
                  "computer science student",
                  style: TextStyle(fontSize: 18),
                selectionColor: Colors.blueAccent,
                ),
              ),
              Center(
                child: Text(
                  "acharya institute of technology",
                  style: TextStyle(fontSize: 18),
                selectionColor: Colors.blueAccent,
                ),
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  "gmail: sinchanab62@gmail.com",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}