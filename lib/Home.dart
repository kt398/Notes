import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ColorSchema.dart';
import 'saveState.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Constants.dart';
import 'Settings.dart';

class Home extends StatefulWidget {
  SaveState save;
  Home(this.save);
  HomeState createState() => HomeState();
}



class HomeState extends State<Home> {
  ColorSchema scheme = new ColorSchema();

  void choiceAction(String choice, SaveState save) {
  print(save.isDark);
  if (choice == Constants.Settings) {
    print('Settings');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings(save)),
    );
  } else if (choice == Constants.Import) {
    print('Import');
  } else if (choice == Constants.Export) {
    print('Export');
  }
}

Future<SaveState> initSaveState() async {
  SaveState save = new SaveState();
  await save.init();
  return save;
}

  Widget build(BuildContext context) {
            return Scaffold(
              appBar: new AppBar(
                backgroundColor: Theme.of(context).appBarTheme.color,
                title: Text(
                  'Notes',
                  style: Theme.of(context).textTheme.headline1,
                ),
                actions: <Widget>[
                  PopupMenuTheme(
                    data: Theme.of(context).popupMenuTheme,
                    child: PopupMenuButton<String>(
                      //color: Theme.of(context).appBarTheme.color,
                      //color: Colors.white,
                      icon: IconTheme(
                        data: Theme.of(context).iconTheme,
                        child:Icon(
                          Icons.more_vert,
                        ),
                      ),
                      onSelected: (choice) {
                        choiceAction(choice, widget.save);
                      },
                      itemBuilder: (context){
                        var list=List<PopupMenuEntry<String>>();
                        list.add(
                          PopupMenuItem(
                            child: Text(
                              Constants.Settings,
                            ),
                            value: Constants.Settings,
                          ),
                        );
                        list.add(
                          PopupMenuDivider(
                            
                            height: 10,
                          ),
                        );
                        list.add(
                          PopupMenuItem(
                            child: Text(
                              Constants.Import,
                            ),
                            value: Constants.Import,
                          ),
                        );
                        list.add(
                          PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        list.add(
                          PopupMenuItem(
                            child: Text(
                              Constants.Export,
                            ),
                            value: Constants.Export,
                          ),
                        );
                        return list;
                      }
                    ),
                  ),
                ],
              ),
            );
  }
}
