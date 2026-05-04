import 'package:flutter/material.dart';

import '../constants.dart';

const InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
  fillColor: Color(0xFFF2F2F7),
  filled: true,
  hintStyle: TextStyle(color: greyColor, fontSize: 14),
  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  border: outlineInputBorder,
  enabledBorder: enabledOutlineInputBorder,
  focusedBorder: focusedOutlineInputBorder,
  errorBorder: errorOutlineInputBorder,
);

const InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
  fillColor: Color(0xFF1C1C28),
  filled: true,
  hintStyle: TextStyle(color: whileColor40, fontSize: 14),
  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  border: outlineInputBorder,
  enabledBorder: enabledOutlineInputBorderDark,
  focusedBorder: focusedOutlineInputBorder,
  errorBorder: errorOutlineInputBorder,
);

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(14)),
  borderSide: BorderSide(
    color: Colors.transparent,
  ),
);

const OutlineInputBorder enabledOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(14)),
  borderSide: BorderSide(
    color: Color(0xFFE8E8ED),
    width: 1,
  ),
);

const OutlineInputBorder enabledOutlineInputBorderDark = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(14)),
  borderSide: BorderSide(
    color: Color(0xFF2A2A3A),
    width: 1,
  ),
);

const OutlineInputBorder focusedOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(14)),
  borderSide: BorderSide(color: primaryColor, width: 2),
);

const OutlineInputBorder errorOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(14)),
  borderSide: BorderSide(
    color: errorColor,
    width: 1.5,
  ),
);

OutlineInputBorder secodaryOutlineInputBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide(
      color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.15),
    ),
  );
}
