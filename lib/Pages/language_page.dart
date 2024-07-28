import 'package:driver/Const/constant.dart';
import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:driver/Components/custom_button.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/language_cubit.dart';
import 'dart:developer' as logger;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LanguagePage extends StatefulWidget {
  // String _selected;
  // LanguagePage ({this._selected});
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  LanguageCubit _languageCubit;
  String selectedLocal;
  String selectedLanguage, language;

  @override
  void initState() {
    super.initState();
    getSharedValue();
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language');
      print('lang : ' + language);
    });
  }

  void getSelectedLanguage(var languages) {
    print('lang :' + language);
    if (language == 'en') {
      selectedLanguage = languages[0];
      print("selectedLanguage : "+selectedLanguage);
    } else if (language == 'ar') {
      selectedLanguage = languages[1];
    } else if (language == 'fr') {
      selectedLanguage = languages[2];
    } else if (language == 'id') {
      selectedLanguage = languages[3];
    } else if (language == 'pt') {
      selectedLanguage = languages[4];
    } else if (language == 'es') {
      selectedLanguage = languages[5];
    }
  }



  // saveLanguagePref(String s) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString("language", s);
  // }

  @override
  Widget build(BuildContext context) {
    // print(_languageCubit.selectArabicLanguage());
    var locale = AppLocalizations.of(context);
    final List<String> languages = [
      locale.englishh,
      locale.arabicc,
      locale.frenchh,
      locale.indonesiann,
      locale.portuguesee,
      locale.spanishh,
    ];
    getSelectedLanguage(languages);
    var theme = Theme.of(context);
    getSelectedLanguage(languages);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState.openDrawer();
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                  color: kWhiteColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.012,
                        horizontal: MediaQuery.of(context).size.width * 0.022),
                    child: Image.asset("assets/images/awesome_align_right.png"),
                  )),
            )),
        title: Text(
          locale.languages,
          style: TextStyle(
            fontFamily: 'Philosopher-Regular',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: AccountDrawer(context),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "assets/images/language_back.png",
              fit: BoxFit.fill,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                // color: kRedLightColor,
                height: MediaQuery.of(context).size.height * 0.16,
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.15),
                // width: MediaQuery.of(context).size.width *0.1,
                child: Image.asset(
                  'assets/images/driver_logo.png',
                  // height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 19),
                child: Text(
                  // locale.selectPreferredLanguage.toUpperCase(),
                  locale.selectPreferredLanguage,
                  style: theme.textTheme.headline6
                      .copyWith(fontSize: 16, fontFamily: balooRegular),
                ),
              ),
              RadioGroup(selectedLanguage),
              //*******************************************************************//
              // RadioButtonGroup(
              //   labels: languages.map((e) => e).toList(),
              //   itemBuilder: (Radio radioButton, Text title, int i) {
              //     return GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           selectedLocal = languages[i];
              //         });
              //       },
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           // radioButton,
              //           Radio(
              //             activeColor: kRedLightColor,
              //             value: languages[i],
              //             groupValue: selectedLocal,
              //             onChanged: (selectedLocale) {
              //               setState(() {
              //                 selectedLocal = selectedLocale;
              //               });
              //             },
              //           ),
              //           Flexible(
              //             child: Text(
              //               languages[i],
              //               overflow: TextOverflow.fade,
              //               style: theme.textTheme.headline6.copyWith(
              //                   color: theme.backgroundColor,
              //                   fontSize: 17,
              //                   fontFamily: balooRegular,
              //                   fontWeight: selectedLocal == languages[i]
              //                       ? FontWeight.bold
              //                       : FontWeight.w100),
              //             ),
              //           )
              //         ],
              //       ),
              //
              //       // child: ListTile(
              //       //   dense: true,
              //       //   contentPadding: EdgeInsets.all(0),
              //       //   leading: radioButton,
              //       //   title: Text(
              //       //     languages[i],
              //       //     style: theme.textTheme.headline6.copyWith(
              //       //         color: theme.backgroundColor,
              //       //         fontSize: 16,
              //       //         fontWeight: selectedLocal == languages[i]
              //       //             ? FontWeight.bold
              //       //             : FontWeight.w100),
              //       //   ),
              //       // ),
              //     );
              //   },
              // ),
              //*******************************************************************//
              SizedBox(height: 25,),
              // CustomButton(
              // onTap: () {
              //   if (selectedLocal == locale.englishh) {
              //     _languageCubit.selectEngLanguage();
              //   } else if (selectedLocal == locale.arabicc) {
              //     _languageCubit.selectArabicLanguage();
              //   } else if (selectedLocal == locale.portuguesee) {
              //     _languageCubit.selectPortugueseLanguage();
              //   } else if (selectedLocal == locale.frenchh) {
              //     _languageCubit.selectFrenchLanguage();
              //   } else if (selectedLocal == locale.spanishh) {
              //     _languageCubit.selectSpanishLanguage();
              //   } else if (selectedLocal == locale.indonesiann) {
              //     _languageCubit.selectIndonesianLanguage();
              //   }
              //   Navigator.pop(context);
              // }
              // ),
              CustomRedButton(
                  label: locale.save,
                  fontFamily: balooExtraBold,
                  fontSize: 17,
                  // color: kRedLightColor,
                  height: MediaQuery.of(context).size.height * 0.06,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02),
                  // margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width * 0.36),
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.37,
                      right: MediaQuery.of(context).size.width * 0.37),
                  prefixIcon: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: kRedLightColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.012,
                          horizontal:
                              MediaQuery.of(context).size.width * 0.022),
                      child: Image.asset(
                        "assets/images/feather_save.png",
                      ),
                    ),
                  ),

                onTap: () async {
                  print("=============================================");
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String selected = prefs.getString("languageSelected");
                  print("============================================="+selected.toString());
                  if (selected == locale.englishh) {
                    _languageCubit.selectEngLanguage();
                    Toast.show(locale.englishSelected,  context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                    prefs.setString("languageSelected", null);
                  } else if (selected == locale.arabicc) {
                    _languageCubit.selectArabicLanguage();
                    prefs.setString("languageSelected", null);
                    Toast.show(locale.arabicSelected,  context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  } else if (selected == locale.portuguesee) {
                    _languageCubit.selectPortugueseLanguage();
                    prefs.setString("languageSelected", null);
                    Toast.show(locale.portugueseSelected,  context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  } else if (selected == locale.frenchh) {
                    _languageCubit.selectFrenchLanguage();
                    prefs.setString("languageSelected", null);
                    Toast.show(locale.frenchSelected,  context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  } else if (selected == locale.spanishh) {
                    _languageCubit.selectSpanishLanguage();
                    prefs.setString("languageSelected", null);
                    Toast.show(locale.spanishSelected,  context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  } else if (selected == locale.indonesiann) {
                    _languageCubit.selectIndonesianLanguage();
                    prefs.setString("languageSelected", null);
                    Toast.show(locale.indonesianSelected,  context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  }
                  Navigator.pop(context);
                },
                  //***********************************************************
                  // onTap: () async {
                  //   // SharedPreferences prefs = await SharedPreferences.getInstance();
                  //   // String selected = prefs.getString("languageSelected");
                  //   // print(selected);
                  //   if (selectedLocal == locale.englishh) {
                  //     _languageCubit.selectEngLanguage();
                  //   } else if (selectedLocal == locale.arabicc) {
                  //     _languageCubit.selectArabicLanguage();
                  //   } else if (selectedLocal == locale.portuguesee) {
                  //     _languageCubit.selectPortugueseLanguage();
                  //   } else if (selectedLocal == locale.frenchh) {
                  //     _languageCubit.selectFrenchLanguage();
                  //   } else if (selectedLocal == locale.spanishh) {
                  //     _languageCubit.selectSpanishLanguage();
                  //   } else if (selectedLocal == locale.indonesiann) {
                  //     _languageCubit.selectIndonesianLanguage();
                  //   }
                  //   Navigator.pop(context);
                  // }
                  //*************************************************************

                  )
            ],
          ),
        ],
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
// Default Radio Button Selected Item.
  String radioItemHolder;

  // Group Value for Radio Button.
  int id;

  RadioGroupWidget(String selectedLanguage) {
    this.radioItemHolder = selectedLanguage;
  }

  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (radioItemHolder == locale.englishh) {
      id = 1;
    } else if (radioItemHolder == locale.spanishh) {
      id = 2;
    } else if (radioItemHolder == locale.portuguesee) {
      id = 3;
    } else if (radioItemHolder == locale.frenchh) {
      id = 4;
    } else if (radioItemHolder == locale.arabicc) {
      id = 5;
    } else if (radioItemHolder == locale.indonesiann) {
      id = 6;
    }

    List<NumberList> nList = [
      NumberList(
        index: 1,
        number: locale.englishh,
      ),
      NumberList(
        index: 2,
        number: locale.spanishh,
      ),
      NumberList(
        index: 3,
        number: locale.portuguesee,
      ),
      NumberList(
        index: 4,
        number: locale.frenchh,
      ),
      NumberList(
        index: 5,
        number: locale.arabicc,
      ),
      NumberList(
        index: 6,
        number: locale.indonesiann,
      ),
    ];
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.start,
      children: nList
          .map((data) => GestureDetector(
                onTap: () async {
                  setState(() {
                    radioItemHolder = data.number;
                    id = data.index;
                  });
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("languageSelected", data.number);
                },
                child: RadioListTile(
                  dense: true,
                  title: Text(
                    "${data.number}",
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 16,
                        fontWeight: radioItemHolder == data.number
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                  groupValue: id,
                  activeColor: kRedLightColor,
                  value: data.index,
                  onChanged: (val) async {
                    setState(() {
                      radioItemHolder = data.number;
                      id = data.index;
                    });
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("languageSelected", data.number);
                  },
                ),
              ))
          .toList(),
    );
  }
}
