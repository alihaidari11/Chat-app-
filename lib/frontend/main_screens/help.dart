import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (){
              Navigator.pop(context);
            },

            borderRadius: BorderRadius.circular(30),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
      ),
      body: Container(

        alignment: Alignment.center,
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
            const SizedBox(height: 30,),
            const Text(
                  'Contact Us',
                  style: TextStyle(color: Colors.black87, fontSize: 20.0),
                ),
            const SizedBox(height: 15,),


            ListTile(
                    title: Row(
                      children: const <Widget>[
                        SizedBox(width: 40,),
                        Icon(Icons.phone),
                        SizedBox(
                          width: 30,
                        ),
                        Text('+93774425830'),
                      ],
                    ),
                  ),
            ListTile(
              title: Row(
                children: const <Widget>[
                  SizedBox(width: 40,),
                  Icon(Icons.email),
                  SizedBox(
                    width: 30,
                  ),
                  Text('alimadadh02@gmail.com'),
                ],
              ),
            ),

            ],
            )


      ),
    );
  }
}