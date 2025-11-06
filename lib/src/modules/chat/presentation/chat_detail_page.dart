import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'model/message_model.dart';
import 'component/widget__messages_list.dart';
import 'component/widget__chat_input.dart';
import 'package:jupyternotebook/generated/colors.gen.dart';

@RoutePage()
class ChatDetailPage extends StatelessWidget {
  final String userName;
  final String userAvatarUrl;

  const ChatDetailPage({
    super.key,
    this.userName = 'xyz',
    this.userAvatarUrl =
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
  });

  @override
  Widget build(BuildContext context) {
    final messages = [
      Message(text: 'Hello', isMe: false),
      Message(text: 'Highfive', isMe: false),
      Message(text: 'hi!!!!!!!!!!', isMe: true),
      Message(text: 'Goodjob!', isMe: true, status: 'Sent'),
      Message(text: 'Are you free tomorrow?', isMe: false),
      Message(text: 'I think I am. What about you?', isMe: true),
      Message(text: 'Great! Let\'s meet at 7pm.', isMe: false),
      Message(text: 'See you then!', isMe: true, status: 'Sent'),
    ];

    return Scaffold(
      backgroundColor: ColorName.softBg,
      appBar: AppBar(
        backgroundColor: ColorName.white,
        surfaceTintColor: ColorName.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorName.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorName.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: WidgetMessagesList(messages: messages)),
          WidgetChatInput(
            onSend: (text) {
              // TODO: handle send logic
            },
          ),
        ],
      ),
    );
  }
}
