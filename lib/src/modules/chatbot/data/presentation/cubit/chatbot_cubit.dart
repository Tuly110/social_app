// lib/src/modules/chatbot/presentation/cubit/chatbot_cubit.dart

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/api/chatbot_api.dart';
import '../../../data/models/chatbot_message_model.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatbotApi _api;
  final String userId;
  final _uuid = const Uuid();

  ChatbotCubit({
    required ChatbotApi api,
    required this.userId,
  })  : _api = api,
        super(const ChatbotState());

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatbotMessageModel(
      id: _uuid.v4(),
      text: trimmed,
      isUser: true,
      createdAt: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMsg];

    emit(state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      error: null,
    ));

    try {
      final replyText = await _api.sendMessage(
        message: trimmed,
        history: updatedMessages,
      );

      final botMsg = ChatbotMessageModel(
        id: _uuid.v4(),
        text: replyText,
        isUser: false,
        createdAt: DateTime.now(),
      );

      final newMessages = [...updatedMessages, botMsg];

      emit(state.copyWith(
        messages: newMessages,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: null));
    }
  }

  /// Dùng để push message hệ thống / bot thủ công từ ChatbotPage
  void addSystemMessage(String text) {
    final sysMsg = ChatbotMessageModel(
      id: _uuid.v4(),
      text: text,
      isUser: false,
      createdAt: DateTime.now(),
    );

    final newMessages = [...state.messages, sysMsg];

    emit(
      state.copyWith(
        messages: newMessages,
      ),
    );
  }

  /// Gửi ảnh để backend xử lý sang style chibi
  Future<void> sendImageAsChibi(File imageFile) async {
    if (state.isLoading) return;

    final now = DateTime.now();

    final userMsg = ChatbotMessageModel(
      id: _uuid.v4(),
      text: 'Ảnh bạn vừa gửi',
      isUser: true,
      createdAt: now,
    );

    final history = [...state.messages, userMsg];

    emit(state.copyWith(
      messages: history,
      isLoading: true,
    ));

    try {
      final chibiUrl = await _api.stylizeImageToChibi(imageFile: imageFile);

      final botMsg = ChatbotMessageModel(
        id: _uuid.v4(),
        text: 'Đây là phiên bản chibi của bạn nè ✨',
        isUser: false,
        createdAt: DateTime.now(),
        imageUrl: chibiUrl,
      );

      emit(state.copyWith(
        messages: [...history, botMsg],
        isLoading: false,
      ));
    } catch (e) {
      addSystemMessage('Xin lỗi, mình không tạo được ảnh chibi lúc này 😢');
      emit(state.copyWith(isLoading: false));
    }
  }
}
