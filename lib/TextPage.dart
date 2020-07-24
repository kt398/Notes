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
            IconButton(
              icon: Icon(Icons.format_bold),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.format_italic),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.format_underlined),
              onPressed: () {},
            )
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

                      ),
                      onChanged: (text) {
                        title=text;
                      },
                    ),
                  ),
                  if(widget.type==Type.task)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        
                      },
                    )
                  )
                ],
              )),
        ),
        body: Stack());
  }
}
