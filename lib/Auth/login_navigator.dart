import 'package:flutter/material.dart';
import 'package:groshop/Auth/Login/sign_in.dart';
import 'package:groshop/Auth/Login/sign_up.dart';
import 'package:groshop/Routes/routes.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class SignInRoutes {
//   static const String signInRoot = 'signIn/';
//   static const String signUp = 'signUp';
//   static const String verification = 'verification';
//   static const String restpassword1 = 'restpassword1';
//   static const String restpassword2 = 'restpassword2';
//   static const String restpassword3 = 'restpassword3';
//   static const String home = 'home';
// }

class SignInNavigator extends StatelessWidget {
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
        initialRoute: PageRoutes.signInRoot,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case PageRoutes.signInRoot:
              builder = (BuildContext _) => SignIn();
              break;
            case PageRoutes.signUp:
              builder = (BuildContext _) => SignUp();
              break;
            case PageRoutes.restpassword1:
              // builder = (BuildContext _) => NumberScreenRestPassword(() {
              //       Navigator.pop(_);
              //     });
              break;
            case PageRoutes.restpassword2:
              // builder = (BuildContext _) => ResetOtpVerify(() {
              //   Navigator.pop(_);
              //     });
              break;
            case PageRoutes.restpassword3:
              // builder = (BuildContext _) => ChangePassword(() {
              //   Navigator.popAndPushNamed(_,SignInRoutes.signInRoot);
              //     });
              break;
            case PageRoutes.verification:
              // builder = (BuildContext _) => VerificationPage(() {
              //       Navigator.popAndPushNamed(context, PageRoutes.homePage);
              //     });
              break;
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
