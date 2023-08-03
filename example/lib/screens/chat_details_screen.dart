import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twilio_chat_plugin_example/global/bubble_widget.dart';
import 'package:twilio_chat_plugin_example/global/chat_text_widget.dart';
import 'package:twilio_chat_plugin_example/providers/twillio_chats_provider.dart';

class ChatDetailsScreen extends HookConsumerWidget {
  final String conversationName;
  final String conversationSid;
  final String? identity;
  const ChatDetailsScreen(
      {Key? key,
      required this.conversationName,
      required this.conversationSid,
      required this.identity})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msgController = TextEditingController();

    final ScrollController controller =
        ScrollController(initialScrollOffset: 0);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
    final conversations = ref.watch(twilioChatsProvider(conversationSid));
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(conversationName),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: ListView.separated(
                  controller: controller,
                  itemCount: conversations.length,
                  reverse: true,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final message = conversations[index];

                    var isMe = (message.author == identity) ? true : false;

                    return BubbleWidget(messageMap: message, isMe: isMe);
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Padding(padding: EdgeInsets.only(bottom: 4)),
                )),
                ChatTextWidget(
                  hintText: "Type here..",
                  msgController: msgController,
                  haveValidation: true,
                  onSend: (typeMessage) {
                    ref
                        .read(twilioChatsProvider(conversationSid).notifier)
                        .sendMessage(
                          enteredMessage: typeMessage,
                          conversationSid: conversationSid,
                        );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
