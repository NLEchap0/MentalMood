import 'package:application/app/navigation/app_navigator.dart';
import 'package:application/app/pages/journal/add_mood_page.dart';
import 'package:application/app/pages/journal/mood_detail_page.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_icons.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/app/theme/animations.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/empty_state.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/mood_labels.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
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

  List<MoodEntry> _filter(List<MoodEntry> history) {
    return history.where((e) {
      final query = _searchText.toLowerCase();
      final textMatch =
          query.isEmpty ||
          (e.note?.toLowerCase().contains(query) ?? false) ||
          e.tags.any((t) => t.toLowerCase().contains(query));
      final scoreMatch =
          e.value >= _scoreRange.start && e.value <= _scoreRange.end;
      final tagsMatch =
          _selectedTags.isEmpty ||
          _selectedTags.every((tag) => e.tags.contains(tag));
      return textMatch && scoreMatch && tagsMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final history = _filter(moodController.moodHistory);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(
              _isFilterExpanded
                  ? Icons.filter_alt_rounded
                  : Icons.filter_list_rounded,
              color: _isFilterExpanded
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
            onPressed: () =>
                setState(() => _isFilterExpanded = !_isFilterExpanded),
            tooltip: 'Filter entries',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: TextField(
                onChanged: (v) => setState(() => _searchText = v),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search entries...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textFaint,
                    size: 20,
                  ),
                ),
              ),
            ),
            if (_isFilterExpanded) _buildFilterPanel(context, moodController),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final user = context.read<AuthController>().currentUser;
                  if (user != null) {
                    await moodController.fetchMoodHistory(user.id);
                  }
                },
                color: AppColors.accent,
                backgroundColor: AppColors.surface,
                child: history.isEmpty
                    ? _buildEmptyState(context, moodController)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 160),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: history.length,
                        itemBuilder: (context, index) => FadeInSlide(
                          duration: const Duration(milliseconds: 400),
                          delay: (index * 20).clamp(0, 400),
                          direction: const Offset(15, 0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _JournalEntryTile(entry: history[index]),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, MoodController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MOOD LEVEL',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_scoreRange.start.round()} - ${_scoreRange.end.round()}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _scoreRange,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => setState(() => _scoreRange = v),
            ),
            const SizedBox(height: 8),
            const Text(
              'TAGS',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag.label);
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(
                        tag.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _selectedTags.add(tag.label);
                        } else {
                          _selectedTags.remove(tag.label);
                        }
                      }),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MoodController controller) {
    final hasAny = controller.moodHistory.isNotEmpty;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: EmptyState(
          icon: hasAny
              ? Icons.filter_alt_off_outlined
              : Icons.auto_stories_outlined,
          title: hasAny ? 'No matching entries' : 'Your journal is empty',
          message: hasAny
              ? 'Try adjusting the search or filters.'
              : 'Log your first check-in to start your journey.',
          actionLabel: hasAny ? null : 'Add Check-in',
          onAction: hasAny
              ? null
              : () => AppNavigator.push(context, const AddMoodPage()),
        ),
      ),
    );
  }
}

class _JournalEntryTile extends StatelessWidget {
  final MoodEntry entry;
  const _JournalEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getSmoothColor(entry.value.toDouble());
    return HoverEffect(
      onTap: () => AppNavigator.push(context, MoodDetailPage(entry: entry)),
      child: GlassCard(
        size: GlassCardSize.sm,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
              ),
              child: Center(
                child: Icon(
                  AppIcons.getMoodIcon(entry.value),
                  size: 22,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(entry.createdAt).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat.Hm().format(entry.createdAt),
                        style: const TextStyle(
                          color: AppColors.textFaint,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entry.hasNote
                        ? entry.note!
                        : '${moodLabelFor(entry.value)} · level ${entry.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: entry.hasNote
                          ? AppColors.textSecondary
                          : AppColors.textFaint,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textFaint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
