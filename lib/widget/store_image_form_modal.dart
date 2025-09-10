import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/model/store_image.dart';
import 'package:hackathon/view_model/store_image.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class StoreImageFormModal extends ConsumerStatefulWidget {
  final StoreImageModel? existingImage; // 編集の場合は既存のデータ
  final String? presetImageUrl; // 事前に設定された画像URL

  const StoreImageFormModal({
    super.key,
    this.existingImage,
    this.presetImageUrl,
  });

  @override
  ConsumerState<StoreImageFormModal> createState() =>
      _StoreImageFormModalState();
}

class _StoreImageFormModalState extends ConsumerState<StoreImageFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  // 画像アップロード関連の状態
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // 既存データがある場合は初期値を設定
    if (widget.existingImage != null) {
      final existing = widget.existingImage!;
      _storeNameController.text = existing.storeName;
      _titleController.text = existing.title;
      _descriptionController.text = existing.description;
      _selectedDate = existing.eventDate;
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 画像を選択する関数
  Future<void> _pickImage() async {
    try {
      final Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();

      if (imageBytes != null) {
        // ファイルサイズチェック（5MB制限）
        const maxSize = 5 * 1024 * 1024; // 5MB
        if (imageBytes.length > maxSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('画像サイズが大きすぎます。5MB以下の画像を選択してください。')),
          );
          return;
        }

        setState(() {
          _selectedImageBytes = imageBytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('画像の選択に失敗しました。')));
    }
  }

  // 日付選択ダイアログ
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // フォーム送信（画像アップロード + Firestore保存）
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 新しい画像が選択されていない場合（編集時で画像変更なし）
      if (_selectedImageBytes == null && widget.existingImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('画像を選択してください。')));
        return;
      }

      setState(() {
        _isUploading = true;
      });
      try {
        String imageUrl;

        // 新しい画像が選択されている場合はアップロード
        if (_selectedImageBytes != null) {
          // Firebase Storageに画像をアップロード
          final storageRef = FirebaseStorage.instance.ref();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'images/image_$timestamp.jpg';
          final imageRef = storageRef.child(fileName);

          // メタデータを設定
          final metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploaded_by': 'flutter_web_app',
              'upload_timestamp': timestamp.toString(),
            },
          );

          // アップロードタスクを開始
          final uploadTask = imageRef.putData(_selectedImageBytes!, metadata);

          // アップロード完了を待機
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          // 既存の画像URLを使用
          imageUrl = widget.existingImage!.imageUrl;
        }

        // Firestoreに保存
        final firestore = FirebaseFirestore.instance;
        final eventData = {
          'shop_name': _storeNameController.text.trim(),
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'date': Timestamp.fromDate(_selectedDate),
          'url': imageUrl,
        };

        if (widget.existingImage != null) {
          // 更新
          await firestore
              .collection('events')
              .doc(widget.existingImage!.id)
              .update(eventData);
        } else {
          // 新規追加
          await firestore.collection('events').add(eventData);
        }

        // ローカル状態も更新
        final storeImage = StoreImageModel(
          id:
              widget.existingImage?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: imageUrl,
          storeName: _storeNameController.text.trim(),
          eventDate: _selectedDate,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        final viewModel = ref.read(storeImageViewModelProvider.notifier);
        if (widget.existingImage != null) {
          viewModel.updateStoreImage(storeImage.id, storeImage);
        } else {
          viewModel.addStoreImage(storeImage);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingImage != null ? 'イベント情報を更新しました' : 'イベント情報を追加しました',
            ),
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存に失敗しました: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ハンドル
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // タイトル
          Text(
            widget.existingImage != null ? '店舗情報を編集' : 'イベントを登録',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // フォーム
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // 画像選択・アップロード部分
                  Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      color: Colors.grey[50],
                    ),
                    child: _selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : widget.existingImage != null &&
                              widget.existingImage!.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.existingImage!.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '画像を選択してください',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  // 画像選択・アップロードボタン
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('画像を選択'),
                  ),

                  const SizedBox(height: 20),

                  // 店舗名
                  TextFormField(
                    controller: _storeNameController,
                    decoration: const InputDecoration(
                      labelText: '店舗名 *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '店舗名を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 日付選択
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            'イベント日付: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // タイトル
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'タイトル *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'タイトルを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 概要
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '概要 *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '概要を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ボタン
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.existingImage != null ? '更新' : '追加'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// モーダルを表示するヘルパー関数
Future<void> showStoreImageFormModal(
  BuildContext context, {
  StoreImageModel? existingImage,
  String? presetImageUrl,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: 800,
        child: StoreImageFormModal(
          existingImage: existingImage,
          presetImageUrl: presetImageUrl,
        ),
      );
    },
  );
}
