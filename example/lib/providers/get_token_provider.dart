import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:twilio_chat_plugin_example/helpers/logging.dart';
import 'package:twilio_chat_plugin_example/providers/conversation_initialization_provider.dart';
import 'package:twilio_chat_plugin_example/screens/chat_screen.dart';

final getTokenProviderLoader = StateProvider((ref) => true);

final getTokenProvider =
    StateNotifierProvider<GetTokenDetailsApiService, String>(
  (ref) {
    return GetTokenDetailsApiService(ref);
  },
);

class GetTokenDetailsApiService extends StateNotifier<String> {
  final Ref ref;
  GetTokenDetailsApiService(this.ref, [String? upcomingSessions])
      : super(
          upcomingSessions ?? '',
        );

  getToken({required BuildContext context, String? identity}) async {
    const url = "https://denim-albatross-3166.twil.io/token-service";

    final data = {
      "identity": identity,
      "password": "password01",
    };

    Response? res;

    final Dio dio = Dio()
      ..interceptors.add(Logging())
      ..interceptors.add(PrettyDioLogger());

    res = await dio.post(
      url,
      data: data,
    );

    ref.read(getTokenProviderLoader.notifier).state = false;

    if (res.statusCode == 200) {
      final String list = res.data;

      print(list);

      state = list;

      ref.read(twilioChatConversationPluginProvider);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(identity: identity),
        ),
      );
    }
  }
}
