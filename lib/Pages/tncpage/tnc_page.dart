import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/aboutus.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TNCPage extends StatefulWidget {
  @override
  TNCPageState createState() => TNCPageState();
}

class TNCPageState extends State<TNCPage> {
  var userName;


  dynamic emailAddress;
  dynamic mobileNumber;
  dynamic _image;

  bool islogin = false;
  dynamic title;
  dynamic content;
  // AboutUsData data;

  @override
  void initState() {
    super.initState();
    getWislist();
  }

  void getWislist() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = pref.getString('user_name');
      emailAddress = pref.getString('user_email');
      mobileNumber = pref.getString('user_phone');
      _image = '$imagebaseUrl${pref.getString('user_image')}';
      islogin = pref.getBool('islogin');
    });
    var url = appTermsUri;
    var http = Client();
    http.get(url).then((value){
      print('resp - ${value.body}');
      if(value.statusCode == 200){
        AboutUsMain data1 = AboutUsMain.fromJsom(jsonDecode(value.body));
        print('${data1.toString()}');
        if(data1.status=="1" || data1.status==1){
          setState(() {
            title = data1.data.title;
            content = data1.data.description;
          });
        }
      }
    }).catchError((e){
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: buildDrawer(context, userName,emailAddress,_image, islogin, onHit: () {
          SharedPreferences.getInstance().then((pref) {
            pref.clear().then((value) {
              // Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
              //     MaterialPageRoute(builder: (context) {
              //       return GroceryLogin();
              //     }), (Route<dynamic> route) => false);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.signInRoot, (Route<dynamic> route) => false);
            });
          });
        }),
      ),

      // appBar: AppBar(
      //   title: Text(
      //     locale.aboutUs,
      //     style: TextStyle(color: kMainTextColor),
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/t_c_back.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.black12,
                              spreadRadius: 1)
                        ],
                      ),
                      height: 30,
                      width: 30,
                      child: IconButton(
                        icon: ImageIcon(AssetImage(
                          'assets/Icon_awesome_align_right.png',
                        ),),
                        iconSize: 15,
                        onPressed: () {
                          _scaffoldKey.currentState.openDrawer();
                        },
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      ),
                    ),
                  ),
                  Center(
                      child: Text(
                        locale.tnc,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: kMainHomeText, fontSize: 18),
                      )),
                ],
              ),
            ),
            Image.asset(
              'assets/t_c_image.png',
              scale: 1,
              height: 280,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (title!=null)?'${title}':'',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: kTextBlack),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Text(
            //   'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis.\n',
            //   style:
            //       Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 15),
            // ),
            (content!=null)?
            Html(
              data: content,
              style: {
                "html": Style(
                  fontSize: FontSize.large,
//              color: Colors.white,
                ),
              },
            ):Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(kRoundButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
