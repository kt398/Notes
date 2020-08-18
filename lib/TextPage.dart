import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes/main.dart';
import 'File.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io';
import 'NotificationHelper.dart';

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
  var date=DateTime.now();
  var time = TimeOfDay.now();
  var finalDateTime = DateTime.now();

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
    if(widget.file.type==Type.task){
      date=(widget.file as Task).date;
    }
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
    final contents = jsonEncode(zController.document);
    if (widget.file.data != contents) {
      widget.file.data = contents;
      String plainText = zController.document.toPlainText();
      widget.file.plainText = plainText;
      await (widget.file.entity as File).writeAsString(contents, flush: true);
      await Future.delayed(new Duration(milliseconds: 750));
      return true;
    } else {
      return false;
    }
  }

  Row printDateTime(DateTime date, TimeOfDay time) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text(
        '${date.month}/${date.day}/${date.year} ${time.format(context)}',
        style: TextStyle(fontSize: 20, letterSpacing: 0),
      ),
    ]);
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
              if (await _saveDocument(context)) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            }),
        title: Text(
          widget.file.title,
          style: Theme.of(context)
              .textTheme
              .headline1
              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        bottom: widget.file.type == Type.task
            ? PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: printDateTime(date, time))
            : null,
        actions: <Widget>[
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
                DateTime finalDate = new DateTime(dateTemp.year, dateTemp.month,
                    dateTemp.day, timeTemp.hour, timeTemp.minute, 0, 0, 0);
                print(finalDate.toIso8601String());
                setState(() {
                  (widget.file as Task).changeDate(finalDate);
                });
                await turnOffNotificationById(flutterLocalNotificationsPlugin,(widget.file as Task).notificationID);
                await scheduleNotification(flutterLocalNotificationsPlugin,
                    widget.file.entity.path, (widget.file as Task).notificationID, 'Test body', finalDate);
                //print((widget.file as Task).date.toString());
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
