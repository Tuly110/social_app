import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../common/utils/getit_utils.dart';
import '../app/app_router.dart';
import '../newpost/presentation/create_post_page.dart'
    show PostVisibility, PostVisibilityX; // dùng lại enum visibility
import 'data/api/chatbot_api.dart';
import 'data/models/chatbot_message_model.dart';
import 'data/presentation/cubit/chatbot_cubit.dart';
import 'data/presentation/cubit/chatbot_state.dart';
import '../newpost/data/models/post_model.dart';
import '../newpost/presentation/cubit/post_cubit.dart';

@RoutePage()
class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? 'guest';

    return BlocProvider(
      create: (_) => ChatbotCubit(
        api: getIt<ChatbotApi>(),
        userId: currentUserId,
      ),
      child: const _ChatbotView(),
    );
  }
}

class _ChatbotView extends StatefulWidget {
  const _ChatbotView();

  @override
  State<_ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<_ChatbotView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _dioDetail(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      final detail = (data is Map) ? data['detail'] : null;
      if (detail is String && detail.trim().isNotEmpty) return detail;
      return 'Lỗi mạng / server (${e.response?.statusCode ?? 'unknown'}).';
    }
    return e.toString();
  }

  void _onSend() {
    final text = _controller.text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    context.read<ChatbotCubit>().sendMessage(trimmed);
    _controller.clear();
  }

  /// 👉 Gửi ảnh cho chatbot để tạo phiên bản chibi (chỉ hiển thị trong chat)
  Future<void> _pickImageAndSendAsChibi() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile == null) return;

    final file = File(xFile.path);
    await context.read<ChatbotCubit>().sendImageAsChibi(file);
  }

  /// 👉 Quick Action: mở FollowersPage (followers của current user)
  void _openFollowers() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    context.router.push(FollowersRoute(userId: currentUserId));
  }

  /// 👉 Quick Action: mở CreatePostPage (đăng tay)
  void _openCreatePost() {
    context.router.push(const CreatePostRoute());
  }

  /// 👉 Quick Action: AI viết caption (chỉ chat, chưa auto-post)
  Future<void> _openAiCaptionSheet() async {
    final controller = TextEditingController();

    final desc = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Text(
                    'AI gợi ý caption',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText:
                          'Mô tả ngắn về bài đăng (ví dụ: đi chơi cuối tuần với bạn bè, quán cà phê chill...)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) {
                            Navigator.of(ctx).pop();
                          } else {
                            Navigator.of(ctx).pop(text);
                          }
                        },
                        child: const Text('Gợi ý caption'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (desc == null || desc.trim().isEmpty) return;

    final prompt =
        'Hãy giúp tôi viết 1 caption ngắn cho bài đăng mạng xã hội City_Life '
        'với mô tả: "$desc". '
        'Chỉ trả về đúng nội dung caption, không giải thích thêm.';

    context.read<ChatbotCubit>().sendMessage(prompt);
  }

  /// 👉 Quick Action: AI viết caption + TỰ ĐĂNG (có thể kèm ảnh)
  Future<void> _openAiCaptionAndPostSheet() async {
    final descController = TextEditingController();
    PostVisibility tempVisibility = PostVisibility.public;
    File? selectedImage;

    final result = await showModalBottomSheet<_AiPostData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const Text(
                        'AI viết caption + đăng luôn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Mô tả ngắn về bài đăng (ví dụ: đi chơi cuối tuần với bạn bè, kỷ niệm, tốt nghiệp...)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chế độ hiển thị',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Public'),
                            selected: tempVisibility == PostVisibility.public,
                            onSelected: (_) {
                              setModalState(() {
                                tempVisibility = PostVisibility.public;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Private'),
                            selected: tempVisibility == PostVisibility.private,
                            onSelected: (_) {
                              setModalState(() {
                                tempVisibility = PostVisibility.private;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ảnh đính kèm (tuỳ chọn)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final xFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (xFile == null) return;
                              setModalState(() {
                                selectedImage = File(xFile.path);
                              });
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh'),
                          ),
                          const SizedBox(width: 12),
                          if (selectedImage != null)
                            const Text(
                              'Đã chọn 1 ảnh',
                              style: TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final desc = descController.text.trim();
                              if (desc.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Bạn chưa nhập mô tả để AI viết caption.')),
                                );
                                return;
                              }
                              Navigator.of(ctx).pop(
                                _AiPostData(
                                  description: desc,
                                  visibility: tempVisibility,
                                  imageFile: selectedImage,
                                ),
                              );
                            },
                            child: const Text('AI đăng giúp tôi'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result == null) return;

    await _createPostWithAi(
      description: result.description,
      visibility: result.visibility,
      imageFile: result.imageFile,
    );
  }

  /// Upload ảnh lên Supabase Storage, trả về public URL
  Future<String> _uploadImageToSupabase(File imageFile) async {
    final supa = Supabase.instance.client;
    final userId = supa.auth.currentUser?.id ?? 'guest';

    final ext = imageFile.path.split('.').last;
    final filePath =
        'chatbot-posts/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    final bytes = await imageFile.readAsBytes();

    // ⚠️ Đảm bảo bạn có bucket "post-images" (hoặc đổi tên bucket cho đúng)
    final bucket = supa.storage.from('post-images');

    await bucket.uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(
        upsert: false,
      ),
    );

    final publicUrl = bucket.getPublicUrl(filePath);
    return publicUrl;
  }

  /// Gọi backend /chatbot/auto-create-post để AI viết caption + tạo post (có thể kèm ảnh)
  Future<void> _createPostWithAi({
    required String description,
    required PostVisibility visibility,
    File? imageFile,
  }) async {
    final supa = Supabase.instance.client;
    final session = supa.auth.currentSession;
    final accessToken = session?.accessToken;
    debugPrint('accessToken null? ${accessToken == null}');

    if (accessToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bạn cần đăng nhập để sử dụng tính năng này.')),
      );
      return;
    }

    final dio = getIt<Dio>();
    final cubit = context.read<ChatbotCubit>();

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImageToSupabase(imageFile);
      }

      final res = await dio.post(
        '/chatbot/auto-create-post',
        data: {
          'prompt': description,
          'visibility': visibility.backendValue, // 'public' | 'private'
          'image_url': imageUrl,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = (res.data as Map).cast<String, dynamic>();
      final caption = data['caption'] as String?;

      // ✅ QUAN TRỌNG: Lấy post trả về và add lên PostCubit để hiện ngay ở Home
      final postJson = data['post'] as Map<String, dynamic>?;
      if (postJson != null) {
        final postEntity = PostModel.fromJson(postJson).toEntity();
        // add lên đầu feed (giống createPost thường)
        if (mounted) {
          try {
            context.read<PostCubit>().addPostOnTop(postEntity);
          } catch (_) {
            // nếu PostCubit không có trong context thì bạn có thể dùng getIt<PostCubit>()
            // getIt<PostCubit>().addPostOnTop(postEntity);
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI đã đăng bài cho bạn!'),
          backgroundColor: Colors.green,
        ),
      );

      if (caption != null && caption.trim().isNotEmpty) {
        cubit.addSystemMessage(
            '✅ Mình vừa đăng giúp bạn với caption:\n"$caption"');
      } else {
        cubit.addSystemMessage('✅ Mình vừa đăng giúp bạn một bài mới.');
      }
    } catch (e) {
      final msg = _dioDetail(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );

      cubit.addSystemMessage('❌ Không thể đăng bài: $msg');
    }
  }

  /// 👉 Quick Action: AI viết caption + HẸN GIỜ ĐĂNG (có thể kèm ảnh)
  Future<void> _openAiSchedulePostSheet() async {
    final descController = TextEditingController();
    PostVisibility tempVisibility = PostVisibility.public;
    DateTime? scheduledAt;
    File? selectedImage;

    final result = await showModalBottomSheet<_AiSchedulePostData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const Text(
                        'AI viết caption + hẹn giờ đăng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Mô tả ngắn về bài đăng (ví dụ: đi chơi cuối tuần, kỷ niệm...)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chế độ hiển thị',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Public'),
                            selected: tempVisibility == PostVisibility.public,
                            onSelected: (_) {
                              setModalState(() {
                                tempVisibility = PostVisibility.public;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Private'),
                            selected: tempVisibility == PostVisibility.private,
                            onSelected: (_) {
                              setModalState(() {
                                tempVisibility = PostVisibility.private;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ảnh đính kèm (tuỳ chọn)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final xFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (xFile == null) return;
                              setModalState(() {
                                selectedImage = File(xFile.path);
                              });
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh'),
                          ),
                          const SizedBox(width: 12),
                          if (selectedImage != null)
                            const Text(
                              'Đã chọn 1 ảnh',
                              style: TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Thời gian đăng',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              scheduledAt != null
                                  ? '${scheduledAt!.day.toString().padLeft(2, '0')}/'
                                      '${scheduledAt!.month.toString().padLeft(2, '0')}/'
                                      '${scheduledAt!.year} '
                                      '${scheduledAt!.hour.toString().padLeft(2, '0')}:'
                                      '${scheduledAt!.minute.toString().padLeft(2, '0')}'
                                  : 'Chưa chọn thời gian',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final date = await showDatePicker(
                                context: ctx,
                                initialDate:
                                    now.add(const Duration(minutes: 10)),
                                firstDate: now,
                                lastDate: now.add(const Duration(days: 30)),
                              );
                              if (date == null) return;

                              final time = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay(
                                  hour: now.hour,
                                  minute: (now.minute + 10) % 60,
                                ),
                              );
                              if (time == null) return;

                              final dt = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );

                              setModalState(() {
                                scheduledAt = dt;
                              });
                            },
                            child: const Text('Chọn thời gian'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final desc = descController.text.trim();
                              if (desc.isEmpty || scheduledAt == null) {
                                Navigator.of(ctx).pop();
                              } else {
                                Navigator.of(ctx).pop(
                                  _AiSchedulePostData(
                                    description: desc,
                                    visibility: tempVisibility,
                                    scheduledAt: scheduledAt!,
                                    imageFile: selectedImage,
                                  ),
                                );
                              }
                            },
                            child: const Text('Hẹn giờ đăng'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result == null) return;

    await _schedulePostWithAi(
      description: result.description,
      visibility: result.visibility,
      scheduledAt: result.scheduledAt,
      imageFile: result.imageFile,
    );
  }

  Future<void> _schedulePostWithAi({
    required String description,
    required PostVisibility visibility,
    required DateTime scheduledAt,
    File? imageFile,
  }) async {
    final supa = Supabase.instance.client;
    final accessToken = supa.auth.currentSession?.accessToken;

    if (accessToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bạn cần đăng nhập để sử dụng tính năng này.')),
      );
      return;
    }

    final dio = getIt<Dio>();
    final cubit = context.read<ChatbotCubit>();

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImageToSupabase(imageFile);
      }

      // ✅ gửi theo UTC để backend dễ xử lý, tránh lệch giờ
      final scheduledUtc = scheduledAt.toUtc().toIso8601String();

      final payload = {
        'prompt': description,
        'visibility': visibility.backendValue, // 'public' | 'private'
        'scheduled_at': scheduledUtc,
        'image_url': imageUrl,
      };

      debugPrint('[schedule-post] payload=$payload');

      final res = await dio.post(
        '/chatbot/schedule-post',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      debugPrint('[schedule-post] status=${res.statusCode} data=${res.data}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã hẹn giờ đăng bài với AI'),
          backgroundColor: Colors.green,
        ),
      );

      cubit.addSystemMessage(
        '✅ Mình đã hẹn giờ đăng bài.\n'
        '🕒 Thời gian (local): ${scheduledAt.toLocal()}\n'
        '🌍 Thời gian (UTC): $scheduledUtc\n'
        '📝 Mô tả: "$description"',
      );
    } catch (e) {
      final msg = _dioDetail(e);
      debugPrint('[schedule-post] ERROR: $msg');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
      cubit.addSystemMessage('❌ Không thể hẹn giờ đăng: $msg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatbotCubit, ChatbotState>(
      listenWhen: (prev, curr) => prev.messages.length != curr.messages.length,
      listener: (_, __) => _scrollToBottom(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CityLife Assistant'),
          backgroundColor: ColorName.mint,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // 🟢 QUICK ACTIONS
            _QuickActions(
              onOpenFollowers: _openFollowers,
              onOpenCreatePost: _openCreatePost,
              onOpenAiCaption: _openAiCaptionSheet,
              onOpenAiCaptionAndPost: _openAiCaptionAndPostSheet,
              onOpenAiSchedulePost: _openAiSchedulePostSheet,
            ),

            // 🧵 LIST CHAT
            Expanded(
              child: BlocBuilder<ChatbotCubit, ChatbotState>(
                builder: (context, state) {
                  if (state.messages.isEmpty && !state.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Xin chào 👋\n'
                          'Mình là CityLife Assistant.\n'
                          'Bạn có thể chọn một trong các option phía trên\n'
                          'hoặc chat trực tiếp với mình nhé!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (state.isLoading && index == state.messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'CityLife Assistant đang trả lời...',
                            ),
                          ),
                        );
                      }

                      final msg = state.messages[index];
                      final isUser = msg.isUser;

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isUser ? ColorName.mint : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(
                                isUser ? 16 : 0,
                              ),
                              bottomRight: Radius.circular(
                                isUser ? 0 : 16,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (msg.imageUrl != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    msg.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Ô input
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImageAndSendAsChibi,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: 'Hỏi CityLife Assistant...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _onSend(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _onSend,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Data tạm để truyền ra khỏi bottom sheet
class _AiPostData {
  final String description;
  final PostVisibility visibility;
  final File? imageFile;

  _AiPostData({
    required this.description,
    required this.visibility,
    required this.imageFile,
  });
}

class _AiSchedulePostData {
  final String description;
  final PostVisibility visibility;
  final DateTime scheduledAt;
  final File? imageFile;

  _AiSchedulePostData({
    required this.description,
    required this.visibility,
    required this.scheduledAt,
    required this.imageFile,
  });
}

/// Widget thanh quick actions phía trên
class _QuickActions extends StatelessWidget {
  final VoidCallback onOpenFollowers;
  final VoidCallback onOpenCreatePost;
  final VoidCallback onOpenAiCaption;
  final VoidCallback onOpenAiCaptionAndPost;
  final VoidCallback onOpenAiSchedulePost;

  const _QuickActions({
    required this.onOpenFollowers,
    required this.onOpenCreatePost,
    required this.onOpenAiCaption,
    required this.onOpenAiCaptionAndPost,
    required this.onOpenAiSchedulePost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorName.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickActionChip(
              icon: Icons.group,
              label: 'Followers của tôi',
              onTap: onOpenFollowers,
            ),
            const SizedBox(width: 8),
            _QuickActionChip(
              icon: Icons.post_add,
              label: 'Đăng bài mới',
              onTap: onOpenCreatePost,
            ),
            const SizedBox(width: 8),
            _QuickActionChip(
              icon: Icons.lightbulb_outline,
              label: 'AI viết caption',
              onTap: onOpenAiCaption,
            ),
            const SizedBox(width: 8),
            _QuickActionChip(
              icon: Icons.auto_awesome,
              label: 'AI viết + đăng luôn',
              onTap: onOpenAiCaptionAndPost,
            ),
            const SizedBox(width: 8),
            _QuickActionChip(
              icon: Icons.schedule,
              label: 'AI viết + hẹn giờ',
              onTap: onOpenAiSchedulePost,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
