import 'package:flutter/material.dart';
import 'hex_color.dart';
// import 'package:google_fonts/google_fonts.dart';

class ThemeClass {
  Color lightPrimaryColor = HexColor('#4173CA');
  Color darkPrimaryColor = HexColor('#031525');
  Color secondaryColor = HexColor('#FF8B6A');
  Color accentColor = HexColor('#FFD2BB');
  Color darkRounded = HexColor('#162c46');
  Color darkErrorStyle = HexColor('#C30101');
  Color darkLight = const Color.fromARGB(255, 3, 21, 37);
  Color lightDiscussion = const Color.fromARGB(255, 243, 243, 243);

  static ThemeData lightTheme = ThemeData(
    // textTheme: GoogleFonts.nunitoTextTheme(),
    appBarTheme: AppBarTheme(backgroundColor: _themeClass.lightPrimaryColor),
    cardColor: _themeClass.lightDiscussion,
    primaryColor: ThemeData.light().scaffoldBackgroundColor,
    primaryColorLight: _themeClass.lightPrimaryColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _themeClass.lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    colorScheme: const ColorScheme.light().copyWith(
        primary: _themeClass.lightPrimaryColor,
        secondary: _themeClass.secondaryColor),
    dialogBackgroundColor: Colors.white,
  );

  static ThemeData darkTheme = ThemeData(
    // textTheme: GoogleFonts.nunitoTextTheme(),

    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.blueGrey,
      selectionHandleColor: Colors.blueGrey,
      cursorColor: Colors.lightBlue,
    ),

    cardColor: _themeClass.darkRounded,
    appBarTheme: AppBarTheme(backgroundColor: _themeClass.darkRounded),
    scaffoldBackgroundColor: _themeClass.darkLight,
    primaryColor: ThemeData.dark().scaffoldBackgroundColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _themeClass.darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: _themeClass.darkPrimaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: const TextStyle(color: Colors.blueGrey),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blueGrey),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: _themeClass.darkErrorStyle,
        ),
      ),
      errorStyle: TextStyle(
        color: _themeClass.darkErrorStyle,
      ),
    ),
    dialogBackgroundColor: _themeClass.darkLight,
  );
}

ThemeClass _themeClass = ThemeClass();
