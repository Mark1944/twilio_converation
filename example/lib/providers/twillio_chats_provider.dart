import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import 'package:twilio_chat_plugin_example/helpers/constants.dart';
import 'package:twilio_chat_plugin_example/helpers/logging.dart';
import 'package:twilio_chat_plugin_example/models/chats.dart';
import 'package:twilio_chat_plugin_example/providers/get_token_provider.dart';
import 'package:twilio_chat_plugin_example/screens/chat_details_screen.dart';

final twilioChatsProviderLoader = StateProvider((ref) => true);

final twilioChatsProvider =
    StateNotifierProvider.family<TwilioChats, List<Chats>, String>(
  (ref, chatId) {
    return TwilioChats(ref, chatId);
  },
);

class TwilioChats extends StateNotifier<List<Chats>> {
  final Ref ref;
  final String chatId;
  TwilioChats(this.ref, this.chatId, [List<Chats>? upcomingSessions])
      : super(
          upcomingSessions ?? [],
        ) {
    getChat();
  }
  final TwilioChatConversation twilioChatConversationPlugin =
      TwilioChatConversation();

  getChat() async {
    final identity = ref.watch(identityProvider);
    List<Chats> chats = [];
    List<dynamic> result = await twilioChatConversationPlugin.getMessages(
          conversationId: chatId,
        ) ??
        [];

    var resultss = jsonEncode(result);
    var resultss2 = jsonDecode(resultss);

    debugPrint(resultss2.toString());

    for (var elm in resultss2) {
      String? sid;
      String? body;
      String? dateCreated;
      String? author;
      List<dynamic> attachedMedia;

      if (defaultTargetPlatform == TargetPlatform.android) {
        sid = elm['sid'];
        body = elm['body'];
        dateCreated = elm['dateCreated'];
        author = elm['author'];
        attachedMedia = elm['attachedMedia'] ?? [];
      } else {
        sid = extractValue(elm['description'], "sid: '([^']+)'");
        body = extractValue(elm['description'], "body: '([^']+)'");
        dateCreated =
            extractValue(elm['description'], "dateCreated: '([^']+)'");
        author = extractValue(elm['description'], "author: '([^']+)'");
        attachedMedia = elm['attachedMedia'];
      }

      chats.add(
        Chats(
          // participant: elm['participant'],
          sid: sid!,
          attachedMedia: attachedMedia,
          body: body!,
          dateCreated: DateTime.parse(dateCreated!),
          author: author!,
        ),
      );
    }

    for (var chat in chats) {
      if (Constants.getIsRead(
                chat.body,
              ) ==
              "false" &&
          chat.author != identity) {
        updateMessage(
          conversationSid: chatId,
          author: chat.author,
          enteredMessage: Constants.getBody(
            chat.body,
          ),
          messageId: chat.sid,
        );
      }
    }
    chats.sort((a, b) => (b.dateCreated).compareTo(a.dateCreated));

    state = chats;
    subscribeToMessageUpdate();
  }

  String? extractValue(String input, String pattern) {
    RegExp regExp = RegExp(pattern);
    RegExpMatch? match = regExp.firstMatch(input);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  subscribeToMessageUpdate() {
    twilioChatConversationPlugin.subscribeToMessageUpdate(
        conversationSid: chatId);
    twilioChatConversationPlugin.onMessageReceived.listen((event) {

          final identity = ref.watch(identityProvider);

      String? sid;
      String? body;
      String? dateCreated;
      String? author;
      List<dynamic> attachedMedia;

      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint(event['body']);

        sid = event['sid'];
        body = event['body'];
        dateCreated = event['dateCreated'];
        author = event['author'];
        attachedMedia = event['attachedMedia'] ?? [];
      } else {
        sid = extractValue(event['description'], "sid: '([^']+)'");
        body = extractValue(event['description'], "body: '([^']+)'");
        dateCreated =
            extractValue(event['description'], "dateCreated: '([^']+)'");
        author = extractValue(event['description'], "author: '([^']+)'");
        attachedMedia = event['attachedMedia'];
      }

      if (state.any((obj) => obj.sid == sid)) {
        state = [
          for (final chatt in state)
            if (chatt.sid == sid)
              Chats(
                // participant: event['participant'],
                sid: sid!,
                attachedMedia: attachedMedia,
                body: body!,
                dateCreated: DateTime.parse(dateCreated!),
                author: author!,
              )
            else
              chatt,
        ];
      } else {
        state = [
          ...state,
          Chats(
            // participant: event['participant'],
            sid: sid!,
            attachedMedia: attachedMedia,
            body: body!,
            dateCreated: DateTime.parse(dateCreated!),
            author: author!,
          ),
        ];
      }

      state.sort((a, b) => (b.dateCreated).compareTo(a.dateCreated));

      state = state;

      if (author != identity) {
        updateMessage(
          conversationSid: chatId,
          author: author!,
          enteredMessage: Constants.getBody(
            body!,
          ),
          messageId: sid,
        );
      }
    });
  }

