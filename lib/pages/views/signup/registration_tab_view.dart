import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/views/signup/group_registration.dart';
import 'package:mlimi/pages/views/signup/loginscreen.dart';

class RegistrationTabView extends StatefulWidget {
  const RegistrationTabView({super.key});

  @override
  State<RegistrationTabView> createState() => _RegistrationTabViewState();
}

class _RegistrationTabViewState extends State<RegistrationTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = GetStorage().read('language') ?? 'en';

    return Scaffold(
      backgroundColor: Bgreen,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              expandedHeight: 260,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    Image.asset(
                      'assets/images/group.jpg',
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay for readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Title and subtitle
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedLanguage == 'en'
                                  ? 'Join our community'
                                  : 'Lowani mu gulu lathu',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedLanguage == 'en'
                                  ? 'Register as an individual or a group to get started.'
                                  : 'Lembetsani nokha kapena monga gulu kuti muyambe.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.95),
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: kPrimaryColor,
                    labelColor: kPrimaryColor,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.person_outline),
                        text:
                            selectedLanguage == 'en' ? 'Individual' : 'Munthu',
                      ),
                      Tab(
                        icon: const Icon(Icons.groups_outlined),
                        text: selectedLanguage == 'en' ? 'Group' : 'Gulu',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            // Embedded forms (no Scaffold)
            SimpleRegisterScreen(embedded: true),
            GroupRegisterScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}


