import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Colors.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData);

  getTheme() => _themeData;
  setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
  }

  static TextTheme personalTextTheme() {
    return TextTheme(
        headline1: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 0,
        ),
        headline2: GoogleFonts.roboto(//title of the cards
          fontSize: 22

        ),
        bodyText1: GoogleFonts.roboto(//content of the cards
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 0,
        ),
        bodyText2: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 22,
          letterSpacing: 0,
        ),
        subtitle2: GoogleFonts.roboto(//trailing for the cards
          color: Colors.black,
          fontSize: 14,
          letterSpacing: 0,
        ));
  }

  static ThemeData darkTheme() {
    return ThemeData(
      applyElevationOverlayColor: true,
      splashColor: Colors.transparent,
      //highlightColor: Colors.transparent,
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.grey[900],
      ),
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      backgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        primaryVariant: darkPrimaryVariant,
        secondary: darkSecondary,
        surface: darkSurface,
        background: darkBackground,
        error: darkError,
        onPrimary: darkonBackGround,
        onSecondary: darkonSecondary,
        onSurface: darkonSurface,
        onBackground: darkonBackGround,
        onError: darkonError,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 4,
        color: darkBackground,
      ),
      brightness: Brightness.dark,
      textTheme: personalTextTheme(),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        foregroundColor: darkonSecondary,
        backgroundColor: darkSecondary,
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      applyElevationOverlayColor: false,
      splashColor: Colors.transparent,
      //highlightColor: Colors.transparent,
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.grey[350],
      ),
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      backgroundColor: lightBackground,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        primary: lightPrimary,
        primaryVariant: lightPrimaryVariant,
        secondary: lightSecondary,
        secondaryVariant: lightSecondary,
        surface: lightSurface,
        background: lightBackground,
        error: lightError,
        onPrimary: lightonPrimary,
        onSecondary: lightonSecondary,
        onSurface: lightonSurface,
        onBackground: lightonBackGround,
        onError: lightonError,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        elevation: 4,
        color: lightPrimary,
      ),
      textTheme: personalTextTheme(),
      //primaryTextTheme: ,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        foregroundColor: lightonSecondary,
        backgroundColor: lightSecondary,
      ),
    );
  }
}
