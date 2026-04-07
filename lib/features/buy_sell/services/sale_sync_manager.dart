import 'dart:async';

import 'package:mlimi/features/buy_sell/services/sale_queue_service.dart';

class SaleSyncManager {
  SaleSyncManager({SaleQueueService? queueService})
      : _queueService = queueService ?? SaleQueueService();

  final SaleQueueService _queueService;
  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await _queueService.sync();
    });
  }

  Future<SaleQueueSyncResult> syncNow() => _queueService.sync();

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
