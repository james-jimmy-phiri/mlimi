import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/models/radio_models.dart';
import 'package:mlimi/pages/radio/audio_player_screen.dart';
import 'package:mlimi/pages/radio/widgets/recording_card.dart';
import 'package:mlimi/provider/radio_provider.dart';
import 'package:provider/provider.dart';

class RadioRecordingsTab extends StatefulWidget {
  const RadioRecordingsTab({super.key});

  @override
  State<RadioRecordingsTab> createState() => _RadioRecordingsTabState();
}

class _RadioRecordingsTabState extends State<RadioRecordingsTab> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All',
    'Trade',
    'Care',
    'Trust',
    'Total Landcare',
    'Agcom',
    'Ministry of Agriculture',
    'My Live Recordings',
    'Downloaded',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radio, _) {
        final allRecordings = radio.allRecordings;

        final filtered = allRecordings.where((r) {
          final matchesSearch = _searchQuery.isEmpty ||
              r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.presenter.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.project.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.description.toLowerCase().contains(_searchQuery.toLowerCase());

          if (!matchesSearch) return false;

          if (_selectedFilter == 'All') return true;
          if (_selectedFilter == 'Downloaded') return r.isDownloaded;
          if (_selectedFilter == 'My Live Recordings') return r.isLiveRecording;
          return r.project.toLowerCase() == _selectedFilter.toLowerCase();
        }).toList();

        return Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: "Search projects, episodes & recordings...",
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Horizontal Project Filter Chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;

                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = filter);
                    },
                    selectedColor: const Color(0xFF059669),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF059669)
                          : const Color(0xFFE2E8F0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Recordings List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.podcasts_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No recordings found",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Record live broadcasts or browse by project category",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final recording = filtered[index];
                        final isCurrentlyPlaying = !radio.isLive &&
                            radio.currentRecording?.id == recording.id &&
                            radio.status == RadioPlayerStatus.playing;

                        return RecordingCard(
                          recording: recording,
                          isCurrentlyPlaying: isCurrentlyPlaying,
                          isFavourite: radio.isRecordingFavourite(recording.id),
                          onPlay: () {
                            if (isCurrentlyPlaying) {
                              radio.togglePlayPause();
                            } else {
                              radio.playRecording(recording);
                            }
                          },
                          onDownload: () => radio.downloadRecording(recording.id),
                          onToggleFavourite: () {
                            radio.toggleFavouriteRecording(recording.id);
                            final isFav = radio.isRecordingFavourite(recording.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFav
                                    ? "Added to Favourites"
                                    : "Removed from Favourites"),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioPlayerScreen(
                                  recording: recording,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
