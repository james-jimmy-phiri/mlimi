import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'buyer_detail.dart';

class MarketActors extends StatefulWidget {
  const MarketActors({Key? key}) : super(key: key);

  @override
  _MarketActorsState createState() => _MarketActorsState();
}

class _MarketActorsState extends State<MarketActors> {
  List<dynamic> _buyers = [];
  List<dynamic> _filteredBuyers = [];
  List<String> manualDistricts = [
    'Lilongwe',
    'Ntchisi',
    'Mchinji',
    'Zomba',
    'Blantyre'
  ]; // Manual list of districts
  Map<String, bool> _districtFilters = {};
  TextEditingController _searchController = TextEditingController();
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

    // Add more value chains as needed
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearch);
    // Initialize district filters as unchecked by default
    _districtFilters = {for (var district in manualDistricts) district: false};
  }

  Future<void> _loadData() async {
    final String response =
        await rootBundle.loadString('assets/data/market_actors.json');
    final data = json.decode(response);
    final buyers = data['buyers'];

    setState(() {
      _buyers = buyers;
      _filteredBuyers = buyers; // Initially display all buyers
    });
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    _filterBuyers(query);
  }

  void _filterBuyers(String query) {
    setState(() {
      _filteredBuyers = _buyers.where((buyer) {
        final name = buyer['name'].toLowerCase();
        final location = buyer['location'].toLowerCase();
        final district = buyer['district'];

        final matchesQuery = name.contains(query) || location.contains(query);
        final isDistrictChecked = _districtFilters[district] ?? false;

        // If no district is checked, show all buyers matching the query
        if (!_districtFilters.containsValue(true)) {
          return matchesQuery;
        }

        // Only show buyers from checked districts
        return matchesQuery && isDistrictChecked;
      }).toList();
    });
  }

  void _onDistrictFilterChanged(String district, bool? value) {
    setState(() {
      _districtFilters[district] = value ?? false;
      _filterBuyers(_searchController.text.toLowerCase());
    });
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by District',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: manualDistricts.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final district = manualDistricts[index];
                  return CheckboxListTile(
                    value: _districtFilters[district],
                    onChanged: (value) =>
                        _onDistrictFilterChanged(district, value),
                    title: Text(
                      district,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBuyers.length,
              itemBuilder: (context, index) {
                final buyer = _filteredBuyers[index];
                final valueChain = buyer['value_chain'];
                final imageUrl =
                    valueChainImages[valueChain] ?? 'assets/images/cereals.jpg';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      buyer['name'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buyer['value_chain'],
                          style: TextStyle(fontSize: 14),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              buyer['district'],
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyerDetail(
                            buyer: buyer,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
