import 'dart:io';
import 'package:notes/main.dart';
import 'package:path/path.dart' as GetName;
import 'NotificationHelper.dart';

enum Type { notes, task, folder }

class Files {
  Type type;
  String title;
  DateTime dateModified;
  String data;
  String plainText;
  bool selected;
  FileSystemEntity entity;
  Files(this.title, this.dateModified, this.selected, this.type, this.entity,
      this.data, this.plainText);

  Future<bool> fileExists(String name) async {
    if ((await FileSystemEntity.type('${entity.parent.path}/$name') !=
        FileSystemEntityType.notFound)) {
      return true;
    }
    return false;
  }

  Future<FileSystemEntityType> getType(String name) async {
    FileSystemEntityType type =
        await FileSystemEntity.type('${entity.path}/$name');
    return type;
  }
}

class Note extends Files {
  Note(String path, String title, DateTime dateModified, File file, String data,
      String textData)
      : super(title, dateModified, false, Type.notes, file, data, textData);

  Future<bool> renameFile(String newName) async {
    if (await fileExists(newName)) {
      return false;
    }
    title = newName;
    entity = await entity.rename('${entity.parent.path}/$newName');
    return true;
  }
}

class Task extends Files {
  DateTime date;
  int notificationID;
  int notificationType;
  /*
  Notification Types:
  0-None
  1-Single
  2-Annual-Doesn't exist yet
  3-Weekly
  4-Daily
  Format for Task file Names:
  path/date/notificationId/notificationType
  */

  Task(String path, String title, DateTime dateModified, File file, String data,
      String textData, this.notificationID, this.date,this.notificationType)
      : super(title, dateModified, false, Type.task, file, data, textData);
  
  
  Future<bool> renameFile(String newName, Folder parentFolder) async{
    for(int i=0;i<parentFolder.list.length;i++){
      if(newName==parentFolder.list[i].title){
        return false;
      }
    }
    entity=await entity.rename('${entity.parent.path}/$newName^&@${this.date.toIso8601String()}^&@${this.notificationID}^&@${this.notificationType}');
    return true;
  }

  Future<void> changeDate(DateTime newDate)async{
    this.date=newDate;
    entity=await entity.rename('${entity.parent.path}/${this.title}^&@${this.date.toIso8601String()}^&@${this.notificationID}^&@${this.notificationType}');
  }




}

class Folder extends Files {
  Folder parentFolder;
  String name;
  List<Files> list;
  String path;
  Folder(String title, DateTime dateModified, Directory dir, this.parentFolder,
      this.path)
      : super(title, dateModified, false, Type.folder, dir, '', '') {
    list = new List<Files>();
    selected = false;
  }
  Future<int> getTotalFiles() async {
    return await (entity as Directory).list(recursive: true).length;
  }

  Future<bool> addFolder(String name) async {
    if (await (Directory('${entity.path}/$name').exists())) {
      return false;
    }
    Directory tempDir = await (Directory('${entity.path}/$name')
        .create(recursive: false)
        .catchError((e) {
      print(e.toString());
      return false;
    }));

    this.list.add(new Folder(name, null, tempDir, this,
        '$path/${GetName.basenameWithoutExtension(entity.path)}'));
    return true;
  }

  Future<bool> addFile(String name, Type t, int lastTask) async {
    if (await fileExists(name)) {
      return false;
    } else {
      switch (t) {
        case Type.folder:
          {}
          break;

        case Type.notes:
          {
            File f = await File('${entity.path}/$name.json')
                .create(recursive: false);
            this.list.add(new Note(f.path, name, (await f.lastModified()), f,
                await f.readAsString(), ''));
          }
          break;

        case Type.task:
          {
            File f = await File(
                    '${entity.path}/$name.json^&@${DateTime.now()}^&@${lastTask + 1}^&@0')
                .create(recursive: false);
            this.list.add(new Task(f.path, name, (await f.lastModified()), f,
                await f.readAsString(), '', lastTask + 1, DateTime.now(),0));
          }
          break;
      }
    }

    return true;
  }

  Future<bool> deleteSelected() async {
    for (int i = 0; i < list.length; i++) {
      if (list[i].selected) {
        await list[i].entity.delete(recursive: true);
        if(list[i].type==Type.task){
          await turnOffNotificationById(notificationsPlugin, (list[i] as Task).notificationID);
        }
        list[i] = null;
        list.removeAt(i);
        i--;
      }
    }
    return true;
  }

  void deselectAll() {
    for (int i = 0; i < list.length; i++) {
      if (list[i].selected) {
        list[i].selected = false;
      }
    }
  }

  turnOnNotifications(){
    for(int i=0;i<this.list.length;i++){
      if(this.list[i].type==Type.folder){
        (this.list[i] as Folder).turnOnNotifications();
      }
      else{
        scheduleNotification(notificationsPlugin, entity.path,(this as Task).notificationID, this.title, (this as Task).date);
      }  
    }
  }

}
