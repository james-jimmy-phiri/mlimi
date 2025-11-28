import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mlimi/constants/color.dart';

class SummaryPage extends StatelessWidget {
  final String cropName;
  final double fieldSize;
  final double sellingPrice;
  final List<SectionSummary> sectionSummaries;
  final double totalExpenditure;
  final double totalIncome;
  final double profitMargin;
  final double averageYiled;
  final String cropImage;

  SummaryPage({
    required this.cropName,
    required this.fieldSize,
    required this.sellingPrice,
    required this.sectionSummaries,
    required this.totalExpenditure,
    required this.totalIncome,
    required this.profitMargin,
    required this.averageYiled,
    required this.cropImage,
  });

  void _saveRecord(BuildContext context) {
    // Implement saving logic here
  }

  void _showSectionDetails(BuildContext context, SectionSummary section) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(section.sectionName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item: ${section.contentItem}'),
              Text('Input Value: MWK ${section.inputValue}'),
              Text('Rate per Acre: MWK ${section.rateAcre}/Acre'),
              Text('Total: MWK ${section.total}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                image: DecorationImage(
                  image: AssetImage('assets/images/${cropImage}1.jpg'),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/back.svg"),
                          color: whitecolor,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, color: whitecolor),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      "Gross Margin Analysis for $cropName\nField Size: $fieldSize Hectares",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildSummaryCard(
                context, "Total Income", "MWK $totalIncome", Colors.blue[400]!),
            SizedBox(height: 20),
            _buildSectionSummaries(context),
            Divider(height: 40, color: Colors.grey),
            _buildPieChart(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTotals(context),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _saveRecord(context),
                child: Text('Save Record', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSummaries(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Variable Costs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 10),
          ...sectionSummaries.map((section) {
            return GestureDetector(
              onTap: () => _showSectionDetails(context, section),
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        section.contentItem,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'MWK ${section.total}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Colors.redAccent,
                value: totalExpenditure,
                title: 'Expenditure',
                radius: 60,
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: Colors.greenAccent,
                value: totalIncome,
                title: 'Income',
                radius: 60,
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: Colors.blueAccent,
                value: profitMargin,
                title: 'Profit',
                radius: 60,
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildTotals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Expenditure: MWK $totalExpenditure',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Total Income: MWK $totalIncome',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Profit Margin: MWK $profitMargin',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class SectionSummary {
  final String sectionName;
  final String contentItem;
  final String inputValue;
  final double rateAcre;
  final double total;

  SectionSummary({
    required this.sectionName,
    required this.contentItem,
    required this.inputValue,
    required this.rateAcre,
    required this.total,
  });
}
