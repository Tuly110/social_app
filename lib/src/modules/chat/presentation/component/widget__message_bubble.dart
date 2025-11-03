import 'package:flutter/material.dart';
import '../model/message_model.dart';

class WidgetMessageBubble extends StatelessWidget {
  final Message message;
  static const _mint = Color(0xFFA7C7B7);

  const WidgetMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final align = message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMe ? _mint : Colors.white;
    final textColor = message.isMe ? Colors.white : Colors.black87;
    final border = BorderRadius.circular(16);

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: border.copyWith(
                topRight: message.isMe
                    ? const Radius.circular(4)
                    : border.topRight,
                topLeft: message.isMe
                    ? border.topLeft
                    : const Radius.circular(4),
              ),
              boxShadow: message.isMe
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          if (message.isMe && message.status != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: Text(
                message.status!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
