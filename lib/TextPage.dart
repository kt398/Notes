import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'File.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:convert';
import 'dart:io' show Platform;
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

  Future<bool> _saveDocument(BuildContext context) async {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(zController.document);
    // For this example we save our document to a temporary file.
    // And show a snack bar on success.
    if (widget.file.data != contents) {
      widget.file.data = contents;
      String plainText=zController.document.toPlainText();
      widget.file.plainText=plainText;
      await (widget.file.entity as File).writeAsString(contents, flush: true);
      await Future.delayed(new Duration(milliseconds: 750));
    }
    else{
    }
    return true;
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(
              Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () async {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      contentPadding: EdgeInsets.fromLTRB(0, 16, 12, 16),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Saving...'),
                            CircularProgressIndicator(),
                          ],
                        ),
                      ],
                    );
                  });
              await _saveDocument(context);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
        title: Text(
          widget.file.title,
          style: Theme.of(context).textTheme.headline1.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
                await _saveDocument(context);
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
