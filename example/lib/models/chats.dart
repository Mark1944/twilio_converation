// To parse this JSON data, do
//
//     final chats = chatsFromJson(jsonString);

import 'dart:convert';

List<Chats> chatsFromJson(String str) =>
    List<Chats>.from(json.decode(str).map((x) => Chats.fromJson(x)));

class Chats {
  String participant;
  // String sid;
  List<dynamic> attachedMedia;
  String participantSid;
  String body;
  DateTime dateCreated;
  String author;
  int index;
  String description;

  Chats({
    required this.participant,
    // required this.sid,
    required this.attachedMedia,
    required this.participantSid,
    required this.body,
    required this.dateCreated,
    required this.author,
    required this.index,
    required this.description,
  });

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        participant: json["participant"] ?? "",
        // sid: json["sid"],
        attachedMedia: List<dynamic>.from(json["attachedMedia"].map((x) => x)),
        participantSid: json["participantSid"],
        body: json["body"],
        dateCreated: DateTime.parse(json["dateCreated"]),
        author: json["author"],
        index: json["index"],
        description: json["description"],
      );
}
