import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/models/requests.dart';
import 'package:mlimi/features/buy_sell/services/api_client.dart';

class CommodityRepository {
  CommodityRepository({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<Commodity>> getForSale() async {
    final data = await _client.get('/commodities/for-sale');
    final list = (data['commodities']?['data'] ?? data['commodities'] ?? [])
        as List<dynamic>;
    return list
        .map((e) => Commodity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Commodity>> getMyPostedForSale() async {
    final list = await getForSale();
    return list
        .where((c) => c.ownPost && (c.type ?? '').toLowerCase() == 'sale')
        .toList();
  }

  Future<List<Commodity>> getForSupply() async {
    final data = await _client.get('/commodities/for-supply');
    final list = (data['commodities']?['data'] ?? data['commodities'] ?? [])
        as List<dynamic>;
    return list
        .map((e) => Commodity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommoditySale>> getCommoditySales(int commodityId) async {
    final data = await _client.get('/commodities/$commodityId/sales');
    final list =
        (data['sales']?['data'] ?? data['sales'] ?? []) as List<dynamic>;
    return list
        .map((e) => CommoditySale.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommodityDetails> getCommodityDetails(int commodityId) async {
    final data = await _client.get('/commodities/$commodityId');
    return CommodityDetails.fromJson(data);
  }

  Future<CommoditySale> createSale(SaleUpsertRequest request) async {
    final data = await _client.post('/commodity-sales', body: request.toJson());
    return CommoditySale.fromJson(data['sale'] as Map<String, dynamic>);
  }

  Future<CommoditySale> updateSale(
      int saleId, SaleUpsertRequest request) async {
    final data =
        await _client.put('/commodities/sales/$saleId', body: request.toJson());
    return CommoditySale.fromJson(data['sale'] as Map<String, dynamic>);
  }

  Future<void> deleteSale(int saleId) => _client.delete('/sales/$saleId');

  Future<void> toggleCommodityStatus({
    required int commodityId,
    required String availabilityStatus,
  }) async {
    await _client.post(
      '/commodities/$commodityId/toggle-status',
      body: {'availability_status': availabilityStatus},
    );
  }

  Future<Commodity> updateCommodity(
      int commodityId, CommodityUpdateRequest request) async {
    final data =
        await _client.put('/commodities/$commodityId', body: request.toJson());
    return Commodity.fromJson(data['commodity'] as Map<String, dynamic>);
  }

  Future<List<CommoditySale>> getMySales({
    int? commodityId,
    int? valueChainId,
    int? buyerId,
    String? paymentStatus,
    String? fromDate,
    String? toDate,
  }) async {
    final data = await _client.get('/profile/commodity-sales', query: {
      if (commodityId != null) 'commodity_id': commodityId,
      if (valueChainId != null) 'value_chain_id': valueChainId,
      if (buyerId != null) 'buyer_id': buyerId,
      if (paymentStatus != null && paymentStatus.isNotEmpty)
        'payment_status': paymentStatus,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    });
    final list =
        (data['sales']?['data'] ?? data['sales'] ?? []) as List<dynamic>;
    return list
        .map((e) => CommoditySale.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StatsSummary> getStatsSummary() async {
    final data = await _client.get('/commodities/stats/summary');
    return StatsSummary.fromJson(data);
  }

  Future<List<Buyer>> getBuyers({String? search}) async {
    final data = await _client.get('/buyers', query: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list =
        (data['buyers']?['data'] ?? data['buyers'] ?? []) as List<dynamic>;
    return list.map((e) => Buyer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Buyer> createBuyer(BuyerCreateRequest request) async {
    final data = await _client.post('/buyers', body: request.toJson());
    return Buyer.fromJson(data['buyer'] as Map<String, dynamic>);
  }

  Future<List<CommoditySale>> getBuyerHistory(int buyerId) async {
    final data = await _client.get('/buyers/$buyerId/history');
    final list =
        (data['sales']?['data'] ?? data['sales'] ?? []) as List<dynamic>;
    return list
        .map((e) => CommoditySale.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ValueChainOption>> getValueChains() async {
    final data = await _client.get('/value-chains');
    final list = (data['value_chains'] ?? data['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => ValueChainOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
