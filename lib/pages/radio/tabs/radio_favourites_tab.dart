import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/models/radio_models.dart';
import 'package:mlimi/pages/radio/audio_player_screen.dart';
import 'package:mlimi/pages/radio/widgets/programme_card.dart';
import 'package:mlimi/pages/radio/widgets/recording_card.dart';
import 'package:mlimi/provider/radio_provider.dart';
import 'package:provider/provider.dart';

class RadioFavouritesTab extends StatelessWidget {
  const RadioFavouritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radio, _) {
        final favProgrammes = radio.allWeeklyProgrammes
            .where((p) => radio.isProgrammeFavourite(p.id))
            .toList();

        final favRecordings = radio.allRecordings
            .where((r) => radio.isRecordingFavourite(r.id))
            .toList();

        final isEmpty = favProgrammes.isEmpty && favRecordings.isEmpty;

        if (isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Color(0xFFF43F5E),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Favourites Yet",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tap the heart icon on any live broadcast, programme, or recording to save it here for quick access.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (favProgrammes.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "Favourite Programmes",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                ...favProgrammes.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ProgrammeCard(
                      programme: p,
                      onPlay: () {
                        if (p.isLive) {
                          radio.playLive();
                        } else {
                          final rec = radio.allRecordings.firstWhere(
                            (r) => r.programmeId == p.id,
                            orElse: () => radio.allRecordings.first,
                          );
                          radio.playRecording(rec);
                        }
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              if (favRecordings.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "Favourite Recordings",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                ...favRecordings.map((r) {
                  final isCurrentlyPlaying = !radio.isLive &&
                      radio.currentRecording?.id == r.id &&
                      radio.status == RadioPlayerStatus.playing;

                  return RecordingCard(
                    recording: r,
                    isCurrentlyPlaying: isCurrentlyPlaying,
                    isFavourite: true,
                    onPlay: () {
                      if (isCurrentlyPlaying) {
                        radio.togglePlayPause();
                      } else {
                        radio.playRecording(r);
                      }
                    },
                    onDownload: () => radio.downloadRecording(r.id),
                    onToggleFavourite: () {
                      radio.toggleFavouriteRecording(r.id);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Removed from Favourites"),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPlayerScreen(recording: r),
                        ),
                      );
                    },
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}
