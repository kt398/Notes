import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'File.dart';

class TextPage extends StatefulWidget {
  Type type;
  String title;
  TextPage(this.type, this.title);
  TextPageState createState() => TextPageState();
}

class TextPageState extends State<TextPage> {
  TextEditingController _controller = new TextEditingController();
  String title;
  var fontWeight=[false,false,false];
  var date=DateTime.now();
  var time=TimeOfDay.now();

  Text printDateTime(DateTime date, TimeOfDay time) {
    return Text(
        '${date.month}/${date.day}/${date.year} ${time.format(context)}',
        style:TextStyle(
          fontSize: 18,
          letterSpacing: -1


        ) ,
    );
  }

  Future<DateTime> selectDate() {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
  }

  Future<TimeOfDay> selectTime() {
    return showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  @override
  Widget build(BuildContext context) {
    _controller.text = '${widget.title}';
    print(widget.title);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            ToggleButtons(
              isSelected: fontWeight,
              selectedBorderColor: Colors.transparent,
              disabledBorderColor: Colors.transparent,
              renderBorder: false,
              children: <Widget>[
                Icon(Icons.format_bold,),
                Icon(Icons.format_italic),
                Icon(Icons.format_underlined),
              ],
              onPressed: (index) {
                setState((){
                  fontWeight[index]=!fontWeight[index];
                });
              },
            ),
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      onChanged: (text) {
                        title = text;
                      },
                    ),
                  ),
                  if (widget.type == Type.task)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Align(
                            alignment: Alignment.centerRight,
                            child: printDateTime(date, time)),
                        Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                var dateTemp = await selectDate(); 
                                if (dateTemp == null) return;
                                var timeTemp = await selectTime();
                                if (timeTemp == null) return;
                                print(date.toString());
                                print(time.toString());
                                setState(() {
                                  date=dateTemp;
                                  time=timeTemp;
                                });
                              },
                            )),
                      ],
                    )
                ],
              )),
        ),
        body: Stack());
  }
}
