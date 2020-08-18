import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'File.dart';
import 'dart:convert';
import 'package:path/path.dart' as GetName;
import 'package:notus/notus.dart';

class SaveState {
  SharedPreferences prefs;
  bool isDark; //false is light, true is dark
  bool notifications;
  int lastTask;
  Folder root;
  Folder notesObj;
  Folder tasksObj;
  saveState() async {
    await init();
  }

  Future<Folder> initStruct(
      Directory dir, Folder object, bool isTask, String folderPath) async {
    Stream temp = dir.list(recursive: false, followLinks: false);
    await for (FileSystemEntity entity in temp) {
      if (entity is File) {
        print(entity.path);
        String temp = await entity.readAsString();
        String plainText =
            NotusDocument.fromJson(jsonDecode(temp)).toPlainText();
        if (isTask) {
          List<String> strings= entity.path.split('^&@');
          String temp2=GetName.basenameWithoutExtension(strings[0]);
          print('Temp2');
          print(temp2);
          object.list.add(new Task(
              entity.path,
              GetName.basenameWithoutExtension(temp2),
              (await (entity).lastModified()),
              entity,
              await entity.readAsString(),
              plainText,
              int.parse(strings[2]),
              DateTime.parse(strings[1])));
              //tasktest123.json^&@2020-08-17 18:43:18.880099^&@1
              //_path:"/data/user/0/com.example.notes/app_flutter/Root//Tasks/tasktest123.json^&@2020-08-17 18:43:18.880099^&@1"

        } else {
          object.list.add(new Note(
              entity.path,
              GetName.basenameWithoutExtension(entity.path),
              (await (entity).lastModified()),
              entity,
              await entity.readAsString(),
              plainText));
        }
      } else if (entity is Directory) {
        Folder temp = new Folder(
            GetName.basenameWithoutExtension(entity.path),
            null,
            entity,
            object,
            '$folderPath/${GetName.basenameWithoutExtension(entity.path)}');
        object.list.add(await initStruct(entity, temp, isTask, temp.path));
      }
    }
    return object;
  }

  Future<String> get localPath async {
    Directory notes;
    Directory tasks;
    final Directory dir = await getApplicationDocumentsDirectory();
    final Directory rootFolder = Directory('${dir.path}/Root/');
    if (!(await rootFolder.exists())) {
      final newRootFolder = await rootFolder.create(
        recursive: false,
      );
      notes = await (Directory('${newRootFolder.path}/Notes')
          .create(recursive: true));
      tasks = await (Directory('${newRootFolder.path}/Tasks')
          .create(recursive: true));
    } else {
      notes = Directory('${rootFolder.path}/Notes');
      tasks = Directory('${rootFolder.path}/Tasks');
    }
    root = new Folder("Root", null, rootFolder, null, '');
    notesObj = new Folder("Notes", null, notes, root, 'Notes');
    tasksObj = new Folder("Tasks", null, tasks, root, 'Tasks');
    root.list.add(notesObj);
    root.list.add(tasksObj);

    root.list.add(await initStruct(notes, notesObj, false, 'Notes'));
    root.list.add(await initStruct(tasks, tasksObj, true, 'Notes'));

    return dir.path;
  }

  Future<void> init() async {
    this.prefs = await SharedPreferences.getInstance();
    this.lastTask=await tasksObj.getTotalFiles();
    if (prefs.containsKey("theme")) {
      isDark = prefs.getBool("theme");
    } else {
      isDark = true;
    }
    if (prefs.containsKey('notifications')) {
      notifications = prefs.getBool('notifications');
    } else {
      notifications = true;
    }
  }

  void write() {
    prefs.setBool("theme", isDark);
    prefs.setBool('notifications', notifications);
  }
}
