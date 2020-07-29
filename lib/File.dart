import 'package:notes/Constants.dart';

enum Type{
  notes,
  task,
  folder
}

class Files{
  Type type;
  String title;
  String dateModified;
  bool selected;
  Files(this.title,this.dateModified,this.selected,this.type);
}

class Note extends Files{
  Note(String title,String dateModified):super(title,dateModified, false,Type.notes){


  }



}

class Task extends Files{
  String date;
  Task(String title, String dateModified,):super(title,dateModified,false,Type.task){

  }
}


class Folder extends Files{
  List<Files> list;
  Folder(String title,String dateModified):super(title,dateModified,false,Type.folder){
    list=new List<Files>();
  }

}