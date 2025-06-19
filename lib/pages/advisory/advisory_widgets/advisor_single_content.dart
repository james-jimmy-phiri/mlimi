// section_content_page.dart
import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/advisory_model.dart';

class AdvisorSingleContent extends StatefulWidget {
  final Section section;

  const AdvisorSingleContent({super.key, required this.section});

  @override
  State<AdvisorSingleContent> createState() => _AdvisorSingleContentState();
}

class _AdvisorSingleContentState extends State<AdvisorSingleContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        backgroundColor: Bgreen,
        title: Text(
          widget.section.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              // const Text(
              //   "Introduction",
              //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              // ),
              // const Text(
              //   "Maize is the staple crop in Malawi and a cornerstone of food security for many households. Grown primarily in the country, maize supports both subsistence and commercial farming. It thrives under Malawi's favorable subtropical climate, which provides the ideal conditions during the main growing season, particularly between November and April, aligning with the rainy season.",
              //   style: TextStyle(fontSize: 16),
              // ),
              const SizedBox(
                height: 2.0,
              ),
              ClipRRect(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 300.0, // Set the maximum height here
                  ),
                  child: Image.asset(
                    'assets/images/${widget.section.image}.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(height: 16.0),
              ...widget.section.content.map((contentItem) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "- $contentItem",
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
