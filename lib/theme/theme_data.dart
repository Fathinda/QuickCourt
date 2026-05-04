import 'package:flutter/material.dart';

import '../constants.dart';

const AppBarTheme appBarLightTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  iconTheme: IconThemeData(color: blackColor),
  titleTextStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: blackColor,
    fontFamily: "Plus Jakarta",
  ),
  centerTitle: true,
);

const AppBarTheme appBarDarkTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  iconTheme: IconThemeData(color: Colors.white),
  titleTextStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFamily: "Plus Jakarta",
  ),
  centerTitle: true,
);

ScrollbarThemeData scrollbarThemeData = ScrollbarThemeData(
  trackColor: WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
  thumbColor: WidgetStateProperty.all(primaryColor.withOpacity(0.4)),
  radius: const Radius.circular(10),
  thickness: WidgetStateProperty.all(4),
);

DataTableThemeData dataTableLightThemeData = DataTableThemeData(
  columnSpacing: 24,
  headingRowColor: WidgetStateProperty.all(surfaceColor),
  decoration: BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
    border: Border.all(color: blackColor10),
  ),
  dataTextStyle: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: blackColor,
  ),
);

DataTableThemeData dataTableDarkThemeData = DataTableThemeData(
  columnSpacing: 24,
  headingRowColor: WidgetStateProperty.all(const Color(0xFF1C1C28)),
  decoration: BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
    border: Border.all(color: Colors.white10),
  ),
  dataTextStyle: const TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontSize: 12,
  ),
);
