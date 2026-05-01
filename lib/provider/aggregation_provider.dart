import 'package:flutter/material.dart';
import 'package:mlimi/models/aggregation_models.dart';
import 'package:mlimi/services/aggregation_service.dart';

class AggregationProvider extends ChangeNotifier {
  final AggregationService _service = AggregationService();

  List<Aggregation> _aggregations = [];
  AggregationMetrics? _metrics;
  Aggregation? _currentAggregation;

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<Aggregation> get aggregations => _aggregations;
  AggregationMetrics? get metrics => _metrics;
  Aggregation? get currentAggregation => _currentAggregation;

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setActionLoading(bool value) {
    _isActionLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchAggregations({String? status, int? groupId}) async {
    _setLoading(true);
    _setError(null);
    try {
      final data = await _service.getAggregations(status: status, groupId: groupId);
      _aggregations = data['aggregations'] as List<Aggregation>;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDashboardStats() async {
    _setLoading(true);
    _setError(null);
    try {
      _metrics = await _service.getDashboardStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAggregationDetails(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentAggregation = await _service.getAggregationDetails(id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAggregation(Map<String, dynamic> data) async {
    _setActionLoading(true);
    _setError(null);
    try {
      final newAgg = await _service.createAggregation(data);
      _aggregations.insert(0, newAgg);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  Future<bool> addContribution(int id, Map<String, dynamic> data) async {
    _setActionLoading(true);
    _setError(null);
    try {
      await _service.addContribution(id, data);
      await fetchAggregationDetails(id); // Refresh details
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  Future<bool> addNewMemberContribution(int id, Map<String, dynamic> data) async {
    _setActionLoading(true);
    _setError(null);
    try {
      await _service.addNewMemberContribution(id, data);
      await fetchAggregationDetails(id); // Refresh details
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  Future<bool> recordSale(int id, Map<String, dynamic> data) async {
    _setActionLoading(true);
    _setError(null);
    try {
      await _service.recordSale(id, data);
      await fetchAggregationDetails(id); // Refresh details
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setActionLoading(false);
    }
  }
}
