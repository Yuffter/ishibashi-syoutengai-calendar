import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StoreImageWidget extends StatefulWidget {
  const StoreImageWidget({super.key});

  @override
  State<StoreImageWidget> createState() => _StoreImageWidgetState();
}

class _StoreImageWidgetState extends State<StoreImageWidget> {
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;
  String? _uploadedImageUrl;
  double _uploadProgress = 0.0;
  String _connectionStatus = "未テスト";

  // Firebase Storage接続テスト
  Future<void> _testFirebaseConnection() async {
    setState(() {
      _connectionStatus = "テスト中...";
    });

    try {
      print("=== Firebase接続テスト開始 ===");
      final storageRef = FirebaseStorage.instance.ref();
      final testRef = storageRef.child(
        'test/connection_test_${DateTime.now().millisecondsSinceEpoch}.txt',
      );

      final testData = Uint8List.fromList('connection test'.codeUnits);
      await testRef.putData(testData);

      final downloadUrl = await testRef.getDownloadURL();
      print("テストURL: $downloadUrl");

      await testRef.delete();

      setState(() {
        _connectionStatus = "接続OK ✅";
      });

      print("=== Firebase接続テスト成功 ===");
    } catch (e) {
      setState(() {
        _connectionStatus = "接続エラー ❌";
      });

      print("=== Firebase接続テストエラー ===");
      print("エラー: $e");
      _showErrorDialog("Firebase接続テストに失敗しました。\n$e");
    }
  }

  // 画像を選択する関数
  Future<void> _pickImage() async {
    try {
      final Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();

      if (imageBytes != null) {
        // ファイルサイズチェック（5MB制限）
        const maxSize = 5 * 1024 * 1024; // 5MB
        if (imageBytes.length > maxSize) {
          _showErrorDialog("画像サイズが大きすぎます。\n5MB以下の画像を選択してください。");
          return;
        }

        setState(() {
          _selectedImageBytes = imageBytes;
          _uploadedImageUrl = null; // 新しい画像が選択されたらURLをクリア
        });

        print("画像を選択しました: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB");
      }
    } catch (e) {
      print("画像選択エラー: $e");
      _showErrorDialog("画像の選択に失敗しました。");
    }
  }

  // Firebase Storageに画像をアップロードする関数
  Future<void> _uploadImageToFirebase() async {
    if (_selectedImageBytes == null) {
      _showErrorDialog("画像を選択してください。");
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      print("=== Firebase Storage アップロード開始 ===");
      print("画像サイズ: ${_selectedImageBytes!.length} bytes");

      // Firebase Storageの参照を作成
      final storageRef = FirebaseStorage.instance.ref();
      print("Storage参照作成完了");

      // ファイル名を生成（タイムスタンプ + ランダム文字列）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'images/image_$timestamp.jpg';
      final imageRef = storageRef.child(fileName);
      print("アップロード先: $fileName");

      // メタデータを設定
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': 'flutter_web_app',
          'upload_timestamp': timestamp.toString(),
        },
      );
      print("メタデータ設定完了");

      // アップロードタスクを開始（正しい参照を使用）
      print("アップロードタスク開始...");
      final uploadTask = imageRef.putData(_selectedImageBytes!, metadata);

      // プログレスを監視
      print("プログレス監視開始");
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          print('=== プログレス更新 ===');
          print('状態: ${snapshot.state}');
          print('転送済み: ${snapshot.bytesTransferred} bytes');
          print('総サイズ: ${snapshot.totalBytes} bytes');

