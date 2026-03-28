import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/url.dart';
import 'buyer_detail.dart';

class MarketActors extends StatefulWidget {
  const MarketActors({Key? key}) : super(key: key);

  @override
  _MarketActorsState createState() => _MarketActorsState();
}

class _MarketActorsState extends State<MarketActors> {
  List<dynamic> _buyers = [];
  
  // API filters mapping
  List<dynamic> _apiDistricts = [];
  List<dynamic> _apiValueChains = [];
  
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isOffline = true; // assume offline until proven otherwise or true if fallback used
  bool _hasMore = true;
  
  // Active Filters
  String _searchQuery = '';
  int? _selectedDistrictId;
  int? _selectedValueChainId;

  // Offline manual filters setup
  List<String> manualDistricts = [
    'Lilongwe',
    'Ntchisi',
    'Mchinji',
    'Zomba',
    'Blantyre',
    'Mangochi',
  ];
  Map<String, bool> _offlineDistrictFilters = {};

  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  final Map<String, String> valueChainImages = {
    'Rice': 'assets/images/rice.jpg',
    'Pigeon Peas': 'assets/images/pigeon.png',
    'Pigeon peas': 'assets/images/pigeon.png',
    'Rice and Pigeon Peas': 'assets/images/pigeon.png',
    'Ppeas': 'assets/images/pigeon.png',
    'Ppeas & Rice': 'assets/images/cereals.jpg',
    'Rice/Pigeon Peas': 'assets/images/ricemix.jpg',
    'Soya': 'assets/images/soybean_choice.jpg',
    'G/nuts': 'assets/images/groundnuts_dressing.jpg',
    'G/nuts & soya': 'assets/images/groundsoya.jpg',
    'Soybean and Groundnuts': 'assets/images/groundsoya.jpg',
    'Soya, G/nuts & beans': 'assets/images/legumes.jpg',
    'Soya & beans': 'assets/images/beans.jpg',
  };

  @override
  void initState() {
    super.initState();
    _offlineDistrictFilters = {for (var district in manualDistricts) district: false};
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Try to fetch filter options from API
    await _fetchFilterOptions();
    // Then fetch the first page of market actors
    await _fetchData(refresh: true);
  }

  Future<void> _fetchFilterOptions() async {
    try {
      final districtRes = await http.get(Uri.parse('${apiurl}v1/districts')).timeout(const Duration(seconds: 10));
      if (districtRes.statusCode == 200) {
        final data = json.decode(districtRes.body);
        setState(() {
          _apiDistricts = data['data'] ?? data; // Depending on API response structure
        });
      }
      
      final vcRes = await http.get(Uri.parse('${apiurl}v1/value-chains')).timeout(const Duration(seconds: 10));
      if (vcRes.statusCode == 200) {
        final data = json.decode(vcRes.body);
        setState(() {
          _apiValueChains = data['data'] ?? data;
        });
      }
    } catch (e) {
      print("Error fetching filters: $e");
    }
  }

