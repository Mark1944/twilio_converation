import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
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
    List<dynamic> result = await twilioChatConversationPlugin.getMessages(
          conversationId: chatId,
        ) ??
        [];

    result.sort((a, b) => (b['dateCreated']).compareTo(a['dateCreated']));
    final episodeObject = chatsFromJson(jsonEncode(result));

    log("episodeObject ,$episodeObject");
    log("episodeObject id,$chatId");
    // log("episodeObject id,${episodeObject[0].sid}");u

    // for (var element in episodeObject) {
    updateMessage(
      conversationSid: chatId,
      enteredMessage: Constants.getBody(
        episodeObject[0].body,
      ),
      messageId: "episodeObject[0].sid",
    );
    // }

    state = episodeObject;
    subscribeToMessageUpdate();
  }

  subscribeToMessageUpdate() {
    twilioChatConversationPlugin.subscribeToMessageUpdate(
        conversationSid: chatId);
    twilioChatConversationPlugin.onMessageReceived.listen((event) {
      final result = Chats.fromJson(Map<String, dynamic>.from(event));

      if (mounted) {
        state = [
          ...state,
          result,
        ];
        state.sort((a, b) => (b.dateCreated).compareTo(a.dateCreated));
      }

      state = state;
    });
  }

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

    print(message);
    var encodedeMessage = jsonEncode(message);
    print("encodedeMessage ,$encodedeMessage");

    var decodeMessage = jsonDecode(encodedeMessage);
    print("decodeMessage ,$decodeMessage");

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
      required messageId}) async {
    var message = {
      "message": enteredMessage,
      "isLink": false,
      "isRead": true,
    };

    print(message);
    var encodedeMessage = jsonEncode(message);
    print("encodedeMessage ,$encodedeMessage");

    var decodeMessage = jsonDecode(encodedeMessage);
    print("decodeMessage ,$decodeMessage");

    String basicAuth =
        'Basic ${base64.encode(utf8.encode('ACb3e67678e4c98201c6d28b042c8fc9a4:50d38ccf51811b582d6f17d931f1fbd6'))}';
    //  final data = {
    //   "identity": identity,
    //   "password": "password01",
    // };

    print("basicAuth ,$basicAuth");

    Response? res;

    final Dio dio = Dio()
      ..interceptors.add(Logging())
      ..interceptors.add(PrettyDioLogger());

    res = await dio.post(
        "https://conversations.twilio.com/v1/Conversations/CHe90b7e2c8bad447eb7f90cff64dcf5ee/Messages/IM52af459b8e0343208a6a29f7e92b63bf",
// /*$conversationSid/Messages/$messageId*/  CH1ad24dc8893149659eeda23d379a7bd2    ",
        data: "Body=$encodedeMessage",
        options: Options(
          headers: {
            "Authorization": basicAuth,
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

  // POST https://conversations.twilio.com/v1/Conversations/{ConversationSid}/Messages/{Sid}

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


//  {
// flutter: ║                 body: "{"message":"heeey","isLink":false,"isRead":false}",
// flutter: ║                 index: 36,
// flutter: ║                 author: "user01",
// flutter: ║                 date_updated: "2023-08-07T13:34:59Z",
// flutter: ║                 media: null,
// flutter: ║                 participant_sid: "MB67ddeabaded84ce0b4e8ddff390b916e",
// flutter: ║                 conversation_sid: "CHe90b7e2c8bad447eb7f90cff64dcf5ee",
// flutter: ║                 account_sid: "ACb3e67678e4c98201c6d28b042c8fc9a4",
// flutter: ║                 delivery: null,
// flutter: ║                 "https://conversations.twilio.com/v1/Conversations/CHe90b7e2c8bad447eb7f90
// flutter: ║                 cff64dcf5ee/Messages/IM52af459b8e0343208a6a29f7e92b63bf"
// flutter: ║                 date_created: "2023-08-07T13:34:59Z",
// flutter: ║                 content_sid: null,
// flutter: ║                 sid: "IM52af459b8e0343208a6a29f7e92b63bf",
// flutter: ║                 attributes: "{}",
// flutter: ║                 links: {
// flutter: ║                     "https://conversations.twilio.com/v1/Conversations/CHe90b7e2c8bad447eb
// flutter: ║                     7f90cff64dcf5ee/Messages/IM52af459b8e0343208a6a29f7e92b63bf/Receipts"
// flutter: ║                     "https://conversations.twilio.com/v1/Conversations/CHe90b7e2c8bad447eb
// flutter: ║                     7f90cff64dcf5ee/Messages/IM52af459b8e0343208a6a29f7e92b63bf/ChannelMet
// flutter: ║                     adata"
// flutter: ║                }
// flutter: ║            }