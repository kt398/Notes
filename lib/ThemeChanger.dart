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

  static ThemeData darkTheme() {
    return ThemeData(
      applyElevationOverlayColor: true,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      cardTheme: CardTheme(
        elevation: 1,
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
        onPrimary: darkonPrimary,
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
      textTheme: TextTheme(
          headline1: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 0,
          ),
          bodyText1: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0,
          ),
          bodyText2: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 0,
          ),
          subtitle2: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 18,
            letterSpacing: 0,
          )),
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
      brightness: Brightness.light,
      textTheme: TextTheme(
        headline1: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 0,
        ),
        bodyText1: GoogleFonts.roboto(
          color: Colors.black,
          fontSize: 20,
          letterSpacing: 0,
        ),
        bodyText2: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 22,
          letterSpacing: 0,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
