import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import 'package:twilio_chat_plugin_example/providers/get_token_provider.dart';

final twilioChatConversationPluginProvider = Provider((ref) async {
  final accessToken = ref.read(getTokenProvider);

  final TwilioChatConversation twilioChatConversationPlugin =
      TwilioChatConversation();

  try {
    String result = await twilioChatConversationPlugin
            .initializeConversationClient(accessToken: accessToken) ??
        "UnImplemented Error";

    print(result == "Authentication Successful");
  } on PlatformException catch (e) {
    e.message.toString();
  }

  return twilioChatConversationPlugin;

  // return ;
});
