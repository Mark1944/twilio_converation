import 'dart:convert';

class Constants {
  static getBody(String jsonString) {
    String body;
    try {
      body = jsonDecode(jsonString)['message'].toString();

      return body;
    } catch (e) {
      return jsonString;
    }
  }

  static getIsRead(String jsonString) {
    String isRead;

    try {
      isRead = jsonDecode(jsonString)['isRead'].toString();

      return isRead;
    } catch (e) {
      return jsonString;
    }
  }
}
