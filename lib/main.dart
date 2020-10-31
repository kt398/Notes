import 'package:flutter/material.dart';
import 'Home.dart';
import 'saveState.dart';
import 'package:provider/provider.dart';
import 'ThemeChanger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'NotificationHelper.dart';
import 'package:flutter/services.dart';


final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationAppLaunchDetails =
      await notificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(notificationsPlugin);
  requestIOSPermissions(notificationsPlugin);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(MyApp());
    });
}

class MyApp extends StatelessWidget {
  Future<SaveState> initSaveState() async {
  SaveState save = new SaveState();
  await save.localPath;
  await save.init();
  return save;
}
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SaveState>(
      future: initSaveState(),
      builder: (BuildContext context,AsyncSnapshot<SaveState> save){
        if(save.hasData){
          return ChangeNotifierProvider<ThemeChanger>(
            create: (_) => ThemeChanger(save.data.isDark?ThemeChanger.darkTheme():ThemeChanger.lightTheme()),
            child: new MaterialAppWithTheme(save.data),
          );



        }
        else{
          return Container(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          );
        }
      }
    );
  }
}


class MaterialAppWithTheme extends StatelessWidget {
  final SaveState save;
  MaterialAppWithTheme(this.save);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      home: Home(save),
      theme: theme.getTheme(),
      routes: {
        '/home':(context)=> Home(save),


      },
    );
  }
}