  Future<void> _fetchData({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _buyers = [];
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String queryParams = '?page=$_currentPage';
      if (_searchQuery.isNotEmpty) queryParams += '&search=$_searchQuery';
      if (_selectedDistrictId != null) queryParams += '&district_id=$_selectedDistrictId';
      if (_selectedValueChainId != null) queryParams += '&value_chain_id=$_selectedValueChainId';

      final response = await http
          .get(Uri.parse('${apiurl}v1/market-actors$queryParams'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final paginatedData = data['data'] ?? {};
        final List<dynamic> newBuyers = paginatedData['data'] is List ? paginatedData['data'] : (paginatedData is List ? paginatedData : []);

        if (refresh && newBuyers.isEmpty && _searchQuery.isEmpty && _selectedDistrictId == null && _selectedValueChainId == null) {
          // If the list is completely empty from API on initial load, fallback to JSON
          _fallbackToOffline();
        } else {
          setState(() {
            _isOffline = false;
            _buyers.addAll(newBuyers);
            _currentPage++;
            
            int lastPage = paginatedData['last_page'] ?? 1;
            if (_currentPage > lastPage) {
              _hasMore = false;
            }
          });
        }
      } else {
        if (refresh) _fallbackToOffline();
      }
    } on SocketException {
      if (refresh) _fallbackToOffline();
    } on TimeoutException {
      if (refresh) _fallbackToOffline();
    } catch (e) {
      print("API Fetch Error: $e");
      if (refresh) _fallbackToOffline();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fallbackToOffline() async {
    setState(() {
      _isOffline = true;
      _isLoading = false;
      _hasMore = false;
    });

    try {
      final String response = await rootBundle.loadString('assets/data/market_actors.json');
      final data = json.decode(response);
      final List<dynamic> allBuyers = data['buyers'] ?? [];

      _filterOfflineData(allBuyers);
    } catch (e) {
      print("Error loading offline JSON: $e");
    }
  }

  void _filterOfflineData(List<dynamic> allBuyers) {
    if (!mounted) return;
    
    setState(() {
      _buyers = allBuyers.where((buyer) {
        final name = (buyer['name'] ?? '').toString().toLowerCase();
        final location = (buyer['location'] ?? '').toString().toLowerCase();
        final district = buyer['district'];

        final matchesQuery = _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase()) || location.contains(_searchQuery.toLowerCase());
        
        bool isDistrictChecked = _offlineDistrictFilters[district] ?? false;
        if (!_offlineDistrictFilters.containsValue(true)) {
          isDistrictChecked = true;
        }

        // We don't have offline value chain filter implemented strictly, but could map name searches.
        // For now, offline filter works primarily on _searchQuery and District checkboxes.
        return matchesQuery && isDistrictChecked;
      }).toList();
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != _searchController.text) {
        _searchQuery = _searchController.text;
        if (_isOffline) {
          _fallbackToOffline();
        } else {
          _fetchData(refresh: true);
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore && !_isOffline) {
        _fetchData();
      }
    }
  }

  void _applyFilterOnline() {
    Navigator.of(context).pop();
    _fetchData(refresh: true);
  }

  void _applyOfflineDistrictFilter(String district, bool? value) {
    setState(() {
      _offlineDistrictFilters[district] = value ?? false;
    });
    _fallbackToOffline(); 
  }

  String _getDistrictName(dynamic buyer) {
    if (buyer['district'] is String) return buyer['district'];
    if (buyer['district'] is Map && buyer['district']['name'] != null) return buyer['district']['name'];
    return buyer['district_name'] ?? 'Unknown District';
  }

  String _getValueChainName(dynamic buyer) {
    if (buyer['value_chain'] is String) return buyer['value_chain'];
    if (buyer['valueChains'] is List && (buyer['valueChains'] as List).isNotEmpty) {
      var chains = buyer['valueChains'] as List;
      return chains.map((v) => v['name']).join(', ');
    }
    if (buyer['value_chains'] is List && (buyer['value_chains'] as List).isNotEmpty) {
      var chains = buyer['value_chains'] as List;
      return chains.map((v) => v['name']).join(', ');
    }
    return buyer['value_chain_name'] ?? 'Unknown crop';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Actors'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: _isOffline ? _buildOfflineFilterDrawer() : _buildOnlineFilterDrawer(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          if (_isOffline)
             Container(
               width: double.infinity,
               color: Colors.orange.shade100,
               padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
               child: const Text('Offline Mode: Showing locally saved data', style: TextStyle(color: Colors.orange, fontSize: 12)),
             ),
          Expanded(
            child: _isLoading && _buyers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _buyers.length + (_hasMore && !_isOffline ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _buyers.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final buyer = _buyers[index];
                      final vcName = _getValueChainName(buyer);
                      final distName = _getDistrictName(buyer);

                      // Try to find image by exact name match first, or fallback
                      String imageUrl = valueChainImages[buyer['value_chain']] ?? 'assets/images/cereals.jpg';
                      
                      // More robust image fetching: check if vcName contains keys
                      if (imageUrl == 'assets/images/cereals.jpg') {
                          for (var key in valueChainImages.keys) {
                             if (vcName.toLowerCase().contains(key.toLowerCase())) {
                                 imageUrl = valueChainImages[key]!;
                                 break;
                             }
                          }
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            buyer['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vcName,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    distName,
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Image.asset(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          onTap: () {
                            // Ensure the object passed to detail matches expected schema locally
                            final detailBuyer = Map<String, dynamic>.from(buyer);
                            detailBuyer['value_chain'] = vcName;
                            detailBuyer['district'] = distName;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuyerDetail(
                                  buyer: detailBuyer,
                                  imagePath: imageUrl,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFilterDrawer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by District\n(Offline Mode)',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: manualDistricts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final district = manualDistricts[index];
              return CheckboxListTile(
                value: _offlineDistrictFilters[district],
                onChanged: (value) => _applyOfflineDistrictFilter(district, value),
                title: Text(
                  district,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineFilterDrawer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('District', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButton<int?>(
                isExpanded: true,
                value: _selectedDistrictId,
                hint: const Text('All Districts'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Districts'),
                  ),
                  ..._apiDistricts.map<DropdownMenuItem<int?>>((d) {
                    return DropdownMenuItem<int?>(
                      value: d['id'],
                      child: Text(d['name'] ?? ''),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedDistrictId = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text('Value Chain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButton<int?>(
                isExpanded: true,
                value: _selectedValueChainId,
                hint: const Text('All Value Chains'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Value Chains'),
                  ),
                  ..._apiValueChains.map<DropdownMenuItem<int?>>((v) {
                    return DropdownMenuItem<int?>(
                      value: v['id'],
                      child: Text(v['name'] ?? ''),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedValueChainId = val;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _applyFilterOnline,
                child: const Text('Apply Filters'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  setState(() {
                    _selectedDistrictId = null;
                    _selectedValueChainId = null;
                  });
                  _applyFilterOnline();
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
