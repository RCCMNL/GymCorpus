import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({required this.data, super.key});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final date = data['date'] as String? ?? '';
    final tag = data['tag'] as String? ?? '';
    final readMin = data['readMin'] as int? ?? 5;
    final colorVal = data['color'] as int? ?? 0xFFFDE047;
    final color = Color(colorVal);

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag + meta
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(tag, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: 0.5)),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_outlined, size: 12, color: t.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(date, style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline, fontSize: 10)),
                  const SizedBox(width: 12),
                  Icon(Icons.timer_outlined, size: 12, color: t.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text('$readMin min lettura', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline, fontSize: 10)),
                ]),
                const SizedBox(height: 20),
                // Title
                Text(title, style: t.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Lexend', height: 1.2)),
                const SizedBox(height: 8),
                // Divider accent
                Container(
                  width: 60, height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.3)]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 28),
                // Body paragraphs
                ...body.split('\n\n').map((paragraph) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: paragraph.startsWith('- ') 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: paragraph.split('\n').map((line) {
                          if (line.startsWith('- ')) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 7),
                                  width: 6, height: 6,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(line.substring(2), style: t.textTheme.bodyMedium?.copyWith(height: 1.6))),
                              ]),
                            );
                          }
                          return Text(line, style: t.textTheme.bodyMedium?.copyWith(height: 1.6));
                        }).toList(),
                      )
                    : Text(paragraph, style: t.textTheme.bodyMedium?.copyWith(height: 1.6)),
                )),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
