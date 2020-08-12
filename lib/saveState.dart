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
        String temp = await entity.readAsString();
        String plainText=NotusDocument.fromJson(jsonDecode(temp)).toPlainText();
        if (isTask) {
          object.list.add(new Task(
              entity.path,
              GetName.basenameWithoutExtension(entity.path),
              (await (entity).lastModified()),
              entity,
              temp,plainText));
        } else {
          object.list.add(new Note(
              entity.path,
              GetName.basenameWithoutExtension(entity.path),
              (await (entity).lastModified()),
              entity,
              await entity.readAsString(),plainText));
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
    if (prefs.containsKey("theme")) {
      isDark = prefs.getBool("theme");
    } else {
      isDark = true;
    }
  }

  void write() {
    prefs.setBool("theme", isDark);
  }
}
