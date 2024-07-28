import 'package:driver/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:driver/Routes/routes.dart';

import 'Login/sign_in.dart';
import 'Login/sign_up.dart';
import 'Login/verification.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SignInRoutes {
  static const String signInRoot = 'signIn/';
  static const String signUp = 'signUp';
  static const String verification = 'verification';
  // static const String homepage = 'homepage';
}

class SignInNavigator extends StatelessWidget {
  // final bool result;
  // SignInNavigator(this.result);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var canPop = navigatorKey.currentState.canPop();
        if (canPop) {
          navigatorKey.currentState.pop();
        }
        return !canPop;
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: SignInRoutes.signInRoot,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case SignInRoutes.signInRoot:
              builder = (BuildContext _) => SignIn((){
                Navigator.popAndPushNamed(context, PageRoutes.homePage);
              });
            break;
            case SignInRoutes.signUp:
              builder = (BuildContext _) => SignUp();
            break;
            case SignInRoutes.verification:
              builder = (BuildContext _) => VerificationPage(() =>
                  Navigator.popAndPushNamed(context, PageRoutes.homePage));
            break;
            // case SignInRoutes.homepage:
            //   builder = (BuildContext _) => HomePage();
            //   break;
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
        onPopPage: (Route<dynamic> route, dynamic result) {
          return route.didPop(result);
        },
      ),
    );
  }
}
