import 'dart:io';
import 'package:path/path.dart' as GetName;

enum Type { notes, task, folder }

class Files {
  Type type;
  String title;
  DateTime dateModified;
  String data;
  String plainText;
  bool selected;
  FileSystemEntity entity;
  Files(this.title, this.dateModified, this.selected, this.type, this.entity,this.data,this.plainText);

  Future<bool> fileExists(String name) async {
    if ((await FileSystemEntity.type('${entity.parent.path}/$name') !=
        FileSystemEntityType.notFound)) {
      return true;
    }
    return false;
  }

  Future<bool> renameFile(String newName) async {
    print("Path:");
    print(entity.path);
    if (await fileExists(newName)) {
      return false;
    }
    title = newName;
    entity = await entity.rename('${entity.parent.path}/$newName');
    return true;
  }

  Future<FileSystemEntityType> getType(String name) async {
    FileSystemEntityType type =
        await FileSystemEntity.type('${entity.path}/$name');
    return type;
  }
}

class Note extends Files {
  Note(String path, String title, DateTime dateModified, File file,String data,String textData)
      : super(title, dateModified, false, Type.notes, file,data,textData);
}

class Task extends Files {
  String date;
  Task(String path, String title, DateTime dateModified, File file,String data,String textData)
      : super(title, dateModified, false, Type.task, file,data,textData);
}

class Folder extends Files {
  Folder parentFolder;
  String name;
  List<Files> list;
  String path;
  Folder(String title, DateTime dateModified, Directory dir, this.parentFolder,this.path)
      : super(title, dateModified, false, Type.folder, dir,'','') {
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

    this.list.add(new Folder(name, null, tempDir, this,'$path/${GetName.basenameWithoutExtension(entity.path)}'));
    return true;
  }

  Future<bool> addFile(String name, Type t) async {
    if (await fileExists(name)) {
      return false;
    } else {
      switch (t) {
        case Type.folder:
          {}
          break;

        case Type.notes:
          {
            File f = await File('${entity.path}/$name.json').create(recursive: false);
            this.list.add(new Note(f.path,name,(await f.lastModified()),f,await f.readAsString(),''));
          }
          break;

        case Type.task:
          {
            File f = await File('${entity.path}/$name.json').create(recursive: false);
            this.list.add(new Task(f.path,name,(await f.lastModified()),f,await f.readAsString(),''));
          }
          break;
      }
    }

    return true;
  }

  Future<bool> deleteSelected() async {
    for(int i=0;i<list.length;i++){
      if(list[i].selected){
        await list[i].entity.delete(recursive: true);
        list[i]=null;
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
}
