import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import 'package:twilio_chat_plugin_example/models/chats.dart';
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

    print(result);
    result.sort((a, b) => (b['dateCreated']).compareTo(a['dateCreated']));
    final episodeObject = chatsFromJson(jsonEncode(result));

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
    String response;
    try {
      final String result = await twilioChatConversationPlugin.sendMessage(
            message: enteredMessage,
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
