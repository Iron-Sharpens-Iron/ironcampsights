// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:news/cubits/Auth/registerTokenCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/languageJsonCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/cubits/themeCubit.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:news/ui/widgets/Slideanimation.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with TickerProviderStateMixin {
  AnimationController? _splashIconController;
  AnimationController? _newsImgController;
  AnimationController? _slideControllerBottom;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    fetchAppConfigurations();

    FirebaseMessaging.instance.getToken().then((token) async {
      if (token != null) context.read<RegisterTokenCubit>().registerToken(fcmId: token, context: context);
      if (token != context.read<SettingsCubit>().getSettings().token && token != null) {
        context.read<SettingsCubit>().changeToken(token);
      }
    });

    _slideControllerBottom = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _splashIconController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _newsImgController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    changeOpacity();
  }

  fetchAppConfigurations() {
    Future.delayed(Duration.zero, () {
      context.read<AppConfigurationCubit>().fetchAppConfiguration();
    });
  }

  fetchLanguages({required AppConfigurationFetchSuccess state}) async {
    String? currentLanguage = Hive.box(settingsBoxKey).get(currentLanguageCodeKey);
    if (currentLanguage == null) {
      //default language effects only for first time.
      context
          .read<AppLocalizationCubit>()
          .changeLanguage(state.appConfiguration.defaultLanDataModel![0].code!, state.appConfiguration.defaultLanDataModel![0].id!, state.appConfiguration.defaultLanDataModel![0].isRTL!);
      context.read<LanguageJsonCubit>().fetchCurrentLanguageAndLabels(state.appConfiguration.defaultLanDataModel![0].code!);
    } else {
      context.read<LanguageJsonCubit>().fetchCurrentLanguageAndLabels(currentLanguage);
    }
  }

  changeOpacity() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        opacity = (opacity == 0.0) ? 1.0 : 0.0;
      });
    });
  }

  @override
  void dispose() {
    _splashIconController!.dispose();
    _newsImgController!.dispose();
    _slideControllerBottom!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) UiUtils.setUIOverlayStyle(appTheme: context.read<ThemeCubit>().state.appTheme); //set UiOverlayStyle according to selected theme
    return Scaffold(backgroundColor: backgroundColor, body: buildScale());
  }

  Future<void> navigationPage() async {
    Future.delayed(const Duration(seconds: 4), () async {
      Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);

    });
  }

  Widget buildScale() {
    return BlocConsumer<AppConfigurationCubit, AppConfigurationState>(
        bloc: context.read<AppConfigurationCubit>(),
        listener: (context, state) {
          if (state is AppConfigurationFetchSuccess) {
            fetchLanguages(state: state);
          }
        },
        builder: (context, state) {
          return BlocConsumer<LanguageJsonCubit, LanguageJsonState>(
              bloc: context.read<LanguageJsonCubit>(),
              listener: (context, state) {
                if (state is LanguageJsonFetchSuccess) {
                  navigationPage();
                }
              },
              builder: (context, langState) {
                if (state is AppConfigurationFetchFailure) {
                  return ErrorContainerWidget(
                    errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage,
                    onRetry: () {
                      fetchAppConfigurations();
                    },
                  );
                } else if (langState is LanguageJsonFetchFailure) {
                  return ErrorContainerWidget(
                    errorMsg: (langState.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : langState.errorMessage,
                    onRetry: () {
                      fetchLanguages(state: state as AppConfigurationFetchSuccess);
                    },
                  );
                } else {
                  return Container(
                    width: double.maxFinite,
                    decoration: const BoxDecoration(color: darkSecondaryColor),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [const SizedBox(height: 220), splashLogoIcon(), subTitle(), const Spacer()]),
                  );
                }
              });
        });
  }

  bool isMaskOpen = true; // A flag to control the animation

  Widget splashLogoIcon() {
    return Center(child: Image.asset("assets/images/svgImage/logo.png", height: 100,));
  }



  Widget subTitle() {
    return AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(seconds: 1),
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
            child: CustomTextLabel(text: "Camp Iron Sights", textAlign: TextAlign.center, textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: backgroundColor))));
  }


}
