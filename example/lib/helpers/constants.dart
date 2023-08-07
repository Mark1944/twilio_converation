import 'dart:convert';

class Constants {
  static getBody(String jsonString) {
    String body;
    try {
      body = jsonDecode(jsonString)['isRead'].toString();

      return body;
    } catch (e) {
      return jsonString;
    }
  }
}
