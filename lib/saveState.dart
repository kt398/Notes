import 'package:shared_preferences/shared_preferences.dart';
class SaveState {
  SharedPreferences prefs;
  bool isDark;//false is light, true is dark

  saveState() async {
    await init();
  }

  Future<void> init() async {
    this.prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("theme")){
      isDark=prefs.getBool("theme");
    }
    else{
      isDark=true;
    }
  }
  void write(){
    prefs.setBool("theme", isDark);
  }
}