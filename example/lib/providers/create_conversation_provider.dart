import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';

final twilioCreateConversationProviderLoader = StateProvider((ref) => true);

final twilioCreateConversationProvider =
    StateNotifierProvider<GetTokenDetailsApiService, List>(
  (ref) {
    return GetTokenDetailsApiService(ref);
  },
);

class GetTokenDetailsApiService extends StateNotifier<List> {
  final Ref ref;
  GetTokenDetailsApiService(this.ref, [List? upcomingSessions])
      : super(
          upcomingSessions ?? [],
        ) {
    getConversations();
  }
  final TwilioChatConversation twilioChatConversationPlugin =
      TwilioChatConversation();

  createConverstion({required conversationName, required identity}) async {
    String response;
    try {
      final String result =
          await twilioChatConversationPlugin.createConversation(
                  conversationName: conversationName, identity: identity) ??
              "UnImplemented Error";

      response = result;
      return response;
    } on PlatformException catch (e) {
      response = e.message.toString();
      return response;
    }
  }

  getConversations() async {
    List response;
    try {
      final List result =
          await twilioChatConversationPlugin.getConversations() ?? [];

      response = result;
      state = response;
    } on PlatformException catch (_) {
      return [];
    }
  }

  addParticipant({required participantName, required conversationId}) async {
    print("object , $participantName");
    print("object , $conversationId");

    String response;
    try {
      final String result = await twilioChatConversationPlugin.addParticipant(
              participantName: participantName,
              conversationId: conversationId) ??
          "UnImplemented Error";

      response = result;

      // if (response.contains("User not found") {
      //   ToastUtility.showToastAtBottom(response);
      // } else {
      print("response , $response");
      // }

      return response;
    } on PlatformException catch (e) {
      print("object , $e");
      response = e.message.toString();
      return response;
    }
  }
}
