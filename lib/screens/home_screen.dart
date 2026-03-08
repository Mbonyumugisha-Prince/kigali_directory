import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listing_provider.dart';
import '../utils/app_theme.dart';
import 'directory/directory_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'map/map_view_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().initStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    const tabs = [
      DirectoryScreen(),
      MyListingsScreen(),
      MapViewScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navy,
          border: Border(top: BorderSide(color: AppColors.navyBorder)),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex:         _currentIndex,
            onTap:                (i) => setState(() => _currentIndex = i),
            type:                 BottomNavigationBarType.fixed,
            backgroundColor:      Colors.transparent,
            elevation:            0,
            selectedItemColor:    AppColors.accent,
            unselectedItemColor:  AppColors.textHint,
            selectedLabelStyle:   const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.location_city_rounded), label: 'Directory'),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_rounded),  label: 'My Listings'),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded),       label: 'Map'),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),  label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
