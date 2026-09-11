import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/models/radio_models.dart';

class RecordingCard extends StatelessWidget {
  final RadioRecording recording;
  final bool isCurrentlyPlaying;
  final bool? isFavourite;
  final VoidCallback onPlay;
  final VoidCallback onDownload;
  final VoidCallback onToggleFavourite;
  final VoidCallback? onTap;

  const RecordingCard({
    super.key,
    required this.recording,
    required this.isCurrentlyPlaying,
    this.isFavourite,
    required this.onPlay,
    required this.onDownload,
    required this.onToggleFavourite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fav = isFavourite ?? recording.isFavourite;

    return InkWell(
      onTap: onTap ?? onPlay,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentlyPlaying
              ? Border.all(color: const Color(0xFF0284C7), width: 1.5)
              : Border.all(color: const Color(0xFFF1F5F9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Play button or audio thumbnail
                GestureDetector(
                  onTap: onPlay,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isCurrentlyPlaying
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isCurrentlyPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isCurrentlyPlaying
                          ? Colors.white
                          : const Color(0xFF059669),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Episode Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recording.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isCurrentlyPlaying
                              ? const Color(0xFF0284C7)
                              : const Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${recording.presenter} • ${recording.airDate}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Favourite Button
                IconButton(
                  icon: Icon(
                    fav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: fav
                        ? const Color(0xFFF43F5E)
                        : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: onToggleFavourite,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description snippet
            Text(
              recording.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF475569),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 10),

            // Bottom action row: Category tag, duration, and download state
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recording.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      recording.durationText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),

                // Download Button / Status
                if (recording.isDownloaded) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF059669),
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Downloaded",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ] else if (recording.downloadProgress > 0 &&
                    recording.downloadProgress < 1.0) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      value: recording.downloadProgress,
                      strokeWidth: 2.2,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ] else ...[
                  InkWell(
                    onTap: onDownload,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.download_rounded,
                            size: 16,
                            color: Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Download",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
