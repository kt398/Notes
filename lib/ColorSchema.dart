import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorSchema{
  ColorSchema();


  Color getBackground(isDark){
    if(isDark){
      return Colors.grey[850];
    }
    return Colors.white;
  }

  Color getText(isDark){
    if(isDark){
      return Colors.white;
    }
    else{
      return Colors.black;
    }
  }
  ThemeData lightTheme(){
    return ThemeData(
      scaffoldBackgroundColor: Colors.teal,
      appBarTheme: AppBarTheme(
        color: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.white,
        onPrimary: Colors.white,
        primaryVariant: Colors.white38,
        secondary: Colors.red,
      ),
      cardTheme: CardTheme(
        color: Colors.teal,
      ),
      iconTheme: IconThemeData(
        color: Colors.white54,
      ),
    );
  }

  ThemeData darkTheme(){
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        color: Colors.grey[850],        
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.black,
        primaryVariant: Colors.black,
        secondary: Colors.red,
      ),
      cardTheme: CardTheme(
        color: Colors.black,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
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
        )
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.grey[850],
        textStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 18,
          letterSpacing: 0,
        )

      ),

    );
  }
}