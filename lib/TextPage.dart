import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  var date = DateTime.now();

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
    if (widget.file.type == Type.task) {
      date = (widget.file as Task).date;
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
      widget.file.dateModified =
          await (widget.file.entity as File).lastModified();
      return true;
    } else {
      return false;
    }
  }

  String notificationType(int notificationTypeInt) {
    switch (notificationTypeInt) {
      case 0:
        {
          return 'None';
        }
        break;
      case 1:
        {
          return 'One-Time';
        }
        break;
      case 2:
        {
          return 'Annual';
        }
      case 3:
        {
          return 'Weekly';
        }
        break;
      case 4:
        {
          return 'Daily';
        }
        break;
    }
    return '';
  }

  Future<int> notificationTypeAlertDialog() {
    return showDialog<int>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Notification Type'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
                child: const Text("None"),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
                child: const Text("One-Time"),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(4);
                },
                child: const Text("Daily"),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(3);
                },
                child: const Text("Weekly"),
              ),
              // SimpleDialogOption(
              //   onPressed: () {
              //     setState(() {
              //       (widget.file as Task).notificationType = 2;
              //     });
              //     Navigator.of(context).pop(2);
              //   },
              //   child: const Text("Annual"),
              //),
            ],
          );
        });
  }

  String getWeekday(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        {
          return 'Monday';
        }
        break;
      case 2:
        {
          return 'Tuesday';
        }
        break;
      case 3:
        {
          return 'Wednesday';
        }
        break;
      case 4:
        {
          return 'Thursday';
        }
        break;
      case 5:
        {
          return 'Friday';
        }
        break;
      case 6:
        {
          return 'Saturday';
        }
        break;
      case 7:
        {
          return 'Sunday';
        }
        break;
    }
    return '';
  }

  String dateAndTime(DateTime date, TimeOfDay time) {
    switch ((widget.file as Task).notificationType) {
      case 0:
        {
          return '';
        }
        break;
      case 1:
        {
          return '${date.month}/${date.day}/${date.year} ${time.format(context)}';
        }
        break;
      case 2:
        {
          return 'this shouldnt work';
        }
        break;
      case 3:
        {
          //weekly
          return '${getWeekday(date.weekday)} ${time.format(context)}';
        }
        break;
      case 4:
        {
          //daily
          return '${time.format(context)}  ';
        }
    }
    return '';
  }

  Row printDateTime(DateTime date) {
    TimeOfDay time = new TimeOfDay(hour: date.hour, minute: date.minute);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        '  ${notificationType((widget.file as Task).notificationType)}',
      ),
      Text(
        '${dateAndTime(date, time)}',
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
                preferredSize: Size.fromHeight(20), child: printDateTime(date))
            : null,
        actions: <Widget>[
          if (widget.file.type == Type.task)
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () async {
                notificationTypeAlertDialog().then((value) async {
                  if (value == null) {
                    //Barrier dismissed, not sure if this works
                    return;
                  } else if (value == 0) {
                    //No notification, no date
                    setState(() {
                      (widget.file as Task).notificationType = 0;
                      return;
                    });
                  } else if (value == 1) {
                    //One-time notification
                    var dateTemp = await selectDate();
                    if (dateTemp == null) return;
                    var timeTemp = await selectTime();
                    if (timeTemp == null) return;
                    DateTime finalDate = new DateTime(
                        dateTemp.year,
                        dateTemp.month,
                        dateTemp.day,
                        timeTemp.hour,
                        timeTemp.minute,
                        0,
                        0,
                        0);
                    setState(() {
                      (widget.file as Task).changeDate(finalDate);
                    });
                    await turnOffNotificationById(notificationsPlugin,
                        (widget.file as Task).notificationID);
                    await scheduleNotification(
                        notificationsPlugin,
                        widget.file.entity.path,
                        (widget.file as Task).notificationID,
                        widget.file.title,
                        finalDate);
                    setState(() {
                      date = finalDate;
                      (widget.file as Task).notificationType = value;
                    });
                  } else if (value == 3) {
                    //Weekly Notification
                    var dateTemp = await selectDate();
                    if (dateTemp == null) return;
                    var timeTemp = await selectTime();
                    if (timeTemp == null) return;
                    DateTime finalDate = new DateTime(
                        dateTemp.year,
                        dateTemp.month,
                        dateTemp.day,
                        timeTemp.hour,
                        timeTemp.minute,
                        0,
                        0,
                        0);
                    setState(() {
                      (widget.file as Task).changeDate(finalDate);
                      (widget.file as Task).notificationType = value;
                    });
                    await turnOffNotificationById(notificationsPlugin,
                        (widget.file as Task).notificationID);
                    await scheduleNotificationWeekly(
                        notificationsPlugin,
                        widget.file.entity.path,
                        (widget.file as Task).notificationID,
                        widget.file.title,
                        finalDate);
                    setState(() {
                      date = finalDate;
                    });
                  } else if (value == 4) {
                    var timeTemp = await selectTime();
                    if (timeTemp == null) return;
                    DateTime finalDate = new DateTime(
                        1, 1, 1, timeTemp.hour, timeTemp.minute, 0, 0, 0);
                    setState(() {
                      (widget.file as Task).changeDate(finalDate);
                      (widget.file as Task).notificationType = value;
                    });
                    await turnOffNotificationById(notificationsPlugin,
                        (widget.file as Task).notificationID);
                    await scheduleNotificationDaily(
                        notificationsPlugin,
                        widget.file.entity.path,
                        (widget.file as Task).notificationID,
                        widget.file.title,
                        finalDate);
                    setState(() {
                      date = finalDate;
                    });
                  }
                });
              },
            ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.check),
              disabledColor: Theme.of(context).colorScheme.onBackground,
              color: Theme.of(context).colorScheme.onPrimary,
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
                } else {
                  Navigator.of(context).pop();
                }
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
