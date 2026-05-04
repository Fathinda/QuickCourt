import 'package:flutter/material.dart';

import '../constants.dart';

ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.2, horizontal: defaultPadding),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    minimumSize: const Size(double.infinity, 52),
    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    animationDuration: animDurationMedium,
  ).copyWith(
    overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.12)),
    elevation: WidgetStateProperty.resolveWith<double>((states) {
      if (states.contains(WidgetState.pressed)) return 0;
      if (states.contains(WidgetState.hovered)) return 6;
      return 2;
    }),
    shadowColor: WidgetStateProperty.all(primaryColor.withOpacity(0.3)),
  ),
);

OutlinedButtonThemeData outlinedButtonTheme(
    {Color borderColor = blackColor10}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(defaultPadding),
      minimumSize: const Size(double.infinity, 52),
      side: BorderSide(width: 1.5, color: borderColor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      animationDuration: animDurationMedium,
    ),
  );
}

final textButtonThemeData = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: primaryColor,
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
