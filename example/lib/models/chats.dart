class Chats {
  // String participant;
  String sid;
  List<dynamic> attachedMedia;
  String body;
  DateTime dateCreated;
  String author;

  Chats({
    // required this.participant,
    required this.sid,
    required this.attachedMedia,
    required this.body,
    required this.dateCreated,
    required this.author,
  });
}

class Person {
  String identity;
  String conversationSid;

  Person({
    required this.identity,
    required this.conversationSid,
  });
}
