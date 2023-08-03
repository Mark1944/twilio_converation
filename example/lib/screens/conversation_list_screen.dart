import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twilio_chat_plugin_example/global/dialog_with_edittext.dart';
import 'package:twilio_chat_plugin_example/providers/create_conversation_provider.dart';
import 'package:twilio_chat_plugin_example/providers/twillio_chats_provider.dart';

class ConversationListScreen extends HookConsumerWidget {
  final String? identity;
  const ConversationListScreen({Key? key, required this.identity})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationList = ref.watch(twilioCreateConversationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: Colors.black12,
      ),
      backgroundColor: Colors.black12,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView.builder(
            itemCount: conversationList.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blueGrey,
                    elevation: 10,
                    child: ListTile(
                      title: Text(
                        conversationList[index]["conversationName"],
                        style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        conversationList[index]["sid"],
                        style: const TextStyle(
                            fontSize: 12.0, color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DialogWithEditText(
                                      onPressed: (enteredText) {
                                        //conversationName =
                                        //conversationList[index]
                                        // ["conversationName"];
                                        // conversationSid = conversationList[index]["sid"];
                                        // chatBloc!.add(AddParticipantEvent(
                                        //     participantName: enteredText,
                                        //     conversationName: widget
                                        //             .conversationList[index]
                                        //         ["sid"]));
                                        ref
                                            .read(
                                                twilioCreateConversationProvider
                                                    .notifier)
                                            .addParticipant(
                                              participantName: enteredText,
                                              conversationId:
                                                  conversationList[index]
                                                      ["sid"],
                                            );
                                        Navigator.of(context).pop();
                                      },
                                      dialogTitle: "Add Participant",
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.person_add_alt_1_sharp,
                                color: Colors.cyanAccent,
                              )),
                          IconButton(
                              onPressed: () {
                                ref
                                    .read(twilioChatsProvider(
                                            conversationList[index]["sid"])
                                        .notifier)
                                    .joinChat(
                                      conversationId: conversationList[index]
                                          ["sid"],
                                      conversationName: conversationList[index]
                                          ["conversationName"],
                                      identity: identity,
                                      context: context,
                                    );
                              },
                              icon: const Icon(
                                Icons.chat,
                                color: Colors.greenAccent,
                              )),
                          IconButton(
                              onPressed: () {
                                // chatBloc!.add(GetParticipantsEvent(
                                //     conversationId: widget
                                //         .conversationList[index]["sid"]));
                              },
                              icon: const Icon(
                                Icons.people_alt_rounded,
                                color: Colors.limeAccent,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // if (state is GetParticipantsLoadedState) {
        //   ProgressBar.dismiss(context);
        //   showBottomSheet(
        //       backgroundColor: Colors.transparent,
        //       context: context,
        //       builder: (c) {
        //         return SingleChildScrollView(
        //           child: Container(
        //             padding: EdgeInsets.zero,
        //             margin: EdgeInsets.zero,
        //             decoration: const BoxDecoration(
        //                 color: Colors.white54,
        //                 borderRadius: BorderRadius.all(Radius.circular(15)),
        //                 boxShadow: [
        //                   BoxShadow(
        //                       blurRadius: 10,
        //                       color: Colors.black,
        //                       spreadRadius: 5)
        //                 ]),
        //             // height: 200,
        //             child: Column(
        //               mainAxisSize: MainAxisSize.min,
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 const Padding(
        //                   padding: EdgeInsets.all(10.0),
        //                   child: Row(
        //                     children: [
        //                       Icon(
        //                         Icons.people_outline_outlined,
        //                         size: 30,
        //                         color: Colors.limeAccent,
        //                       ),
        //                       Padding(
        //                         padding: EdgeInsets.only(left: 8.0),
        //                         child: Text(
        //                           "Participants",
        //                           style: TextStyle(
        //                               color: Colors.limeAccent,
        //                               fontSize: 20,
        //                               fontWeight: FontWeight.w600),
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 ListView.separated(
        //                   padding: const EdgeInsets.all(10.0),
        //                   physics: const ClampingScrollPhysics(),
        //                   shrinkWrap: true,
        //                   separatorBuilder: (c, i) {
        //                     return const Divider(
        //                       height: 2.0,
        //                     );
        //                   },
        //                   itemBuilder: (context, index) {
        //                     return Card(
        //                       child: Padding(
        //                         padding: const EdgeInsets.all(15.0),
        //                         child: Row(
        //                           children: [
        //                             const Icon(
        //                               Icons.person,
        //                               size: 20,
        //                               color: Colors.brown,
        //                             ),
        //                             Padding(
        //                               padding:
        //                                   const EdgeInsets.only(left: 8.0),
        //                               child: Text(
        //                                 "${state.participantsList[index]}",
        //                                 style: const TextStyle(
        //                                     color: Colors.brown,
        //                                     fontSize: 15,
        //                                     fontWeight: FontWeight.w500),
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                   itemCount: state.participantsList.length,
        //                 ),
        //               ],
        //             ),
        //           ),
        //         );
        //       });
        // }
        //   if (state is GetParticipantsErrorState) {
        //     ProgressBar.dismiss(context);
        //     ToastUtility.showToastAtCenter(
        //         "Something went wrong. Please try again later.");

        // },
      ),
    );
  }
}
