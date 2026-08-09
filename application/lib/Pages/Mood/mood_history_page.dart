import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Pages/Mood/mood_detail_page.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:application/Widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoodHistoryPage extends StatefulWidget {
  const MoodHistoryPage({super.key});
  @override
  State<MoodHistoryPage> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  String _searchText = '';
  bool _isFilterExpanded = false;
  RangeValues _scoreRange = const RangeValues(1, 10);
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final history = moodController.moodHistory.where((e) {
      final textMatch = _searchText.isEmpty || (e.note?.toLowerCase().contains(_searchText.toLowerCase()) ?? false) || (e.tags?.toLowerCase().contains(_searchText.toLowerCase()) ?? false);
      final scoreMatch = e.value >= _scoreRange.start && e.value <= _scoreRange.end;
      final tagsFilterMatch = _selectedTags.isEmpty || (_selectedTags.every((tag) => e.tags?.contains(tag) ?? false));
      return textMatch && scoreMatch && tagsFilterMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("SYSTEM LOGS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)), centerTitle: false, actions: [IconButton(icon: Icon(Icons.filter_list_rounded, color: _isFilterExpanded ? AppTheme.accent : Colors.white54, size: 20), onPressed: () => setState(() => _isFilterExpanded = !_isFilterExpanded)), const SizedBox(width: 12)]),
      body: Column(children: [
        const SizedBox(height: 100),
        Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), child: TextField(onChanged: (v) => setState(() => _searchText = v), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15), decoration: const InputDecoration(hintText: "Search neural reflections...", prefixIcon: Icon(Icons.search_rounded, color: Colors.white30, size: 18)))),
        if (_isFilterExpanded) _buildFilterPanel(context, moodController),
        Expanded(child: RefreshIndicator(onRefresh: () async { final user = context.read<LoginController>().currentUser; if (user != null) await moodController.fetchMoodHistory(user.id); }, color: AppTheme.accent, child: history.isEmpty ? _buildEmptyState(context) : ListView.builder(padding: const EdgeInsets.fromLTRB(24, 8, 24, 160), physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), itemCount: history.length, itemBuilder: (context, index) => FadeInSlide(duration: 400, delay: (index * 20).clamp(0, 400), direction: const Offset(15, 0), child: Padding(padding: const EdgeInsets.only(bottom: 16), child: _JournalEntryTile(entry: history[index])))))),
      ]),
    );
  }

  Widget _buildFilterPanel(BuildContext context, MoodController controller) {
    return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: GlassCard(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("AMPLITUDE RANGE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.white38)), Text("${_scoreRange.start.round()} - ${_scoreRange.end.round()}", style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900))]),
      RangeSlider(values: _scoreRange, min: 1, max: 10, divisions: 9, activeColor: AppTheme.accent, mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click), onChanged: (v) => setState(() => _scoreRange = v)),
      const SizedBox(height: 16), const Text("FILTER BY PARAMETER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.white38)), const SizedBox(height: 12),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: controller.availableTags.map((tag) {
        final isSelected = _selectedTags.contains(tag.label);
        return Padding(padding: const EdgeInsets.only(right: 12), child: FilterChip(label: Text(tag.label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)), selected: isSelected, onSelected: (selected) => setState(() { if (selected) _selectedTags.add(tag.label); else _selectedTags.remove(tag.label); }), labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.w700), selectedColor: AppTheme.accent.withValues(alpha: 0.2), checkmarkColor: AppTheme.accent, backgroundColor: Colors.white.withValues(alpha: 0.03), side: BorderSide(color: isSelected ? AppTheme.accent.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08)), mouseCursor: SystemMouseCursors.click, shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))));
      }).toList()))
    ])));
  }

  Widget _buildEmptyState(BuildContext context) => SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: SizedBox(height: MediaQuery.of(context).size.height * 0.5, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.storage_rounded, size: 64, color: Colors.white.withValues(alpha: 0.12)), const SizedBox(height: 24), const Text("SYSTEM DATABASE EMPTY", style: TextStyle(color: Colors.white30, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2))]))));
}

class _JournalEntryTile extends StatelessWidget {
  final dynamic entry;
  const _JournalEntryTile({required this.entry});
  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getSmoothColor(entry.value.toDouble());
    return HoverEffect(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MoodDetailPage(entry: entry))), child: GlassCard(padding: const EdgeInsets.all(18), child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1)), child: Center(child: Icon(AppIcons.getMoodIcon(entry.value), size: 22, color: statusColor))),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(DateFormat('dd/MM/yyyy').format(entry.createdAt).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 0.5)), const Spacer(), Text(DateFormat.Hm().format(entry.createdAt), style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900))]), const SizedBox(height: 6), Text(entry.note ?? "Recorded a level ${entry.value} state.", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: entry.note != null ? Colors.white70 : Colors.white24, fontSize: 13, fontWeight: FontWeight.w500))])),
      const SizedBox(width: 12), const Icon(Icons.chevron_right_rounded, color: Colors.white10, size: 18),
    ])));
  }
}
