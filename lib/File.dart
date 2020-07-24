import 'package:notes/Constants.dart';

class FileList<T>{

  T file;
  List list;
  FileList(int numItems){
    list=List<File>(numItems);

  }



}

enum Type{
  notes,
  task,
  folder


}

class File{
  Type type;
  String title;
  String dateModified;
  bool selected;
  File(this.title,this.dateModified,this.selected,this.type);
}

class Note extends File{
  Note(String title,String dateModified):super(title,dateModified, false,Type.notes){


  }



}

class Task extends File{

  String date;
  Task(String title, String dateModified,):super(title,dateModified,false,Type.task){



  }
}


class Folder extends File{

  Folder(String title,String dateModified):super(title,dateModified,false,Type.folder){
    
  }

}