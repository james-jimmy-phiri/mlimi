import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/models/radio_models.dart';
import 'package:mlimi/pages/radio/widgets/audio_visualizer.dart';
import 'package:mlimi/provider/radio_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class RadioPlayerTab extends StatefulWidget {
  const RadioPlayerTab({super.key});

  @override
  State<RadioPlayerTab> createState() => _RadioPlayerTabState();
}

class _RadioPlayerTabState extends State<RadioPlayerTab> {
  String _selectedProjectFilter = 'All';
  String _searchQuery = '';

  final List<String> _projectCategories = [
    'All',
    'Trade',
    'Care',
    'Trust',
    'Total Landcare',
    'Agcom',
    'Ministry of Agriculture',
    'My Live Recordings',
  ];

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return "${d.inHours}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  void _showRecordDialog(BuildContext context, RadioProvider radio) {
    String selectedProject = 'Trade';
    final titleController = TextEditingController(
      text: "Recording: ${radio.currentProgramme?.title ?? 'Mlimi Live 98.4 FM'}",
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mic_rounded, color: Color(0xFFDC2626), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                "Save Recording",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Assign this audio recording to a project category:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedProject,
                decoration: InputDecoration(
                  labelText: "Project Category",
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Trade', child: Text("1. TRADE")),
                  DropdownMenuItem(value: 'Care', child: Text("2. CARE")),
                  DropdownMenuItem(value: 'Trust', child: Text("3. TRUST")),
                  DropdownMenuItem(value: 'Total Landcare', child: Text("4. FMNR")),
                  DropdownMenuItem(value: 'Agcom', child: Text("5. AGCOM")),
                  DropdownMenuItem(value: 'Ministry of Agriculture', child: Text("6. MINISTRY OF AGRICULTURE")),
                  DropdownMenuItem(value: 'My Live Recordings', child: Text("7. Personal / Farmer Group")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedProject = val);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                decoration: InputDecoration(
                  labelText: "Recording Title",
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final enteredTitle = titleController.text.trim().isEmpty
                    ? "Live Broadcast ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"
                    : titleController.text.trim();
                final saved = await radio.stopRecording(
                  title: enteredTitle,
                  project: selectedProject,
                );
                if (context.mounted && saved != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF065F46),
                      content: Text("Recording saved under ${saved.project}!"),
                    ),
                  );
                }
              },
              child: Text(
                "Save Audio",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedMenu(BuildContext context, RadioProvider radio) {
    final speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Playback Speed",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...speeds.map((s) {
                  final isSelected = radio.playbackSpeed == s;
                  return ListTile(
                    title: Text(
                      "${s}x",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF059669) : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF059669))
                        : const SizedBox(width: 24),
                    onTap: () {
                      radio.setPlaybackSpeed(s);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radio, _) {
        final currentRec = radio.currentRecording ?? (radio.allRecordings.isNotEmpty ? radio.allRecordings.first : null);
        final isPlayingRecording = !radio.isLive && radio.status == RadioPlayerStatus.playing;
        final isBuffering = !radio.isLive &&
            (radio.status == RadioPlayerStatus.buffering || radio.status == RadioPlayerStatus.connecting);
        final position = !radio.isLive ? radio.position : Duration.zero;
        final duration = !radio.isLive && radio.duration > Duration.zero
            ? radio.duration
            : (currentRec?.duration ?? const Duration(minutes: 30));

        final filteredRecordings = radio.allRecordings.where((r) {
          final matchesSearch = _searchQuery.isEmpty ||
              r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.presenter.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.project.toLowerCase().contains(_searchQuery.toLowerCase());

          if (!matchesSearch) return false;

          if (_selectedProjectFilter == 'All') return true;
          if (_selectedProjectFilter == 'My Live Recordings') return r.isLiveRecording;
          return r.project.toLowerCase() == _selectedProjectFilter.toLowerCase();
        }).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Now Playing Deck
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Bar inside player: Project Badge & Recording status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.podcasts_rounded, color: Color(0xFF34D399), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                (currentRec?.project ?? "TRADE").toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: const Color(0xFF34D399),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (radio.isRecording)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle, color: Colors.white, size: 8),
                                const SizedBox(width: 5),
                                Text(
                                  "REC ${_formatDuration(radio.recordingDuration)}",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Logo / Artwork Display
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icons/mlimiradiologo.jpg',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/logo/mlimi_radio_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF065F46),
                                  child: const Icon(Icons.radio_rounded, color: Colors.white, size: 36),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentRec?.title ?? "Mlimi Recording",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${currentRec?.presenter ?? 'Farm Radio Specialist'} • ${currentRec?.airDate ?? 'Recorded'}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AudioVisualizer(
                                isPlaying: isPlayingRecording,
                                barCount: 16,
                                color: const Color(0xFF10B981),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress Scrubber Bar
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: const Color(0xFF10B981),
                        inactiveTrackColor: const Color(0xFF334155),
                        thumbColor: const Color(0xFF34D399),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: position.inMilliseconds.toDouble().clamp(
                              0.0,
                              duration.inMilliseconds.toDouble() > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1.0,
                            ),
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble() > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0,
                        onChanged: (val) {
                          if (!radio.isLive) {
                            radio.seek(Duration(milliseconds: val.toInt()));
                          }
                        },
                      ),
                    ),

                    // Timestamps
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Media Player Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => _showSpeedMenu(context, radio),
                          child: Text(
                            "${radio.playbackSpeed}x",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, size: 28, color: Colors.white),
                          onPressed: !radio.isLive ? () => radio.seekRelative(-10) : null,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (currentRec != null) {
                              if (!radio.isLive && radio.currentRecording?.id == currentRec.id) {
                                radio.togglePlayPause();
                              } else {
                                radio.playRecording(currentRec);
                              }
                            }
                          },
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF059669), Color(0xFF10B981)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF059669).withOpacity(0.5),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isBuffering
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Icon(
                                      isPlayingRecording
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, size: 28, color: Colors.white),
                          onPressed: !radio.isLive ? () => radio.seekRelative(10) : null,
                        ),
                        if (currentRec != null)
                          IconButton(
                            icon: Icon(
                              radio.isRecordingFavourite(currentRec.id)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: radio.isRecordingFavourite(currentRec.id)
                                  ? const Color(0xFFF43F5E)
                                  : const Color(0xFF94A3B8),
                              size: 22,
                            ),
                            onPressed: () {
                              radio.toggleFavouriteRecording(currentRec.id);
                              final isFav = radio.isRecordingFavourite(currentRec.id);
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
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Import Local Audio File & Live Record Toolbar Row
              Row(
                children: [
                  // Pick File Button (Local Device Music Player)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () => radio.pickAndPlayLocalAudio(),
                      icon: const Icon(Icons.folder_open_rounded, size: 18),
                      label: Text(
                        "Choose Local Audio",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Live Stream Record Action Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: radio.isRecording ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (radio.isRecording) {
                        _showRecordDialog(context, radio);
                      } else {
                        radio.startRecording();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFFDC2626),
                            content: Text("Recording live stream started!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      radio.isRecording ? Icons.stop_circle_rounded : Icons.fiber_manual_record_rounded,
                      size: 18,
                    ),
                    label: Text(
                      radio.isRecording
                          ? "Stop (${_formatDuration(radio.recordingDuration)})"
                          : "Record Stream",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Project Categorized Library Section Header
              Text(
                "Audio Library by Project",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),

              // Project Filter Chips Row
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _projectCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _projectCategories[index];
                    final isSelected = cat == _selectedProjectFilter;

                    return ChoiceChip(
                      label: Text(
                        cat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF059669),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      showCheckmark: false,
                      onSelected: (val) {
                        if (val) setState(() => _selectedProjectFilter = cat);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Search episodes, topics & presenters...",
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Playlist Items List
              if (filteredRecordings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_rounded, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        "No recordings found for this category",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredRecordings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredRecordings[index];
                    final isThisPlaying = !radio.isLive &&
                        radio.currentRecording?.id == item.id &&
                        radio.status == RadioPlayerStatus.playing;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isThisPlaying
                              ? const Color(0xFF059669)
                              : const Color(0xFFE2E8F0),
                          width: isThisPlaying ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isThisPlaying) {
                                radio.togglePlayPause();
                              } else {
                                radio.playRecording(item);
                              }
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isThisPlaying
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: isThisPlaying
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF475569),
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.project.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF047857),
                                        ),
                                      ),
                                    ),
                                    if (item.isLiveRecording) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.localPath != null ? "LOCAL" : "LIVE REC",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFDC2626),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${item.presenter} • ${item.durationText}",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Direct Favourite Heart Button
                          IconButton(
                            icon: Icon(
                              radio.isRecordingFavourite(item.id)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: radio.isRecordingFavourite(item.id)
                                  ? const Color(0xFFF43F5E)
                                  : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            onPressed: () {
                              radio.toggleFavouriteRecording(item.id);
                              final isFav = radio.isRecordingFavourite(item.id);
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
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B), size: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              if (val == 'play') {
                                radio.playRecording(item);
                              } else if (val == 'share') {
                                Share.share("Listen to '${item.title}' on Mlimi Radio: ${item.audioUrl}");
                              } else if (val == 'fav') {
                                radio.toggleFavouriteRecording(item.id);
                                final isFav = radio.isRecordingFavourite(item.id);
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
                              } else if (val == 'delete') {
                                radio.deleteRecording(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Recording removed")),
                                );
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'play',
                                child: Row(
                                  children: [
                                    Icon(Icons.play_circle_outline_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text("Play Now"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    Icon(Icons.share_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text("Share"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'fav',
                                child: Row(
                                  children: [
                                    Icon(
                                      radio.isRecordingFavourite(item.id)
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 18,
                                      color: const Color(0xFFF43F5E),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(radio.isRecordingFavourite(item.id) ? "Unfavourite" : "Favourite"),
                                  ],
                                ),
                              ),
                              if (item.isLiveRecording)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Delete", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
