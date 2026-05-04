import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Just for demo
const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
const productDemoImg4 = "https://i.imgur.com/q9oF9Yq.png";
const productDemoImg5 = "https://i.imgur.com/MsppAcx.png";
const productDemoImg6 = "https://i.imgur.com/JfyZlnO.png";

// End For demo

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

const Color primaryColor = Color(0xFF7B61FF);

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFF9581FF, <int, Color>{
  50: Color(0xFFEFECFF),
  100: Color(0xFFD7D0FF),
  200: Color(0xFFBDB0FF),
  300: Color(0xFFA390FF),
  400: Color(0xFF8F79FF),
  500: Color(0xFF7B61FF),
  600: Color(0xFF7359FF),
  700: Color(0xFF684FFF),
  800: Color(0xFF5E45FF),
  900: Color(0xFF6C56DD),
});

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 16.0;
const double cardBorderRadius = 20.0;
const Duration defaultDuration = Duration(milliseconds: 300);

// Animation Durations
const Duration animDurationFast = Duration(milliseconds: 150);
const Duration animDurationMedium = Duration(milliseconds: 300);
const Duration animDurationSlow = Duration(milliseconds: 500);

// Surface & Card Colors
const Color surfaceColor = Color(0xFFF8F9FE);
const Color cardColor = Colors.white;
const Color shimmerBaseColor = Color(0xFFE8E8ED);
const Color shimmerHighlightColor = Color(0xFFF5F5F8);

// Glassmorphism Tokens
const double glassBlur = 20.0;
const Color glassColor = Color(0x30FFFFFF);
const Color glassBorderColor = Color(0x40FFFFFF);

// Modern UI Tokens
const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF7B61FF), Color(0xFF9581FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient premiumGradient = LinearGradient(
  colors: [Color(0xFF5E45FF), Color(0xFF9581FF)],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const LinearGradient accentGradient = LinearGradient(
  colors: [Color(0xFF00C9A7), Color(0xFF00D4AA)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient successGradient = LinearGradient(
  colors: [Color(0xFF2ED573), Color(0xFF7BED9F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient warningGradient = LinearGradient(
  colors: [Color(0xFFFFBE21), Color(0xFFFFD93D)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient errorGradient = LinearGradient(
  colors: [Color(0xFFEA5B5B), Color(0xFFFF6B6B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient darkOverlayGradient = LinearGradient(
  colors: [Colors.transparent, Color(0xCC000000)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Shadow Variants
final List<BoxShadow> softShadow = [
  BoxShadow(
    color: const Color(0xFF7B61FF).withOpacity(0.08),
    blurRadius: 24,
    offset: const Offset(0, 8),
  ),
];

final List<BoxShadow> softShadowSm = [
  BoxShadow(
    color: const Color(0xFF7B61FF).withOpacity(0.06),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

final List<BoxShadow> softShadowLg = [
  BoxShadow(
    color: const Color(0xFF7B61FF).withOpacity(0.12),
    blurRadius: 32,
    offset: const Offset(0, 12),
  ),
];

final List<BoxShadow> neutralShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  ),
];


final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(6, errorText: 'password must be at least 6 digits long'),
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";