  // sssssssend({required String bodys}) async {
  //   const uname = 'ACb3e67678e4c98201c6d28b042c8fc9a4';
  //   const pword = '50d38ccf51811b582d6f17d931f1fbd6';
  //   final authn = 'Basic ${base64Encode(utf8.encode('$uname:$pword'))}';

  //   final headers = {
  //     'Content-Type': 'application/x-www-form-urlencoded',
  //     'Authorization': authn,
  //     'X-Twilio-Webhook-Enabled': 'false',
  //   };

  //   print("res.body error header: ,$headers");

  //   final data = {
  //     'Author': 'user02',
  //     'Body': bodys,
  //   };

  //   final url = Uri.parse(
  //       'https://conversations.twilio.com/v1/Conversations/CH246dade7a4ae40d383da0b1480827a84/Messages/IM4eea9abad29443a3826e4ee40767d577');

  //   late http.Response res;
  //   try {
  //     res = await http.post(url, headers: headers, body: data);
  //   } catch (e) {
  //     print("res.body error: ,$e");
  //   }
  //   final status = res.statusCode;
  //   if (status != 200) throw Exception('http.post error: statusCode= $status');

  //   // print(res.body);

  //   print("res.body error body: ,${res.body}");
  // }

  joinChat({
    required conversationId,
    required conversationName,
    String? identity,
    required BuildContext context,
  }) async {
    String response;
    try {
      final String result = await twilioChatConversationPlugin.joinConversation(
              conversationId: conversationId) ??
          "UnImplemented Error";
      response = result;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatDetailsScreen(
            identity: identity,
            conversationName: conversationName,
            conversationSid: conversationId,
          ),
        ),
      );

      return response;
    } on PlatformException catch (e) {
      response = e.message.toString();
      return response;
    }
  }

  sendMessage(
      {required String enteredMessage, required String conversationSid}) async {
    var message = {
      "message": enteredMessage,
      "isLink": false,
      "isRead": false,
    };

    var encodedeMessage = jsonEncode(message);

    String response;
    try {
      final String result = await twilioChatConversationPlugin.sendMessage(
            message: encodedeMessage,
            conversationId: conversationSid,
          ) ??
          "UnImplemented Error";

      response = result;
      return response;
    } on PlatformException catch (e) {
      response = e.message.toString();
      return response;
    }
  }

  updateMessage(
      {required String enteredMessage,
      required String conversationSid,
      required messageId,
      required String author}) async {
    var message = {
      "message": enteredMessage,
      "isLink": false,
      "isRead": true,
    };

    var encodedeMessage = jsonEncode(message);

    String basicAuth =
        'Basic ${base64.encode(utf8.encode('ACb3e67678e4c98201c6d28b042c8fc9a4:50d38ccf51811b582d6f17d931f1fbd6'))}';

    final data = {
      'Author': author,
      'Body': encodedeMessage,
    };

    Response? res;

    final Dio dio = Dio()
      ..interceptors.add(Logging())
      ..interceptors.add(PrettyDioLogger());

    res = await dio.post(
        "https://conversations.twilio.com/v1/Conversations/$conversationSid/Messages/$messageId",
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "Authorization": basicAuth,
             'X-Twilio-Webhook-Enabled': true,
          },
        ));

    print("res, $message");

    print(res);
    print(res.statusCode);
    print(res.data);

    if (res.statusCode == 200) {
      // final String list = res.data;

      // state = list;
    }

    // String response;
    // try {
    //   final String result = await twilioChatConversationPlugin.sendMessage(
    //         message: encodedeMessage,
    //         conversationId: conversationSid,
    //       ) ??
    //       "UnImplemented Error";
    //   response = result;
    //   return response;
    // } on PlatformException catch (e) {
    //   response = e.message.toString();
    //   return response;
    // }
  }

  void unSubscribeToMessageUpdate() {
    twilioChatConversationPlugin.unSubscribeToMessageUpdate(
        conversationSid: chatId);
  }

  @override
  void dispose() {
    super.dispose();
    unSubscribeToMessageUpdate();
  }
}
