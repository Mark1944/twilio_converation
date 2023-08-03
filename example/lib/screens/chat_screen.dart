import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twilio_chat_plugin_example/global/common_text_button_widget.dart';
import 'package:twilio_chat_plugin_example/global/dialog_with_edittext.dart';
import 'package:twilio_chat_plugin_example/providers/create_conversation_provider.dart';
import 'package:twilio_chat_plugin_example/providers/get_token_provider.dart';
import 'package:twilio_chat_plugin_example/screens/conversation_list_screen.dart';

class ChatScreen extends HookConsumerWidget {
  final String? identity;
  const ChatScreen({Key? key, required this.identity}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatToken = ref.read(getTokenProvider);
    final chatTokenLoader = ref.read(getTokenProviderLoader);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.80,
                height: MediaQuery.of(context).size.height * 0.08,
                child: SvgPicture.asset(
                  "assets/images/twilio_logo_red.svg",
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            chatTokenLoader
                ? const CircularProgressIndicator()
                : Text(
                    chatToken,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
            CommonTextButtonWidget(
              isIcon: false,
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.82,
              title: "Create Conversation",
              titleFontSize: 14.0,
              bgColor: Colors.blueGrey,
              borderColor: Colors.white,
              titleFontWeight: FontWeight.w600,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogWithEditText(
                      onPressed: (enteredText) {
                        // chatBloc!.add(CreateConversationEvent(
                        // conversationName: enteredText,
                        // identity: widget.identity));
                        ref
                            .read(twilioCreateConversationProvider.notifier)
                            .createConverstion(
                                conversationName: enteredText,
                                identity: identity);

                        Navigator.of(context).pop();
                      },
                      dialogTitle: "Create Conversation",
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.030,
            ),
            CommonTextButtonWidget(
              isIcon: false,
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.82,
              bgColor: Colors.blueGrey,
              borderColor: Colors.white,
              title: "My Conversations",
              titleFontSize: 14.0,
              titleFontWeight: FontWeight.w600,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationListScreen(
                      identity: identity,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
