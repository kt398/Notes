import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'saveState.dart';
import 'Constants.dart';
import 'Settings.dart';

class Home extends StatefulWidget {
  SaveState save;
  Home(this.save);
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  bool selected = false;
  void choiceAction(String choice, SaveState save) {
    print(save.isDark);
    if (choice == Constants.Settings) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Settings(save)),
      );
    } else if (choice == Constants.Import) {
    } else if (choice == Constants.Export) {}
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: new AppBar(
            backgroundColor: Theme.of(context).appBarTheme.color,
            title: TabBar(
              tabs: <Widget>[
                Tab(
                  child: Text(
                    'Notes',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Tab(
                  child: Text(
                    'Tasks',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              PopupMenuTheme(
                data: Theme.of(context).popupMenuTheme,
                child: PopupMenuButton<String>(
                    //color: Theme.of(context).appBarTheme.color,
                    //color: Colors.white,
                    icon: IconTheme(
                      data: Theme.of(context).iconTheme,
                      child: Icon(
                        Icons.more_vert,
                      ),
                    ),
                    onSelected: (choice) {
                      choiceAction(choice, widget.save);
                    },
                    itemBuilder: (context) {
                      var list = List<PopupMenuEntry<String>>();
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
                    }),
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              TabBarView(
                children: <Widget>[
                  ListView.builder(
                    //itemCount: list.length,
                    //itemBuilder: getListItemTile,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
