import 'package:flutter/material.dart';
import 'package:mlimi/pages/advisory/components/advisor_list.dart';
import 'package:mlimi/services/advisory_service.dart';
import 'package:mlimi/models/advisory_model.dart';

class AdvisoryTabs extends StatelessWidget {
  AdvisoryTabs({super.key}); // No 'const' here
  final DataService dataService = DataService();

  Future<Sector> _fetchSector(String sectorType) async {
    try {
      return await dataService.getSectorByType(sectorType);
    } catch (e) {
      print(e);
      throw Exception('Error fetching sector');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, right: 5, left: 5, bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: "Crops"),
                Tab(text: "Livestocks"),
                Tab(text: "Weather"),
                Tab(text: "Financial Literacy"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder<Sector>(
                    future: _fetchSector('Crops'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading data'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('No data available'));
                      } else {
                        return MoreView(sector: snapshot.data!);
                      }
                    },
                  ),
                  FutureBuilder<Sector>(
                    future: _fetchSector('Livestocks'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading data'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('No data available'));
                      } else {
                        return MoreView(sector: snapshot.data!);
                      }
                    },
                  ),
                  FutureBuilder<Sector>(
                    future: _fetchSector('Weather'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading data'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('No data available'));
                      } else {
                        return MoreView(sector: snapshot.data!);
                      }
                    },
                  ),
                  FutureBuilder<Sector>(
                    future: _fetchSector('Financial Literacy'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading data'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('No data available'));
                      } else {
                        return MoreView(sector: snapshot.data!);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
