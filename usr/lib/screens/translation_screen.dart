import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _chineseController = TextEditingController();
  bool _isRecording = false;
  bool _isLoading = false;

  // Supabase client
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _englishController.dispose();
    _chineseController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    // 请求麦克风权限
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // 如果用户拒绝权限，显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要麦克风权限来进行实时翻译')),
      );
      return;
    }

    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // TODO: 在这里开始与阿里云SDK的集成
      // 1. 开始录音
      // 2. 将音频流发送到阿里云
      // 3. 接收实时英文识别结果并更新 _englishController
      // 4. 调用翻译服务将英文翻译成中文并更新 _chineseController
      _englishController.text = "Recognizing speech...";
      _chineseController.text = "翻译中...";
    } else {
      // TODO: 停止录音和翻译流程
      _englishController.text = "Hello, this is a test.";
      _chineseController.text = "你好，这是一个测试。";
    }
  }

  Future<void> _saveTranslation() async {
    final englishText = _englishController.text;
    final chineseText = _chineseController.text;

    if (englishText.isEmpty || chineseText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有内容可以保存')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase.from('translations').insert({
        'english_text': englishText,
        'chinese_text': chineseText,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('翻译已保存!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时翻译'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/history'),
            tooltip: '翻译历史',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _englishController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: '英文原文',
                      labelText: '英文',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _chineseController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: '中文翻译',
                      labelText: '中文',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _saveTranslation,
                child: const Text('保存记录'),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRecording,
        tooltip: _isRecording ? '停止' : '开始',
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
