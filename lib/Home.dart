import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'saveState.dart';
import 'Constants.dart';
import 'Settings.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'TextPage.dart';
import 'File.dart';

class Home extends StatefulWidget {
  SaveState save;
  Home(this.save);
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController tabController;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text='Untitled';
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    tabController.dispose();
  }

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

  enterName(BuildContext context, bool isFile) {
    String name = '';
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter ${isFile ? 'File' : 'Folder'} Name",
              ),
            ),
            content: TextField(
              controller: _controller,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onChanged: (text) {
                name = text;
              },
            ),
            actions: <Widget>[
              Center(
                child: ButtonBar(
                  //alignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () => {
                        Navigator.of(context).pop(),
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () => {
                        if (isFile)
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TextPage(
                                        tabController.index == 1
                                            ? Type.task
                                            : Type.notes,name))),
                            //Navigator.of(context).pop(),
                          }
                        else
                          {
                            //TODO Add method to add folder to the structure
                            Navigator.pop(context, () {
                              setState(() {});
                            }),
                          }
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  SpeedDial buildAddIcons() {
    return SpeedDial(
      //backgroundColor: Colors.tealAccent,
      overlayOpacity: 0,
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.note_add),
          onTap: () => {
            enterName(context, true),
          },
          label: 'New Note',
          labelStyle: Theme.of(context).textTheme.subtitle2,
        ),
        SpeedDialChild(
          child: Icon(Icons.folder),
          onTap: () => {
            enterName(context, false),
          },
          label: "New Folder",
          labelStyle: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      //TODO Hide appbar on scrollup
      //TODO Change appbar on selected
      appBar: new AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        title: TabBar(
          controller: tabController,
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
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          Icon(Icons.card_giftcard),
          Icon(Icons.ac_unit),
        ],
      ),
      floatingActionButton: buildAddIcons(),
    );
  }
}
