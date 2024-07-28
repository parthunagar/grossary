import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/main.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../language_cubit.dart';

class ChooseLanguage extends StatefulWidget {
  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  LanguageCubit _languageCubit;
  bool islogin = false;
  List<int> radioButtons = [0, -1, -1, -1, -1];
  String selectedLanguage, language;

  var userName;
  dynamic emailAddress;
  dynamic mobileNumber;
  dynamic _image;

  @override
  void initState() {
    super.initState();
    getSharedValue();

    _languageCubit = BlocProvider.of<LanguageCubit>(context);

    // getLanguage(context);
  }

  String getLanguage(BuildContext context) {
    String language;
    BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        // ignore: missing_return
        builder: (_, locale) {
          print('local  : ' + locale.toString());
          language = locale.toString();
        },
      ),
    );
    return language;
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name');
      emailAddress = prefs.getString('user_email');
      mobileNumber = prefs.getString('user_phone');
      _image = '$imagebaseUrl${prefs.getString('user_image')}';
      islogin = prefs.getBool('islogin');
      language = prefs.getString('language');
      print('lang :' + language);
    });
  }

  void getSelectedLanguage(List<String> languages) {
    print('getSelectedLanguage => language :' + language.toString());
    if (language == 'en') { selectedLanguage = languages[0];  }
    else if (language == 'fr') {  selectedLanguage = languages[3];  }
    else if (language == 'es') {  selectedLanguage = languages[1];  }
    else if (language == 'pt') {  selectedLanguage = languages[2];  }
    else if (language == 'ar') {  selectedLanguage = languages[4];  }
    else if (language == 'id') {  selectedLanguage = languages[5];  }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    List<String> languages = [locale.englishh, locale.spanishh, locale.portuguesee, locale.frenchh, locale.arabicc, locale.indonesiann];
    getSelectedLanguage(languages);
    return Scaffold(
      drawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: buildDrawer(context, userName, emailAddress, _image, islogin,
          onHit: () {
          SharedPreferences.getInstance().then((pref) {
            pref.clear().then((value) {
              // Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,MaterialPageRoute(builder: (context) {return GroceryLogin(); }), (Route<dynamic> route) => false);
              Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
            });
          });
        }),
      ),
      appBar: AppBar(
        title: Text(locale.languages, style: TextStyle(color: kMainHomeText, fontSize: 18)),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              // padding: EdgeInsets.all(6),
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
              ),
              child: IconButton(
                icon: ImageIcon(AssetImage('assets/Icon_awesome_align_right.png')),
                iconSize: 15,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/language_back.png"), fit: BoxFit.fitHeight),),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.only(left: 50), child: Image.asset('assets/logo_big_new.png', height: 120)),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16, bottom: 16),
                child: Text(locale.selectPreferredLanguage, style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 14, fontWeight: FontWeight.normal, color: kSearchIconColour),
                ),
              ),
              RadioGroup(selectedLanguage),
              // RadioButtonGroup(
              //   activeColor: kMainColor1,
              //   labelStyle: Theme.of(context).textTheme.caption,
              //   onSelected: (selectedLocale) {
              //     setState(() {
              //       selectedLanguage = selectedLocale;
              //     });
              //   },
              //   labels: languages,
              //   itemBuilder: (Radio radioButton, Text title, int i) {
              //     return Container(
              //       height: 40,
              //       color: Theme.of(context).scaffoldBackgroundColor,
              //       child: GestureDetector(
              //         onTap: (){
              //           setState(() {
              //             selectedLanguage = languages[i];
              //             radioButton.onChanged((selectedLocale)=>{
              //                 setState(() {
              //                   selectedLanguage = selectedLocale;
              //                 })
              //             });
              //           });
              //         },
              //         child: Row(
              //           children: [
              //             radioButton,
              //             Text(
              //               languages[i],
              //               style: Theme.of(context)
              //                   .textTheme
              //                   .subtitle1
              //                   .copyWith(fontSize: 19,fontWeight: selectedLanguage == languages[i]?FontWeight.bold:FontWeight.normal),
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              // ),
              // Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    color: kRoundButton,
                    iconGap: 12,
                    label: locale.save,
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String selected = prefs.getString("languageSelected");
                      print(selected);
                      if (selected == locale.englishh) {
                        _languageCubit.selectEngLanguage();
                        prefs.setString("languageSelected", null);
                      } else if (selected == locale.arabicc) {
                        _languageCubit.selectArabicLanguage();
                        prefs.setString("languageSelected", null);
                      } else if (selected == locale.portuguesee) {
                        _languageCubit.selectPortugueseLanguage();
                        prefs.setString("languageSelected", null);
                      } else if (selected == locale.frenchh) {
                        _languageCubit.selectFrenchLanguage();
                        prefs.setString("languageSelected", null);
                      } else if (selected == locale.spanishh) {
                        _languageCubit.selectSpanishLanguage();
                        prefs.setString("languageSelected", null);
                      } else if (selected == locale.indonesiann) {
                        _languageCubit.selectIndonesianLanguage();
                        prefs.setString("languageSelected", null);
                      }
                      // Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 50)
              // Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class RadioGroup extends StatefulWidget {
  String selectedLanguage;

  RadioGroup(String selectedLanguage) {
    this.selectedLanguage = selectedLanguage;
  }

  @override
  RadioGroupWidget createState() => RadioGroupWidget(selectedLanguage);
}

class NumberList {
  String number;
  int index;

  NumberList({this.number, this.index});
}

class RadioGroupWidget extends State {
  // List<String> languages = [
  //   locale.englishh,
  //   locale.spanishh,
  //   locale.portuguesee,
  //   locale.frenchh,
  //   locale.arabicc,
  //   locale.indonesiann,
  // ];
// Default Radio Button Selected Item.
  String radioItemHolder;

  // Group Value for Radio Button.
  int id;

  RadioGroupWidget(String selectedLanguage) {
    this.radioItemHolder = selectedLanguage;
  }

  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (radioItemHolder == locale.englishh) { id = 1; }
    else if (radioItemHolder == locale.spanishh) {  id = 2; }
    else if (radioItemHolder == locale.portuguesee) { id = 3; }
    else if (radioItemHolder == locale.frenchh) { id = 4; }
    else if (radioItemHolder == locale.arabicc) { id = 5; }
    else if (radioItemHolder == locale.indonesiann) { id = 6; }

    List<NumberList> nList = [
      NumberList(index: 1, number: locale.englishh),
      NumberList(index: 2, number: locale.spanishh),
      NumberList(index: 3, number: locale.portuguesee),
      NumberList(index: 4, number: locale.frenchh),
      NumberList(index: 5, number: locale.arabicc),
      NumberList(index: 6, number: locale.indonesiann),
    ];
    return Column(
    children: nList.map((data) =>GestureDetector(
    onTap: () async{
      setState(() {
        radioItemHolder = data.number;
        id = data.index;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("languageSelected", data.number);
      },
    child: RadioListTile(
      title: Text("${data.number}",
      style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 16,fontWeight:  radioItemHolder == data.number?FontWeight.bold:FontWeight.normal)),
        groupValue: id,
        value: data.index,
        onChanged: (val) async {
          setState(() {
            radioItemHolder = data.number;
            id = data.index;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("languageSelected", data.number);
        },
      ),
    )).toList(),
    );
  }
}
