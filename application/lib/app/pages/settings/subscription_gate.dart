import 'package:application/app/pages/settings/subscription_page.dart';
import 'package:flutter/material.dart';

/// Apre la pagina piani. Usato quando un utente tocca una feature
/// riservata ai piani a pagamento (Standard/Pro).
Future<void> openSubscriptionPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
  );
}
