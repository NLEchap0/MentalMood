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
import 'package:application/app/widgets/refresh_view.dart';
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
  State<MoodHistoryPage> createState() => MoodHistoryPageState();
}

class MoodHistoryPageState extends State<MoodHistoryPage> {
  String _searchText = '';
  bool _isFilterExpanded = false;
  RangeValues _scoreRange = const RangeValues(1, 10);
  final List<String> _selectedTags = [];
  
  int _currentPage = 0;
  static const int _itemsPerPage = 20;

  bool get _isFiltered =>
      _searchText.isNotEmpty ||
      _scoreRange.start != 1 ||
      _scoreRange.end != 10 ||
      _selectedTags.isNotEmpty;

  void resetFilters() {
    setState(() {
      _searchText = '';
      _scoreRange = const RangeValues(1, 10);
      _selectedTags.clear();
      _currentPage = 0;
      _isFilterExpanded = false; // Also close the menu
    });
  }

  @override
  void initState() {
    super.initState();
    // No need to call resetFilters here since it's already the default state
  }

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
    final allFiltered = _filter(moodController.moodHistory);
    
    final totalPages = (allFiltered.length / _itemsPerPage).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }
    
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, allFiltered.length);
    final historyPage = allFiltered.isEmpty ? <MoodEntry>[] : allFiltered.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          children: [
            // FIXED HEADER (Consistent with Home)
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildJournalHeader(),
                        const SizedBox(height: 16),
                        _buildSearchRow(),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _isFilterExpanded
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _buildFilterPanel(context, moodController),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // SCROLLABLE CONTENT (Full width for scrollbar edge alignment)
            Expanded(
              child: RefreshView(
                onRefresh: () async {
                  final user = context.read<AuthController>().currentUser;
                  if (user != null) {
                    await moodController.fetchMoodHistory(user.id);
                  }
                },
                child: allFiltered.isEmpty
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: _buildEmptyState(context, moodController),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 160),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        itemCount: historyPage.length + (totalPages > 1 ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Pagination row as last item
                          if (index == historyPage.length) {
                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: _buildPagination(totalPages),
                              ),
                            );
                          }

                          final entry = historyPage[index];

                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: FadeInSlide(
                                duration: const Duration(milliseconds: 250),
                                delay: (index * 5).clamp(0, 150),
                                direction: const Offset(10, 0),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _JournalEntryTile(entry: entry),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageBtn(
            icon: Icons.chevron_left_rounded,
            enabled: _currentPage > 0,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 24),
          Text(
            'PAGE ${_currentPage + 1} OF $totalPages',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.textFaint,
            ),
          ),
          const SizedBox(width: 24),
          _PageBtn(
            icon: Icons.chevron_right_rounded,
            enabled: _currentPage < totalPages - 1,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textFaint,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Journal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (_isFiltered) ...[
          GestureDetector(
            onTap: resetFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
              ),
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Stack(
          children: [
            IconButton(
              icon: Icon(
                _isFilterExpanded
                    ? Icons.filter_alt_rounded
                    : Icons.filter_list_rounded,
                color: _isFilterExpanded ? AppColors.accent : AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
              tooltip: 'Filter entries',
            ),
            if (_isFiltered && !_isFilterExpanded)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return TextField(
      onChanged: (v) => setState(() {
        _searchText = v;
        _currentPage = 0; // Reset to first page on search
      }),
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
    );
  }

  Widget _buildFilterPanel(BuildContext context, MoodController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
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
              onChanged: (v) => setState(() {
                _scoreRange = v;
                _currentPage = 0; // Reset to first page on filter
              }),
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
                      avatar: Icon(
                        AppIcons.fromString(tag.emoji),
                        size: 14,
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                      label: Text(
                        tag.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) => setState(() {
                        _currentPage = 0; // Reset to first page on tag selection
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

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.3,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
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
