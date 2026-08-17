import 'dart:convert';
import 'dart:math';

import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/data/sync/sync_models.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/services/crypto_service.dart';
import 'package:application/domain/services/encrypted_payload.dart';
import 'package:application/services/questionnaire_service.dart';
import 'package:application/services/sync_http_client.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncState { idle, syncing, success, error, paymentRequired }

class SyncCredentials {
  const SyncCredentials({
    required this.accessToken,
    required this.syncKey,
    required this.dek,
  });

  final String accessToken;
  final String syncKey;
  final SecretKey dek;
}

class SyncService extends ChangeNotifier {
  SyncService({
    required EmotionRepository emotionRepository,
    required SyncHttpClient httpClient,
    required CryptoService crypto,
    DateTime Function()? now,
  })  : _emotionRepository = emotionRepository,
        _httpClient = httpClient,
        _crypto = crypto,
        _now = now ?? DateTime.now;

  final EmotionRepository _emotionRepository;
  final SyncHttpClient _httpClient;
  final CryptoService _crypto;
  final DateTime Function() _now;
  final Random _random = Random.secure();

  SyncState _state = SyncState.idle;
  SyncState get state => _state;

  String? _errorCode;
  String? get errorCode => _errorCode;

  DateTime? _lastSyncAt;
  DateTime? get lastSyncAt => _lastSyncAt;

  Future<bool> sync({
    required int userId,
    required SyncCredentials credentials,
    String baseUrl = 'http://localhost:8090',
  }) async {
    _state = SyncState.syncing;
    _errorCode = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final sinceRaw = prefs.getString('sync_since_$userId');
      final since = sinceRaw == null
          ? DateTime.utc(1970)
          : DateTime.parse(sinceRaw).toUtc();

      final local = await _emotionRepository.getEmotionsForUser(userId);
      final records = <SyncRecord>[];
      for (final entry in local) {
        if (entry.createdAt.isBefore(since)) continue;
        final payload = base64Encode(
          (await _crypto.encryptString(
            jsonEncode({
              'value': entry.value,
              'note': entry.note,
              'tags': entry.tags,
              'createdAt': entry.createdAt.toUtc().toIso8601String(),
            }),
            credentials.dek,
          ))
              .toBytes(),
        );
        records.add(SyncRecord(
          recordKey: 'emotion:${entry.id}',
          entity: 'emotion',
          payload: payload,
          updatedAt: entry.createdAt,
          deleted: false,
        ));
      }

      // Also synchronize PHQ-9/GAD-7 questionnaires (entity questionnaire),
      // encrypted like the mood entries.
      final questionnaires = await QuestionnaireService().history(userId);
      for (final q in questionnaires) {
        if (q.completedAt.isBefore(since)) continue;
        final qPayload = base64Encode(
          (await _crypto.encryptString(
            jsonEncode({
              'type': q.type,
              'totalScore': q.totalScore,
              'severity': q.severity,
              'completedAt': q.completedAt.toUtc().toIso8601String(),
            }),
            credentials.dek,
          ))
              .toBytes(),
        );
        records.add(SyncRecord(
          recordKey: 'questionnaire:${q.type}:${q.completedAt.millisecondsSinceEpoch}',
          entity: 'questionnaire',
          payload: qPayload,
          updatedAt: q.completedAt,
          deleted: false,
        ));
      }

      final body = <String, dynamic>{
        'ts': _now().millisecondsSinceEpoch ~/ 1000,
        'nonce': _hexBytes(16),
        'since': since.toIso8601String(),
        'records': records.map((r) => r.toJson()).toList(),
      };

      final response = await _httpClient.postSync(
        baseUrl: baseUrl,
        accessToken: credentials.accessToken,
        syncKey: credentials.syncKey,
        body: body,
      );

      final pull = SyncPullResponse.fromJson(response);
      await _applyPulls(pull, userId, credentials.dek, local);
      await prefs.setString(
        'sync_since_$userId',
        pull.serverTime.toUtc().toIso8601String(),
      );

      _lastSyncAt = _now();
      _state = SyncState.success;
      notifyListeners();
      return true;
    } on SyncFailure catch (e) {
      _state = e.statusCode == 402
          ? SyncState.paymentRequired
          : SyncState.error;
      _errorCode = e.code;
      notifyListeners();
      return false;
    }
  }

  Future<void> resetForUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sync_since_$userId');
  }

  Future<void> _applyPulls(
    SyncPullResponse pull,
    int userId,
    SecretKey dek,
    List<MoodEntry> local,
  ) async {
    for (final record in pull.pulled) {
      try {
        await _applyPull(record, userId, dek, local);
      } catch (e) {
        // A corrupted record (payload not decryptable, invalid JSON)
        // must not block the entire sync: skip it and continue.
        debugPrint('Sync: skipped record ${record.recordKey}: $e');
      }
    }
  }

  Future<void> _applyPull(
    SyncRecord record,
    int userId,
    SecretKey dek,
    List<MoodEntry> local,
  ) async {
    final idMatch = RegExp(r'^emotion:(\d+)$').firstMatch(record.recordKey);
    if (idMatch == null) return;
    final id = int.parse(idMatch.group(1)!);

    if (record.deleted) {
      await _emotionRepository.deleteEmotion(id);
      return;
    }
    if (record.payload == null) return;
    if (_findEmotionById(id, local) != null) return;

    final payload = EncryptedPayload.fromBytes(base64Decode(record.payload!));
    final plain = _crypto.decryptString(payload, dek);
    final data = jsonDecode(plain) as Map<String, dynamic>;

    await _emotionRepository.addEmotion(
      userId: userId,
      value: (data['value'] as num).toInt(),
      note: data['note'] as String?,
      tags: (data['tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(data['createdAt'] as String).toUtc(),
    );
  }

  MoodEntry? _findEmotionById(int id, List<MoodEntry> local) {
    for (final entry in local) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  String _hexBytes(int length) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
