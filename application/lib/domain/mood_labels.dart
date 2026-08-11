/// Single source of truth for the mood scale vocabulary (1..10).
const List<String> moodLabels = [
  'Dormant',
  'Trace',
  'Pulse',
  'Core',
  'Stasis',
  'Flow',
  'Active',
  'Radiant',
  'Vibrant',
  'Zenith',
];

/// Returns the mood label for a value in 1..10 (clamped).
String moodLabelFor(int value) => moodLabels[(value - 1).clamp(0, 9)];
