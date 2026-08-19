class SyncRecord {
  const SyncRecord({
    required this.recordKey,
    required this.entity,
    this.payload,
    required this.updatedAt,
    required this.deleted,
  });

  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    final deletedVal = json['deleted'];
    final isDeleted = deletedVal is bool ? deletedVal : (deletedVal as num? ?? 0) != 0;
    
    return SyncRecord(
      recordKey: json['record_key'] as String,
      entity: json['entity'] as String,
      payload: json['payload'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      deleted: isDeleted,
    );
  }

  final String recordKey;
  final String entity;
  final String? payload;
  final DateTime updatedAt;
  final bool deleted;

  Map<String, dynamic> toJson() {
    return {
      'record_key': recordKey,
      'entity': entity,
      'payload': payload,
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted': deleted,
    };
  }
}

class SyncPullResponse {
  const SyncPullResponse({required this.pulled, required this.serverTime});

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['pulled'] as List<dynamic>? ?? [];
    return SyncPullResponse(
      pulled: raw
          .map((e) => SyncRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      serverTime: DateTime.parse(json['server_time'] as String).toUtc(),
    );
  }

  final List<SyncRecord> pulled;
  final DateTime serverTime;
}

class SyncFailure implements Exception {
  const SyncFailure({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'SyncFailure($statusCode, $code)';
}
