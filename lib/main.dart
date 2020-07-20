import 'package:flutter/material.dart';
import 'Home.dart';
import 'saveState.dart';
import 'ColorSchema.dart';
import 'package:provider/provider.dart';
import 'ThemeChanger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ColorSchema schema=new ColorSchema();
  Future<SaveState> initSaveState() async {
  SaveState save = new SaveState();
  await save.init();
  return save;
}
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SaveState>(
      future: initSaveState(),
      builder: (BuildContext context,AsyncSnapshot<SaveState> save){
        if(save.hasData){
          return ChangeNotifierProvider<ThemeChanger>(
            create: (_) => ThemeChanger(save.data.isDark?ThemeChanger.darkTheme():ThemeChanger.lightTheme()),
            child: new MaterialAppWithTheme(save.data),
          );



        }
        else{
          return SizedBox(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          );
        }
      }
    );
  }
}


class MaterialAppWithTheme extends StatelessWidget {
  SaveState save;
  MaterialAppWithTheme(this.save);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      home: Home(save),
      theme: theme.getTheme(),
    );
  }
}
