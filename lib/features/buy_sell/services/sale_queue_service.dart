import 'dart:convert';
import 'dart:io';

import 'package:mlimi/features/buy_sell/models/requests.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QueuedSale {
  QueuedSale({
    required this.id,
    required this.createdAt,
    required this.retryCount,
    required this.payload,
    this.lastError,
  });

  final String id;
  final String createdAt;
  final int retryCount;
  final SaleUpsertRequest payload;
  final String? lastError;

  QueuedSale copyWith({int? retryCount, String? lastError}) {
    return QueuedSale(
      id: id,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      payload: payload,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'retry_count': retryCount,
      'payload': payload.toJson(),
      'last_error': lastError,
    };
  }

  factory QueuedSale.fromJson(Map<String, dynamic> json) {
    final payload = Map<String, dynamic>.from(json['payload'] as Map);
    return QueuedSale(
      id: json['id'].toString(),
      createdAt: json['created_at'].toString(),
      retryCount: (json['retry_count'] ?? 0) as int,
      payload: SaleUpsertRequest(
        commodityId: (payload['commodity_id'] ?? 0) as int,
        valueChainId: (payload['value_chain_id'] ?? 0) as int,
        quantitySold: (payload['quantity_sold'] as num?)?.toDouble() ?? 0,
        unitPrice: (payload['unit_price'] as num?)?.toDouble() ?? 0,
        saleDate: payload['sale_date']?.toString(),
        buyerId: payload['buyer_id'] as int?,
        buyerName: payload['buyer_name']?.toString(),
        buyerPhone: payload['buyer_phone']?.toString(),
        paymentStatus: payload['payment_status']?.toString() ?? 'pending',
        amountPaid: (payload['amount_paid'] as num?)?.toDouble() ?? 0,
        paymentDueDate: payload['payment_due_date']?.toString(),
        paymentNotes: payload['payment_notes']?.toString(),
        farmingSeasonId: payload['farming_season_id'] as int?,
        groupMemberId: payload['group_member_id'] as int?,
      ),
      lastError: json['last_error']?.toString(),
    );
  }
}

class SaleQueueSyncResult {
  SaleQueueSyncResult(
      {required this.synced, required this.failed, required this.remaining});
  final int synced;
  final int failed;
  final int remaining;
}

class SaleQueueService {
  SaleQueueService({CommodityRepository? repository})
      : _repository = repository ?? CommodityRepository();

  static const _queueKey = 'commodity_sales_queue_v1';
  final CommodityRepository _repository;

  Future<List<QueuedSale>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .map((e) => QueuedSale.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> enqueue(SaleUpsertRequest request) async {
    final queue = await getQueue();
    queue.add(
      QueuedSale(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now().toIso8601String(),
        retryCount: 0,
        payload: request,
      ),
    );
    await _save(queue);
  }

  Future<SaleQueueSyncResult> sync() async {
    final queue = await getQueue();
    if (queue.isEmpty) {
      return SaleQueueSyncResult(synced: 0, failed: 0, remaining: 0);
    }

    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      return SaleQueueSyncResult(
          synced: 0, failed: queue.length, remaining: queue.length);
    }

    int synced = 0;
    int failed = 0;
    final nextQueue = <QueuedSale>[];
    for (final item in queue) {
      try {
        await _repository.createSale(item.payload);
        synced++;
      } catch (e) {
        failed++;
        nextQueue.add(item.copyWith(
            retryCount: item.retryCount + 1, lastError: e.toString()));
      }
    }
    await _save(nextQueue);
    return SaleQueueSyncResult(
        synced: synced, failed: failed, remaining: nextQueue.length);
  }

  Future<void> _save(List<QueuedSale> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _queueKey, jsonEncode(queue.map((e) => e.toJson()).toList()));
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
