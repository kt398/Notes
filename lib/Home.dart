import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'saveState.dart';
import 'Constants.dart';
import 'Settings.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'TextPage.dart';
import 'File.dart';
import 'GoogleAuthClient.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';

//TODO make everything pretty
//TODO notifications-Mostly Done
//TODO licenses

class Home extends StatefulWidget {
  final SaveState save;
  Home(this.save);
  HomeState createState() => HomeState();
}
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [drive.DriveApi.DriveScope]
);
class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  GoogleSignInAccount currentUser;
  TabController tabController;
  TextEditingController _controller = new TextEditingController();
  TextEditingController renameController = new TextEditingController();
  Folder notesWorkingFolder;
  Folder tasksWorkingFolder;
  int totalSelected = 0;
  int firstIndex = -1;
  int rootDirectory;

  @override
  void initState() {
    rootDirectory = 0;
    notesWorkingFolder = widget.save.notesObj;
    tasksWorkingFolder = widget.save.tasksObj;
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        currentUser = account;
      });
      if (currentUser != null) {
      }
    });
    _googleSignIn.signInSilently();
  }
  /*
  Dialog box that shows when delete is clicked from settings menu
  Confirmation to delete selected files/folders
  */
  void deleteAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Text(
                  "Delete selected ${totalSelected > 1 ? "item" : 'items'}"),
              actions: <Widget>[
                MaterialButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                MaterialButton(
                    child: Text("Confirm"),
                    onPressed: () async {
                      if (tabController.index == 1) {
                        await tasksWorkingFolder.deleteSelected();
                        widget.save.lastTask -= totalSelected;
                      } else {
                        await notesWorkingFolder.deleteSelected();
                      }
                      totalSelected = 0;
                      Navigator.of(context).pop();
                    }),
              ],
            );
          });
        }).then((value) {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    tabController.dispose();
  }

  void choiceAction(String choice, SaveState save){
    if (choice == Constants.Settings) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Settings(save,widget.save.tasksObj)),
      );
    } else if (choice == Constants.Import) {
      print('import');
      if(currentUser==null){
        checkLogin();
      }
      import();

    } else if (choice == Constants.Export) {
      if(currentUser==null){
        checkLogin();
      }
    }
  }

  void checkLogin() async{
    GoogleSignInAccount account = await _googleSignIn.signIn();
    if(account==null){
      print('Canceled?');
      return;
    }
    else{
      currentUser=account;
      print('User account $currentUser');
      print('after');
      return;
    }
    
  }
  void import() async{
    print('inside import');
    final authHeaders = await currentUser.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final Stream<List<int>> mediaStream =
    Future.value([104, 105]).asStream().asBroadcastStream();
    var media = new drive.Media(mediaStream, 2);
    var driveFile = new drive.File();
    driveFile.name = "hello_world.txt";
    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");

  }
  void selectedMenuChoice(String choice) {
    if (choice == Constants.Delete) {
      deleteAlertDialog();
    } else if (choice == Constants.Move) {
    } else if (choice == Constants.Rename) {
      renameAlertDialog(firstIndex);
    }
  }

  renameAlertDialog(int index) {
    renameController.text = '';
    bool validate = true;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter New Name',
                ),
              ),
              content: TextField(
                controller: renameController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  errorText: !validate ? "Folder Name Already exists" : null,
                ),
                autofocus: true,
                autocorrect: false,
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
                        onPressed: () async => {
                          if (tabController.index == 0)
                            {
                              if (await (notesWorkingFolder.list[index] as Note)
                                  .renameFile(renameController.text))
                                {
                                  totalSelected = 0,
                                  Navigator.of(context).pop(),
                                }
                              else
                                {
                                  setState(() {
                                    validate = false;
                                  }),
                                }
                            }
                          else
                            {
                              if(await (tasksWorkingFolder.list[index] as Task).renameFile(renameController.text,tasksWorkingFolder)){
                                totalSelected=0,
                                Navigator.of(context).pop(),
                              }
                              else{
                                setState((){
                                  validate=false;
                                })
                              }
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
        }).then((value) {
      setState(() {
        notesWorkingFolder.deselectAll();
        tasksWorkingFolder.deselectAll();
      });
    });
  }
  /*
  Dialog Box when a new file/folder is created.
  Asks the user to enter the name of the file/folder
  Shows an error if the name already exists in the current directory
  */
  enterName(bool isFile) {
    bool temp;
    bool validate = true;
    _controller.text = "";
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
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
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error)),
                  errorText: !validate ? "Name already exists" : null,
                ),
                autofocus: true,
                autocorrect: false,
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
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async => {
                          if (isFile)
                            {
                              if (tabController.index == 1)
                                {
                                  await tasksWorkingFolder.addFile(
                                      _controller.text,
                                      Type.task,
                                      widget.save.lastTask),
                                  widget.save.lastTask++,
                                }
                              else
                                {
                                  await notesWorkingFolder.addFile(
                                      _controller.text, Type.notes, -1),
                                },
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TextPage(
                                          tabController.index == 1
                                              ? tasksWorkingFolder.list[
                                                  tasksWorkingFolder
                                                          .list.length -
                                                      1]
                                              : notesWorkingFolder.list[
                                                  notesWorkingFolder
                                                          .list.length -
                                                      1],
                                          _controller.text))),
                            }
                          else //If the folder button is selected
                            {
                              if (tabController.index == 1)
                                {
                                  temp = await tasksWorkingFolder
                                      .addFolder(_controller.text),
                                  setState(() {
                                    validate = temp;
                                  }),
                                }
                              else
                                {
                                  temp = await notesWorkingFolder
                                      .addFolder(_controller.text),
                                  setState(() {
                                    validate = temp;
                                  }),
                                },
                              setState(() {}),
                              if (validate)
                                {
                                  Navigator.of(context).pop(true),
                                }
                            }
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
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
        }).then((value) {
      setState(() {});
    });
  }


  /*
  Icon menu at the bottom right to add a new file/folder
  */
  SpeedDial buildAddIcons() {

    //bool temp = true;
    return SpeedDial(
      backgroundColor:
          Theme.of(context).floatingActionButtonTheme.backgroundColor,
      visible: totalSelected < 1 ? true : false,
      overlayOpacity: 0,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.note_add,color: Theme.of(context).floatingActionButtonTheme.foregroundColor),
          onTap: () => {
            enterName(true),
          },
          label: 'New Note',
          labelStyle: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.black),
        ),
        SpeedDialChild(
          child: Icon(Icons.folder),
          onTap: () => {
            enterName(false),
          },
          label: "New Folder",
          labelStyle: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.black),
        ),
      ],
    );
  }

  List<Widget> popupMenu() {
    return <Widget>[
      PopupMenuTheme(
        data: Theme.of(context).popupMenuTheme,
        child: PopupMenuButton<String>(
            //color: Theme.of(context).appBarTheme.color,
            //color: Colors.white,
            padding: EdgeInsets.all(0),
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
                  height: 1,
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
                  height: 1,
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
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      //TODO Hide appbar on scrollup
      appBar: rootDirectory != 0 && totalSelected == 0
          ? new AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  if (tabController.index == 0) {
                    setState(() {
                      rootDirectory--;
                      notesWorkingFolder = notesWorkingFolder.parentFolder;
                    });
                  }
                },
              ),
              title: Text(
                notesWorkingFolder.path,
                //textDirection: TextDirection.rtl,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16),
              ),
              actions: popupMenu(),
            )
          : totalSelected < 1
              ? new AppBar(
                  //Appbar when none of the cards are selected
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  title: TabBar(
                    //physics: NeverScrollableScrollPhysics(),
                    controller: tabController,
                    indicatorColor: widget.save.isDark?Theme.of(context).colorScheme.secondary:Colors.white,
                    tabs: <Widget>[
                      Tab(
                        child: Text(
                          'Notes',
                          style: Theme.of(context).textTheme.headline1.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Tasks',
                          style: Theme.of(context).textTheme.headline1.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                  actions: popupMenu(),
                )
              : new AppBar(
                  //Appbar when at least one card is selected
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      setState(() {
                        totalSelected = 0;
                        notesWorkingFolder.deselectAll();
                        tasksWorkingFolder.deselectAll();
                      });
                    },
                  ),
                  title: Text('$totalSelected Selected',
                      style: Theme.of(context).textTheme.headline1.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )),
                  actions: <Widget>[
                    PopupMenuTheme(
                      data: Theme.of(context).popupMenuTheme,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onSelected: (choice) {
                          selectedMenuChoice(choice);
                        },
                        itemBuilder: (context) {
                          var l2 = List<PopupMenuEntry<String>>();
                          l2.add(PopupMenuItem(
                            child: Text(Constants.Delete),
                            value: Constants.Delete,
                          ));
                          l2.add(PopupMenuDivider(
                            height: 10,
                          ));
                          l2.add(PopupMenuItem(
                            child: Text(Constants.Move),
                            value: Constants.Move,
                          ));
                          if (totalSelected == 1) {
                            l2.add(PopupMenuDivider(
                              height: 10,
                            ));
                            l2.add(PopupMenuItem(
                              child: Text(Constants.Rename),
                              value: Constants.Rename,
                            ));
                          }
                          return l2;
                        },
                      ),
                    ),
                  ],
                ),
      body: TabBarView(
        physics: totalSelected > 0 || rootDirectory != 0
            ? NeverScrollableScrollPhysics()
            : null,
        controller: tabController,
        children: <Widget>[
          ListView.separated(
            itemCount: notesWorkingFolder.list.length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 4,
                color: Colors.transparent,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: !notesWorkingFolder.list[index].selected
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).cardTheme.color,
                //elevation: !notesWorkingFolder.list[index].selected ? 1 : 1,
                margin: index == 0
                    ? const EdgeInsets.fromLTRB(3, 4, 3, 0)
                    : const EdgeInsets.fromLTRB(3, 0, 3, 0),
                shadowColor: Colors.transparent,
                child: ListTileTheme(
                  dense: false,
                  selectedColor: Colors.white,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    selected: notesWorkingFolder.list[index].selected,
                    leading: Icon(
                      notesWorkingFolder.list[index].type == Type.folder
                          ? Icons.folder
                          : Icons.note_add,
                      size: 40,
                    ),
                    onTap: () {
                      if (totalSelected > 0) {
                        if (notesWorkingFolder.list[index].selected) {
                          totalSelected--;
                        } else {
                          totalSelected++;
                        }
                        setState(() {
                          notesWorkingFolder.list[index].selected =
                              !notesWorkingFolder.list[index].selected;
                        });
                      } else if (tabController.index == 1) {
                        if (tasksWorkingFolder.list[index].type ==
                            Type.folder) {
                          tasksWorkingFolder = tasksWorkingFolder.list[index];
                          rootDirectory++;
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextPage(
                                    tasksWorkingFolder.list[index],
                                    tasksWorkingFolder.list[index].title)),
                          );
                        }
                      } else if (tabController.index == 0) {
                        if (notesWorkingFolder.list[index].type ==
                            Type.folder) {
                          setState(() {
                            rootDirectory++;
                            notesWorkingFolder = notesWorkingFolder.list[index];
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextPage(
                                    notesWorkingFolder.list[index],
                                    notesWorkingFolder.list[index].title)),
                          );
                        }
                      }
                    },
                    onLongPress: () {
                      if (notesWorkingFolder.list[index].selected) {
                        totalSelected--;
                      } else {
                        totalSelected++;
                      }
                      if (totalSelected == 1) {
                        firstIndex = index;
                      }
                      if (totalSelected == 0) {
                        firstIndex = -1;
                      }
                      setState(() {
                        notesWorkingFolder.list[index].selected =
                            !notesWorkingFolder.list[index].selected;
                      });
                    },
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: AutoSizeText(
                            '${notesWorkingFolder.list[index].title}',
                            minFontSize: 16,
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                .copyWith(
                                    color: (Theme.of(context)
                                        .colorScheme
                                        .onBackground)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
                          if (notesWorkingFolder.list[index].type !=
                              Type.folder)
                            Text(
                              '${notesWorkingFolder.list[index].dateModified.month}/${notesWorkingFolder.list[index].dateModified.day}/${notesWorkingFolder.list[index].dateModified.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(.8)),
                            )
                        ]),
                    subtitle: notesWorkingFolder.list[index].type != Type.folder
                        ? Text(
                            '${notesWorkingFolder.list[index].plainText}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(.8)),
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                          )
                        : null,
                    isThreeLine: false,
                  ),
                ),
              );
            },
          ),
          ListView.separated(
            itemCount: tasksWorkingFolder.list.length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 4,
                color: Colors.transparent,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: !tasksWorkingFolder.list[index].selected
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).cardTheme.color,
                //elevation: !tasksWorkingFolder.list[index].selected ? 1 : 1,
                margin: index == 0
                    ? const EdgeInsets.fromLTRB(3, 4, 3, 0)
                    : const EdgeInsets.fromLTRB(3, 0, 3, 0),
                shadowColor: Colors.transparent,
                child: ListTileTheme(
                  dense: false,
                  selectedColor: Colors.white,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    selected: tasksWorkingFolder.list[index].selected,
                    leading: Icon(
                      tasksWorkingFolder.list[index].type == Type.folder
                          ? Icons.folder
                          : Icons.note_add,
                      size: 40,
                    ),
                    onTap: () {
                      if (totalSelected > 0) {
                        if (tasksWorkingFolder.list[index].selected) {
                          totalSelected--;
                        } else {
                          totalSelected++;
                        }
                        setState(() {
                          tasksWorkingFolder.list[index].selected =
                              !tasksWorkingFolder.list[index].selected;
                        });
                      } else if (tabController.index == 1) {
                        if (tasksWorkingFolder.list[index].type ==
                            Type.folder) {
                          tasksWorkingFolder = tasksWorkingFolder.list[index];
                          rootDirectory++;
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextPage(
                                    tasksWorkingFolder.list[index],
                                    tasksWorkingFolder.list[index].title)),
                          );
                        }
                      } else if (tabController.index == 0) {
                        if (tasksWorkingFolder.list[index].type ==
                            Type.folder) {
                          setState(() {
                            rootDirectory++;
                            tasksWorkingFolder = tasksWorkingFolder.list[index];
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextPage(
                                    tasksWorkingFolder.list[index],
                                    tasksWorkingFolder.list[index].title)),
                          );
                        }
                      }
                    },
                    onLongPress: () {
                      if (tasksWorkingFolder.list[index].selected) {
                        totalSelected--;
                      } else {
                        totalSelected++;
                      }
                      if (totalSelected == 1) {
                        firstIndex = index;
                      }
                      if (totalSelected == 0) {
                        firstIndex = -1;
                      }
                      setState(() {
                        tasksWorkingFolder.list[index].selected =
                            !tasksWorkingFolder.list[index].selected;
                      });
                    },
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: AutoSizeText(
                            '${tasksWorkingFolder.list[index].title}',
                            minFontSize: 16,
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                .copyWith(
                                    color: (Theme.of(context)
                                        .colorScheme
                                        .onBackground)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
                          if (tasksWorkingFolder.list[index].type !=
                              Type.folder)
                            Text(
                              '${tasksWorkingFolder.list[index].dateModified.month}/${tasksWorkingFolder.list[index].dateModified.day}/${tasksWorkingFolder.list[index].dateModified.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(.8)),
                            )
                        ]),
                    subtitle: tasksWorkingFolder.list[index].type != Type.folder
                        ? Text(
                            '${tasksWorkingFolder.list[index].plainText}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(.8)),
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                          )
                        : null,
                    isThreeLine: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: buildAddIcons(),
    );
  }
}
