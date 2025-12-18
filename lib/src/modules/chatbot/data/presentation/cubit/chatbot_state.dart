// lib/src/modules/chatbot/presentation/cubit/chatbot_state.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/chatbot_message_model.dart';

class ChatbotState extends Equatable {
  final List<ChatbotMessageModel> messages;
  final bool isLoading;
  final String? error;

  const ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatbotState copyWith({
    List<ChatbotMessageModel>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error];
}
