import 'package:flutter/material.dart';

/// Iconography helpers — mood levels and tag/emoji names → Material icons.
abstract final class AppIcons {
  static IconData getMoodIcon(int value) {
    switch (value) {
      case 1:
        return Icons.radio_button_unchecked_rounded;
      case 2:
        return Icons.blur_on_rounded;
      case 3:
        return Icons.trip_origin_rounded;
      case 4:
        return Icons.adjust_rounded;
      case 5:
        return Icons.tonality_rounded;
      case 6:
        return Icons.motion_photos_on_rounded;
      case 7:
        return Icons.track_changes_rounded;
      case 8:
        return Icons.brightness_high_rounded;
      case 9:
        return Icons.flare_rounded;
      case 10:
        return Icons.auto_awesome_rounded;
      default:
        return Icons.lens_blur_rounded;
    }
  }

  static IconData fromString(String name) {
    // Normalize emoji stored by older seeds: strip ZWJ and variation
    // selectors so both 'work' and '💼' map to the same icon.
    final key = name.replaceAll('\u200d', '').replaceAll('\ufe0f', '');
    switch (key) {
      case 'work':
      case '💼':
        return Icons.work_outline_rounded;
      case 'sport':
      case '🏃':
      case '🏃♂':
        return Icons.fitness_center_rounded;
      case 'food':
      case '🍎':
        return Icons.restaurant_rounded;
      case 'sleep':
      case '😴':
        return Icons.bedtime_outlined;
      case 'family':
      case '👨👩👧':
      case '👪':
        return Icons.groups_2_rounded;
      case 'friends':
      case '🤝':
      case '👯':
        return Icons.person_add_rounded;
      case 'hobby':
      case '🎨':
        return Icons.palette_outlined;
      case 'weather':
      case '⛅':
      case '🌤':
        return Icons.wb_sunny_outlined;
      case 'streak':
        return Icons.local_fire_department_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'diamond':
        return Icons.diamond_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'edit':
        return Icons.edit_note_rounded;
      case 'morning':
        return Icons.wb_twilight_rounded;
      case 'night':
        return Icons.nightlight_round;
      case 'zen':
        return Icons.spa_rounded;
      case 'roller':
        return Icons.timeline_rounded;
      case 'social':
        return Icons.hub_rounded;
      default:
        return Icons.label_important_outline_rounded;
    }
  }
}
