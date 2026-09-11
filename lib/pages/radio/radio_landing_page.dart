import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/pages/radio/tabs/radio_favourites_tab.dart';
import 'package:mlimi/pages/radio/tabs/radio_live_tab.dart';
import 'package:mlimi/pages/radio/tabs/radio_more_tab.dart';
import 'package:mlimi/pages/radio/tabs/radio_player_tab.dart';
import 'package:mlimi/pages/radio/tabs/radio_recordings_tab.dart';
import 'package:mlimi/pages/radio/tabs/radio_schedule_tab.dart';
import 'package:mlimi/provider/radio_provider.dart';
import 'package:provider/provider.dart';
import 'package:mlimi/models/radio_models.dart';

class RadioLandingPage extends StatelessWidget {
  final int initialTabIndex;

  const RadioLandingPage({
    super.key,
    this.initialTabIndex = 0,
  });

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 30,
              color: Color(0xFF1E293B),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Station badge pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "MLIMI RADIO",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  "98.4 FM",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // Top App Bar Recording Action Button
            Consumer<RadioProvider>(
              builder: (context, radio, _) {
                final isRec = radio.isRecording;
                final mins = (radio.recordingDuration.inSeconds ~/ 60).toString().padLeft(2, '0');
                final secs = (radio.recordingDuration.inSeconds % 60).toString().padLeft(2, '0');

                return GestureDetector(
                  onTap: () {
                    if (isRec) {
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
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRec ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRec ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRec ? Icons.stop_circle_rounded : Icons.fiber_manual_record_rounded,
                          color: isRec ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isRec ? "$mins:$secs" : "REC",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isRec ? const Color(0xFFDC2626) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Live Stream Toggle Button
            Consumer<RadioProvider>(
              builder: (context, radio, _) {
                final isPlaying = radio.isLive && radio.status == RadioPlayerStatus.playing;
                return IconButton(
                  tooltip: "Toggle Live Stream",
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPlaying ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPlaying ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      Icons.sensors_rounded,
                      color: isPlaying ? const Color(0xFF059669) : const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    if (radio.isLive) {
                      radio.togglePlayPause();
                    } else {
                      radio.playLive();
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 4),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: const Color(0xFF059669),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF059669),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.radio_rounded, size: 20),
                text: "Live Radio",
              ),
              Tab(
                icon: Icon(Icons.calendar_month_rounded, size: 20),
                text: "Schedule",
              ),
              Tab(
                icon: Icon(Icons.play_circle_fill_rounded, size: 20),
                text: "Player",
              ),
              Tab(
                icon: Icon(Icons.podcasts_rounded, size: 20),
                text: "Recordings",
              ),
              Tab(
                icon: Icon(Icons.favorite_rounded, size: 20),
                text: "Favourites",
              ),
              Tab(
                icon: Icon(Icons.more_horiz_rounded, size: 20),
                text: "More",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RadioLiveTab(),
            RadioScheduleTab(),
            RadioPlayerTab(),
            RadioRecordingsTab(),
            RadioFavouritesTab(),
            RadioMoreTab(),
          ],
        ),
      ),
    );
  }
}
