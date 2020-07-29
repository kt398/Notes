import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'File.dart';
class SaveState {
  SharedPreferences prefs;
  bool isDark; //false is light, true is dark
  Folder root;
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
          object.list.add(new Task("${entity.path}","temp date"));
        }
        else{
          object.list.add(new Note("${entity.path}","temp date"));
        }
      }
      else if(entity is Directory){
        Folder temp =new Folder(entity.path,"test");
        object.list.add(await initStruct(dir, temp, isTask));
      }
    }
    return object;
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
    root=new Folder("Root","Root");
    Folder notesObj=new Folder("Notes","Root");
    Folder tasksObj=new Folder("Tasks","Root");
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
