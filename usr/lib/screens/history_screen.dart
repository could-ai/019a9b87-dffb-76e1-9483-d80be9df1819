import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<Map<String, dynamic>>> _translationsFuture;

  @override
  void initState() {
    super.initState();
    _translationsFuture = _fetchTranslations();
  }

  Future<List<Map<String, dynamic>>> _fetchTranslations() async {
    final response = await Supabase.instance.client
        .from('translations')
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('翻译历史'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _translationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('没有历史记录'));
          }

          final translations = snapshot.data!;

          return ListView.builder(
            itemCount: translations.length,
            itemBuilder: (context, index) {
              final translation = translations[index];
              final createdAt = DateTime.parse(translation['created_at']);
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt.toLocal());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(translation['english_text']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(translation['chinese_text']),
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
