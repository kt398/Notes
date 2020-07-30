import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'File.dart';
import 'package:path/path.dart' as path;
class SaveState {
  SharedPreferences prefs;
  bool isDark; //false is light, true is dark
  Folder root;
  Folder notesObj;
  Folder tasksObj;
  saveState() async {
    await init();
  }


  Future<Folder> initStruct(Directory dir,Folder object, bool isTask) async{
    print(dir.path);
    Stream temp=dir.list(recursive: false,followLinks: false);
    await for(FileSystemEntity entity in temp){
      print(entity.path);
      if(entity is File){
        if(isTask){
          object.list.add(new Task(entity.path,"${entity.path}","temp date",entity));
        }
        else{
          object.list.add(new Note(entity.path,"${entity.path}","temp date",entity));
        }
      }
      else if(entity is Directory){
        print(path.basenameWithoutExtension(entity.path));
        Folder temp =new Folder(path.basenameWithoutExtension(entity.path),"test",entity,object);
        object.list.add(await initStruct(entity, temp, isTask));
      }
    }
    return object;
  }
  void addFolder(String name){
    
  }

  void addFile(){

  }

  Future<String> get localPath async {
    Directory notes;
    Directory tasks;
    final Directory dir = await getApplicationDocumentsDirectory();
    final Directory rootFolder = Directory('${dir.path}/Root/');
    if(!(await rootFolder.exists())){
      final newRootFolder= await rootFolder.create(recursive: false,);
      notes= await (Directory('${newRootFolder.path}/Notes').create(recursive:true));
      tasks= await (Directory('${newRootFolder.path}/Tasks').create(recursive:true));
      //return dir.path;
    }
    else{
      notes=Directory('${rootFolder.path}/Notes');
      tasks=Directory('${rootFolder.path}/Tasks');
    }
    root=new Folder("Root","Root",rootFolder,null);
    notesObj=new Folder("Notes","Root",notes,root);
    tasksObj=new Folder("Tasks","Root",tasks,root);
    root.list.add(notesObj);
    root.list.add(tasksObj);

    root.list.add(await initStruct(notes,notesObj,false));
    root.list.add(await initStruct(tasks,tasksObj,true));

    print(dir.path);
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
