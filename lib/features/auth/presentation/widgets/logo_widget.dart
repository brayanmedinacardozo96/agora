import 'package:flutter/material.dart';
import 'package:uicomponents/uicomponents.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLogoWidget(
      logo: Logo(type: LogoType.asset, source: "assets/img/logoeasy2.png"),
    );
  }
}
