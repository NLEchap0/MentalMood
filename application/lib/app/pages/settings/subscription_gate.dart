import 'package:application/app/pages/settings/subscription_page.dart';
import 'package:flutter/material.dart';

/// Opens the plans page. Used when a user taps a feature
/// reserved for paid plans (Standard/Pro).
Future<void> openSubscriptionPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
  );
}
