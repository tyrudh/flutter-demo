import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  static Future<void> saveUserData(String phoneNumber, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_phone_$phoneNumber', name);
  }

  static Future<String?> getUserDataByPhoneNumber(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone_$phoneNumber');
  }
}
