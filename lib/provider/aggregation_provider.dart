import 'package:flutter/material.dart';
import 'package:mlimi/models/aggregation_models.dart';
import 'package:mlimi/services/aggregation_service.dart';

class AggregationProvider extends ChangeNotifier {
  final AggregationService _service = AggregationService();

  List<Aggregation> _aggregations = [];
  AggregationMetrics? _metrics;
  AggregationMetrics? _groupMetrics;
  Aggregation? _currentAggregation;
  List<AggregationGroupMember> _groupMembers = [];
  List<AggregationBuyer> _buyers = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _valueChains = [];
  Map<String, dynamic> _broadcastRecipients = {'market_actors': [], 'business_profiles': []};

  bool _isLoading = false;
  bool _isActionLoading = false;
  bool _isLoadingMembers = false;
  bool _isLoadingBuyers = false;
  bool _isLoadingGroups = false;
  bool _isLoadingValueChains = false;
  bool _isLoadingRecipients = false;
  String? _errorMessage;

  List<Aggregation> get aggregations => _aggregations;
  AggregationMetrics? get metrics => _metrics;
  AggregationMetrics? get groupMetrics => _groupMetrics;
  Aggregation? get currentAggregation => _currentAggregation;
  List<AggregationGroupMember> get groupMembers => _groupMembers;
  List<AggregationBuyer> get buyers => _buyers;
  List<Map<String, dynamic>> get groups => _groups;
  List<Map<String, dynamic>> get valueChains => _valueChains;
  Map<String, dynamic> get broadcastRecipients => _broadcastRecipients;

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  bool get isLoadingMembers => _isLoadingMembers;
  bool get isLoadingBuyers => _isLoadingBuyers;
  bool get isLoadingGroups => _isLoadingGroups;
  bool get isLoadingValueChains => _isLoadingValueChains;
  bool get isLoadingRecipients => _isLoadingRecipients;
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

  Future<void> fetchDashboardStats({int? groupId}) async {
    _setLoading(true);
    _setError(null);
    if (groupId != null) _groupMetrics = null; 
    try {
      final metrics = await _service.getDashboardStats(groupId: groupId);
      if (groupId != null) {
        _groupMetrics = metrics;
      } else {
        _metrics = metrics;
      }
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

  Future<void> fetchGroupMembers(int groupId) async {
    _isLoadingMembers = true;
    _setError(null);
    notifyListeners();
    try {
      _groupMembers = await _service.getGroupMembers(groupId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingMembers = false;
      notifyListeners();
    }
  }

  Future<void> fetchBuyers() async {
    _isLoadingBuyers = true;
    _setError(null);
    notifyListeners();
    try {
      _buyers = await _service.getBuyers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingBuyers = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroups() async {
    _isLoadingGroups = true;
    _setError(null);
    notifyListeners();
    try {
      _groups = await _service.getGroups();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingGroups = false;
      notifyListeners();
    }
  }

  Future<void> fetchValueChains() async {
    _isLoadingValueChains = true;
    _setError(null);
    notifyListeners();
    try {
      _valueChains = await _service.getValueChains();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingValueChains = false;
      notifyListeners();
    }
  }

  Future<void> fetchBroadcastRecipients(int id) async {
    _isLoadingRecipients = true;
    _setError(null);
    notifyListeners();
    try {
      _broadcastRecipients = await _service.getBroadcastRecipients(id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingRecipients = false;
      notifyListeners();
    }
  }

  Future<bool> finalizeAndBroadcast(int id, Map<String, dynamic> data) async {
    _setActionLoading(true);
    _setError(null);
    try {
      await _service.finalizeAndBroadcast(id, data);
      await fetchAggregationDetails(id); // Refresh details to show published status
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  Future<bool> updateContribution(int aggregationId, int contributionId, Map<String, dynamic> data) async {
    _setActionLoading(true);
    _setError(null);
    try {
      await _service.updateContribution(aggregationId, contributionId, data);
      await fetchAggregationDetails(aggregationId); // Refresh details
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  Future<bool> deleteAggregation(int id) async {
    _setActionLoading(true);
    _setError(null);
    try {
      await _service.deleteAggregation(id);
      _aggregations.removeWhere((agg) => agg.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setActionLoading(false);
    }
  }
}
