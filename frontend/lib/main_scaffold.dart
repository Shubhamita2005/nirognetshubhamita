// lib/main_scaffold.dart
import 'package:flutter/material.dart';

// 1. Import all the screens for the nav bar
// (Use the correct paths from your project)
import 'screens/homepage.dart';
import 'screens/book_consultation_page.dart';
// Import your other screens as you create them
// import 'screens/medicine_availability.dart'; 
// import 'screens/health_records.dart';

// --- Placeholders for screens you haven't made yet ---
// You can create these files later, just like we did for Home
class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Medicine Availability")),
        body: const Center(child: Text("Medicine Availability Screen")));
  }
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Health Records")),
        body: const Center(child: Text("Health Records Screen")));
  }
}
// --- End of Placeholders ---


class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // 2. Create the list of screens
  static const List<Widget> _screens = <Widget>[
    HomeScreen(), // Index 0
    BookConsultationScreen(), // Index 1
    // Index 2 is the AI Checker, handled separately
    MedicineScreen(), // Index 3
    RecordsScreen(), // Index 4
  ];

  // 3. This method now handles all navigation
  void _onItemTapped(int index) {
    // SPECIAL CASE: Handle the AI Symptom Checker
    if (index == 2) {
      // Use pushNamed to open it as a new, separate page
      // This will NOT have the bottom nav bar
      Navigator.pushNamed(context, '/ai_symptom');
      
      // We don't change the state, so the tab selection remains on 
      // the previous screen (e.g., Home). This is usually desired.
      // If you want the "Home" tab to be re-selected, you could add:
      // setState(() => _selectedIndex = 0); 
    } 
    // Handle all other tabs
    else {
      // We need to adjust the index for our list,
      // since the AI checker (index 2) isn't in it.
      int listIndex = index;
      if (index > 2) {
        listIndex = index - 1; // e.g., Tab 3 maps to list item 2
      }

      setState(() {
        _selectedIndex = index; // This controls the highlighted tab
      });

      // Note: We are no longer using a PageView or IndexedStack here
      // for simplicity. Re-building with the new screen.
      // A more optimized way would be to use an IndexedStack.
    }
  }

  // Helper to get the correct screen from the list
  Widget _getCurrentScreen() {
    int listIndex = _selectedIndex;
    if (_selectedIndex > 2) {
      listIndex = _selectedIndex - 1;
    }
    return _screens[listIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 4. The body is now the screen from our list
      body: _getCurrentScreen(),
      // 5. This is the persistent Bottom Nav Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // This is the nav bar code from your original homepage.dart
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // This calls our new logic
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: <BottomNavigationBarItem>[
          _buildNavBarItem(0, Icons.home, 'HOME'),
          _buildNavBarItem(1, Icons.calendar_month, 'Book Consultation'),
          _buildNavBarItem(2, Icons.smart_toy_outlined, 'AI Symptom Checker'),
          _buildNavBarItem(
            3,
            Icons.local_pharmacy_outlined,
            'Medicine Availability',
          ),
          _buildNavBarItem(4, Icons.description_outlined, 'Health Records'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(
    int index,
    IconData iconData,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Colors.teal.shade100
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(iconData),
      ),
      label: label,
    );
  }
}