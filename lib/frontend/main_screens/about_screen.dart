import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'About Chat ',
                  style: TextStyle(color: Colors.black87, fontSize: 20.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "A Private, Secure, End-to-End Encrypted Messaging app that helps you to connect with your connections without any Ads, promotion. No other third party person can't read your messages. Nobody can't take screenshot or can't do screen recording of this app.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Messages and Activity are End-to-End Encrypted',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 16.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Hope You Enjoying this app',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 50.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Creator\nAli Madad Haidari',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}