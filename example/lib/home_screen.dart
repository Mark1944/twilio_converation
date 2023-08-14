import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twilio_chat_plugin_example/global/common_text_button_widget.dart';
import 'package:twilio_chat_plugin_example/global/common_textfield.dart';
import 'package:twilio_chat_plugin_example/global/toast_utility.dart';
import 'package:twilio_chat_plugin_example/providers/get_token_provider.dart';

class HomeScreen extends HookConsumerWidget {
  final String? platformVersion;
  const HomeScreen({super.key, this.platformVersion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController userNameController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Twilio Chat Conversation'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.80,
                height: MediaQuery.of(context).size.height * 0.08,
                child:Image.network(
    'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'),
                
                //  SvgPicture.asset(
                //   "assets/images/twilio_logo_red.svg",
                // ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.16,
              ),
              const Text(
                "🧑 Please Enter User Name",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.visible,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.050,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.82,
                  child: TextInputField(
                    icon: const Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: Icon(
                        Icons.person,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    textCapitalization: TextCapitalization.none,
                    hintText: "",
                    maxLength: 100,
                    textInputFormatter: const [],
                    keyboardType: TextInputType.text,
                    width: MediaQuery.of(context).size.width * 0.90,
                    color: Colors.white,
                    borderColor: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.31),
                        blurRadius: 15,
                        offset: const Offset(-5, 5),
                      )
                    ],
                    controller: userNameController,
                    textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.visible,
                      decoration: TextDecoration.none,
                    ),
                  )),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              CommonTextButtonWidget(
                isIcon: false,
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.82,
                bgColor: Colors.blueGrey,
                borderColor: Colors.white,
                title: "Generate Token and Initialize Client",
                titleFontSize: 14.0,
                titleFontWeight: FontWeight.w600,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (userNameController.text.trim().isNotEmpty) {
                    ref.read(getTokenProvider.notifier).getToken(
                          identity: userNameController.text,
                          context: context,
                        );
                  } else {
                    ToastUtility.showToastAtCenter("Please enter user name.");
                  }
                },
              ),
            ],
          ),
        ));
  }
}
