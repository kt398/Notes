import 'package:notes/Constants.dart';
import 'dart:io';

enum Type { notes, task, folder }

class Files {
  Type type;
  String title;
  String dateModified;
  bool selected;
  FileSystemEntity entity;
  Files(this.title, this.dateModified, this.selected, this.type, this.entity);
  bool fileExists(String name) {
    if ((FileSystemEntity.type('${entity.path}/$name') !=
        FileSystemEntityType.notFound)) {
      return true;
    }
    return false;
  }
  Future<bool> renameFile(String name) async{
    if(fileExists(name)){
      return false;
    }
    else{
      return true;
    }
  }

  Future<FileSystemEntityType> getType(String name)async{
    FileSystemEntityType type= await FileSystemEntity.type('${entity.path}/$name');
    return type;
  }
}

class Note extends Files {
  Note(String path, String title, String dateModified, File file)
      : super(title, dateModified, false, Type.notes, file);
}

class Task extends Files {
  String date;
  Task(String path, String title, String dateModified, File file)
      : super(title, dateModified, false, Type.task, file) {}
}

class Folder extends Files {
  Folder parentFolder;
  String name;
  List<Files> list;
  Folder(String title, String dateModified, Directory dir, this.parentFolder)
      : super(title, dateModified, false, Type.folder, dir) {
    list = new List<Files>();
    selected = false;
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

    this.list.add(new Folder(name, 'test', tempDir, this));
    return true;
  }

  Future<bool> deleteSelected() async {
    return true;
  }

  void deselectAll() {
    for (int i = 0; i < list.length; i++) {
      if (list[i].selected) {
        list[i].selected = false;
      }
    }
  }
}
