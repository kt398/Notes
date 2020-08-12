
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'saveState.dart';
import 'ThemeChanger.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget{
  final SaveState save;
  Settings(this.save);
  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Settings>{

  Widget build(BuildContext context){
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    bool isDark= widget.save.isDark;
    print(isDark);
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon:Icon(Icons.arrow_back,color:Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.headline1,
          ),
      ),
      body: Builder(
        builder: (context){
          double bodyHeight=MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight;
          double width=MediaQuery.of(context).size.width;
          return ListView(
            children: <Widget>[
              Container(
                width: width,
                height: bodyHeight/8,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[600],width:1),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Dark Mode",
                      style: Theme.of(context).textTheme.headline1.apply(color: Theme.of(context).colorScheme.onBackground),
                    ),
                    Switch(
                      value: isDark,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value){
                        setState(() {
                          widget.save.isDark=!widget.save.isDark;
                          widget.save.write();
                          if(value){
                            _themeChanger.setTheme(ThemeChanger.darkTheme());
                          }
                          else{
                            _themeChanger.setTheme(ThemeChanger.lightTheme());

                          }
                          //widget.save.isDark=value;
                        });
                      }
                    )
                    


                  ],
                ),


              ),
              Container(
                width: width,
                height: bodyHeight/8,
                decoration: BoxDecoration(
                  border: Border(
                    //top:BorderSide(color: Colors.grey,width: 1),
                    bottom: BorderSide(color: Colors.grey[600],width:1),
                  )
                ),


              )
            
            
            
            ],
          );
        }
      ),
    );
  }
}