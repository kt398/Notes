class List{

  List list;







}

class File{

  String title;
  String dateModified;
  bool selected;
  File(this.title,this.dateModified,this.selected);
}

class Note extends File{
  Note(String title,String dateModified):super(title,dateModified, false){



  }



}

class Task extends File{

  String date;
  Task(String title, String dateModified,):super(title,dateModified,false){





  }



}