import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'File.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:convert';
import 'dart:io';

class TextPage extends StatefulWidget {
  final String title;
  final Files file;
  TextPage(this.file, this.title);
  TextPageState createState() => TextPageState();
}

class TextPageState extends State<TextPage> {
  ZefyrController zController;
  FocusNode node;
  TextEditingController _controller = new TextEditingController();
  String title;
  var fontWeight = [false, false, false];
  var date = DateTime.now();
  var time = TimeOfDay.now();

  NotusDocument loadDocument() {
    if (widget.file.data.isNotEmpty) {
      final contents = widget.file.data;
      return NotusDocument.fromJson(jsonDecode(contents));
    }
    return NotusDocument();
  }

  @override
  void initState() {
    node = FocusNode();
    final document = loadDocument();
    zController = new ZefyrController(document);
    super.initState();
  }

  @override
  void dispose() {
    node.dispose();
    zController.dispose();
    super.dispose();
  }

  void _saveDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(zController.document);
    // For this example we save our document to a temporary file.
    // And show a snack bar on success.
    widget.file.data = contents;
    (widget.file.entity as File).writeAsString(contents, flush: true).then((_) {
      print("Saved");
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Saved"),
        elevation: 20,
        backgroundColor: Theme.of(context).colorScheme.onBackground,
      ));
    });
    //Navigator.pop(context);
  }

  Text printDateTime(DateTime date, TimeOfDay time) {
    return Text(
      '${date.month}/${date.day}/${date.year} ${time.format(context)}',
      style: TextStyle(fontSize: 18, letterSpacing: -1),
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
        automaticallyImplyLeading: false,
        title: Text(
          widget.file.title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        actions: <Widget>[
          if (widget.file.type == Type.task) printDateTime(date, time),
          if (widget.file.type == Type.task)
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () async {
                var dateTemp = await selectDate();
                if (dateTemp == null) return;
                var timeTemp = await selectTime();
                if (timeTemp == null) return;
                print(date.toString());
                print(time.toString());
                setState(() {
                  date = dateTemp;
                  time = timeTemp;
                });
              },
            ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.check),
              disabledColor: Theme.of(context).colorScheme.onBackground,
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () async {
                _saveDocument(context);
                //Navigator.popUntil(context, (route) => false),
              },
            ),
          ),
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrEditor(
          controller: zController,
          padding: EdgeInsets.all(16),
          autofocus: false,
          focusNode: node,
        ),
      ),
    );
  }
}