          if (snapshot.totalBytes > 0) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            print('進捗: ${(progress * 100).toStringAsFixed(1)}%');
            setState(() {
              _uploadProgress = progress;
            });
          } else {
            print('⚠️ 警告: totalBytesが0です');
          }
        },
        onError: (error) {
          print('🚨 プログレス監視エラー: $error');
          if (error is FirebaseException) {
            print('Firebase エラーコード: ${error.code}');
            print('Firebase エラーメッセージ: ${error.message}');
          }
        },
      );

      // アップロード完了を待機
      final snapshot = await uploadTask;

      // ダウンロードURLを取得
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
        _uploadedImageUrl = downloadUrl;
        _uploadProgress = 0.0;
      });

      print("=== アップロード成功 ===");
      print("ダウンロードURL: $downloadUrl");
      _showSuccessDialog("画像のアップロードが完了しました！");
    } catch (e, stackTrace) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      print("=== アップロードエラー ===");
      print("エラー: $e");
      print("エラータイプ: ${e.runtimeType}");
      print("スタックトレース: $stackTrace");

      String errorMessage = "画像のアップロードに失敗しました。\n\n";

      if (e is FirebaseException) {
        print("Firebase エラーコード: ${e.code}");
        print("Firebase エラーメッセージ: ${e.message}");

        switch (e.code) {
          case 'permission-denied':
          case 'unauthorized':
            errorMessage +=
                "🚨 権限エラー\nFirebase Storageのセキュリティルールを確認してください。\n\nテスト用ルール:\nallow read, write: if true;";
            break;
          case 'storage/object-not-found':
            errorMessage += "🗂️ オブジェクトが見つかりません";
            break;
          case 'storage/bucket-not-found':
            errorMessage += "🪣 ストレージバケットが見つかりません";
            break;
          case 'storage/quota-exceeded':
            errorMessage += "💾 ストレージ容量制限を超えています";
            break;
          case 'storage/retry-limit-exceeded':
            errorMessage += "🔄 リトライ制限を超えました";
            break;
          default:
            errorMessage += "Firebase エラー: ${e.code}\n${e.message}";
        }
      } else {
        errorMessage += "詳細: ${e.toString()}";
      }

      _showErrorDialog(errorMessage);
    }
  }

  // 選択した画像をクリアする関数
  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _uploadedImageUrl = null;
    });
  }

  // エラーダイアログを表示
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 成功ダイアログを表示
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('成功'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 画像情報を取得
  String _getImageInfo() {
    if (_selectedImageBytes == null) return "画像が選択されていません";

    final sizeKB = (_selectedImageBytes!.length / 1024).toStringAsFixed(1);
    final sizeMB = (_selectedImageBytes!.length / (1024 * 1024))
        .toStringAsFixed(2);

    if (_selectedImageBytes!.length > 1024 * 1024) {
      return "画像サイズ: $sizeMB MB";
    } else {
      return "画像サイズ: $sizeKB KB";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // タイトル
            const Text(
              'Firebase Storage 画像アップロード',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 接続状態とテストボタン
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '接続状態: $_connectionStatus',
                    style: const TextStyle(fontSize: 14),
                  ),
                  ElevatedButton(
                    onPressed: _testFirebaseConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: const Text('接続テスト', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 画像表示エリア
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: _selectedImageBytes == null
                  ? const Center(
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
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // 画像情報
            Text(
              _getImageInfo(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // アップロード進捗バー
            if (_isUploading) ...[
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(
                'アップロード中... ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],

            // ボタン群
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('画像を選択'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: (_selectedImageBytes != null && !_isUploading)
                      ? _uploadImageToFirebase
                      : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Firebase にアップロード'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                if (_selectedImageBytes != null)
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _clearSelectedImage,
                    icon: const Icon(Icons.clear),
                    label: const Text('クリア'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),

            // アップロード成功時のURL表示
            if (_uploadedImageUrl != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'アップロード完了',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('ダウンロードURL:'),
                    const SizedBox(height: 4),
                    SelectableText(
                      _uploadedImageUrl!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // URLをクリップボードにコピー
                        Clipboard.setData(
                          ClipboardData(text: _uploadedImageUrl!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('URLをクリップボードにコピーしました')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('URLをコピー'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
