import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData);

  getTheme() => _themeData;
  setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
  }


  static ThemeData darkTheme(){
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: TextTheme(
        headline1: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 0,
        ),
        bodyText1: GoogleFonts.roboto(
          color:Colors.white,
          fontSize: 20,
          letterSpacing: 0,
        ),
        bodyText2: GoogleFonts.roboto(
          color:Colors.white,
          fontSize: 22,
          letterSpacing: 0,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),






    );


  }


  static ThemeData lightTheme(){
    return ThemeData(
      brightness: Brightness.light,
      textTheme: TextTheme(
        headline1: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 0,
        ),
        bodyText1: GoogleFonts.roboto(
          color:Colors.black,
          fontSize: 20,
          letterSpacing: 0,
        ),
        bodyText2: GoogleFonts.roboto(
          color:Colors.white,
          fontSize: 22,
          letterSpacing: 0,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),



    );



  }
}