import 'package:shared_preferences/shared_preferences.dart';

class LocalData{

  static SharedPreferences? prefs;

  static void init() async{
    prefs = await SharedPreferences.getInstance();
  }


  static void setData({required String key , required dynamic value}){
    if(value is String){
      prefs?.setString(key, value);
    }
    else if(value is double ){
      prefs?.setDouble(key, value);
    }
    else if(value is int){
      prefs?.setInt(key, value);
    }
    else if(value is bool){
      prefs?.setBool(key, value);
    }
    else if(value is List<String>){
      prefs?.setStringList(key, value);
    }

  }


  static dynamic getData({required String key}){
    return prefs?.get(key);
  }

  static void  clearData(){
    prefs?.clear();
  }

}