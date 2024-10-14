// Under Construction

/*
Insights:
  1. The secure storage is used to store the user data securely.
  2. The user data is stored in the form of key-value pairs.
  3. Could be used to reduce the usage of IOPS.
*/

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  // Creating an instance of FlutterSecureStorage
  static const _storage = FlutterSecureStorage();

  // Declaring keys for the storage
  static const _keyUserId = 'userId';
  static const _keyUserDisplayName = 'userDisplayName';
  static const _keyUserType = 'userType';
  static const _keyUserTags = 'userTags';
  static const _userPhotoUrl = 'userPhotoUrl';

  // Setter for userId
  static Future<void> setUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  // Getter for userId
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // Setter for userDisplayName
  static Future<void> setUserDisplayName(String userDisplayName) async {
    await _storage.write(key: _keyUserDisplayName, value: userDisplayName);
  }

  // Getter for userDisplayName
  static Future<String?> getUserDisplayName() async {
    return await _storage.read(key: _keyUserDisplayName);
  }

  // Setter for userType
  static Future<void> setUserType(String userType) async {
    await _storage.write(key: _keyUserType, value: userType);
  }

  // Getter for userType
  static Future<String?> getUserType() async {
    return await _storage.read(key: _keyUserType);
  }

  // Setter for userTags
  static Future<void> setUserTags(List<String> tags) async {
    String tagsJson = jsonEncode(tags);
    await _storage.write(key: _keyUserTags, value: tagsJson);
  }

  // Getter for userTags
  static Future<List<String>?> getUserTags() async {
    String? tagsJson = await _storage.read(key: _keyUserTags);
    if (tagsJson != null) {
      List<dynamic> tagsList = jsonDecode(tagsJson);
      return tagsList.cast<String>();
    }
    return null;
  }

  // Setter for userPhotoUrl
  static Future<void> setUserPhotoUrl(String userPhotoUrl) async {
    await _storage.write(key: _userPhotoUrl, value: userPhotoUrl);
  }

  // Getter for userPhotoUrl
  static Future<String?> getUserPhotoUrl() async {
    return await _storage.read(key: _userPhotoUrl);
  }

  // Function to clear all values
  static Future<void> clearAll() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserDisplayName);
    await _storage.delete(key: _keyUserType);
    await _storage.delete(key: _keyUserTags);
    await _storage.delete(key: _userPhotoUrl);
    // await _storage.deleteAll(); // Doesn't work on certain platform
  }
}
