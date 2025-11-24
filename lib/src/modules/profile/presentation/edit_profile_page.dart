import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/src/core/data/api/profile_api.dart';
import 'package:social_app/src/core/data/api/profile_api_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel? initialProfile;

  const EditProfilePage({
    super.key,
    this.initialProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileApi _profileApi;
  final _usernameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _bioController = TextEditingController();

  final _picker = ImagePicker();
  bool _saving = false;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _profileApi = ProfileApi(baseUrl: 'http://10.0.2.2:8001');

    final p = widget.initialProfile;
    if (p != null) {
      _usernameController.text = p.username;
      _avatarUrlController.text = p.avatarUrl ?? '';
      _bioController.text = p.bio ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _uploadingImage = true);

      // Đọc bytes ảnh
      final bytes = await picked.readAsBytes();

      // Lấy user hiện tại
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy user hiện tại')),
        );
        setState(() => _uploadingImage = false);
        return;
      }

      // Đường dẫn file trong bucket (avatar/<userId>_timestamp.jpg)
      final filePath =
          'avatars/${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload lên Supabase Storage (bucket tên "avatars" – bạn đổi nếu khác)
      final storage = Supabase.instance.client.storage;
      await storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Lấy public URL
      final publicUrl = storage.from('avatars').getPublicUrl(filePath);

      setState(() {
        _avatarUrlController.text = publicUrl;
        _uploadingImage = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload ảnh thất bại: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    final username = _usernameController.text.trim();
    final avatarUrl = _avatarUrlController.text.trim();
    final bio = _bioController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username không được để trống')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final updated = await _profileApi.updateMyProfile(
        ProfileUpdateRequest(
          username: username,
          avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
          bio: bio.isEmpty ? null : bio,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop<ProfileModel>(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.initialProfile;

    final currentAvatar = _avatarUrlController.text.isNotEmpty
        ? _avatarUrlController.text
        : p?.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          IconButton(
            onPressed: (_saving || _uploadingImage) ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      currentAvatar != null && currentAvatar.isNotEmpty
                          ? NetworkImage(currentAvatar)
                          : null,
                  child: (currentAvatar == null || currentAvatar.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: InkWell(
                    onTap: _uploadingImage ? null : _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _uploadingImage
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nếu bạn vẫn muốn user có thể tự dán URL thủ công thì giữ lại.
          // Nếu không cần, có thể xoá TextField này.
          TextField(
            controller: _avatarUrlController,
            decoration: const InputDecoration(
              labelText: 'Avatar URL (tuỳ chọn)',
              hintText: 'Có thể dán link ảnh nếu muốn',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Bio',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_saving || _uploadingImage) ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Lưu thay đổi'),
            ),
          ),
        ],
      ),
    );
  }
}
