import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/screens/login/cubit/card_cubit.dart';
import 'package:warehouse_amf/screens/widgets/ip_config_card.dart';
import 'package:warehouse_amf/screens/login/widgets/login_card.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen>
    with SingleTickerProviderStateMixin {
  //anim controller for setting icon rotation
  late AnimationController animController;
  double sizeAddition = 0;
  //to check if state was rebuilt using setState or bloc!
  CardState lastState = LogInState();

  @override
  void initState() {
    animController = AnimationController(
      vsync: this,
      duration: kAnimDuration,
    );
    //update state as anim is going on
    animController.addListener(() {
      setState(() {});
    });

    //reset sizeAddition when animation is completed
    animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        sizeAddition = 0;
        animController.reset();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cardCubit = BlocProvider.of<CardCubit>(context);
    final size = MediaQuery.of(context).size;
    //size addition is used to create pumping anim for cards
    //do nothing wehn anim value is 0 or else cards grows bigger with every setstate
    if (animController.value != 0) {
      sizeAddition =
          animController.value <= 0.5 ? (sizeAddition + 5) : (sizeAddition - 5);
    }

    double cardWidth = size.width * 0.8 + sizeAddition;
    double cardHeight = size.height * 0.5 + sizeAddition;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        //a bloc listener for sowing username and pass validation result

        child: MultiBlocListener(
          listeners: [
            BlocListener<UserAuthCubit, UserAuthState>(
              listener: (BuildContext context, UserAuthState uthState) {
                if (uthState is UserUnAuthorized) {
                  Vibration.vibrate();
                  ToastHelper.showErrorToast(
                    Text(Translations.error.name.tr()),
                    Text(uthState.message),
                  );
                } else if (uthState is UserAuthorized) {
                  Navigator.pushReplacementNamed(context, kRouteHome);
                  ToastHelper.showSuccessToast(
                    null,
                    Text(Translations.welcome.name.tr()),
                  );
                }
              },
            ),
          ],

          //a bloc builder to rebuild state when login ip card changes
          child: BlocBuilder<CardCubit, CardState>(
            builder: (context, state) {
              if (state.toString() != lastState.toString()) {
                //update is caused by bloc
                animController.forward();
                lastState = state;
              }
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Transform.rotate(
                          angle: pi *
                              animController.value *
                              (state is LogInState ? 1 : -1), //rotation
                          child: IconButton(
                            onPressed: () {
                              cardCubit.changeState();
                            },
                            icon: const Icon(
                              size: 35,
                              Icons.settings,
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: kAnimDuration,
                          opacity: state is LogInState ? 0 : 1,
                          child: Text(Translations.ipConfiguration.name.tr()),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: kAnimDuration,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      width: cardWidth > 500 ? 500 + sizeAddition : cardWidth,
                      height:
                          cardHeight > 700 ? 700 + sizeAddition : cardHeight,
                      child: state is LogInState
                          ? const LogInCard()
                          : const IpConfigCard(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
