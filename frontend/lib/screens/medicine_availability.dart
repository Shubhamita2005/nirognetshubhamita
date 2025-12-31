import 'package:flutter/material.dart';

void main() {
  runApp(MedicineAvailabilityApp());
}

class MedicineAvailabilityApp extends StatelessWidget {
  const MedicineAvailabilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MedicineAvailabilityPage(),
    );
  }
}

class MedicineAvailabilityPage extends StatelessWidget {
  final List<Map<String, String>> previouslyViewed = [
    {
      "name": "Aspirin",
      "desc": "Pain reliever, anti-inflammatory",
      "status": "Available",
    },
    {"name": "Metformin", "desc": "Diabetes medication", "status": "Available"},
    {"name": "Amoxicillin", "desc": "Antibiotic", "status": "Low Stock"},
    {
      "name": "Atorvastatin",
      "desc": "Cholesterol medication",
      "status": "Available",
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.favorite, "label": "Cardiac"},
    {"icon": Icons.psychology, "label": "Neurology"},
    {"icon": Icons.coronavirus, "label": "Allergy"},
    {"icon": Icons.healing, "label": "Pain Relief"},
    {"icon": Icons.air, "label": "Respiratory"},
    {"icon": Icons.local_hospital, "label": "Digestive"},
    {"icon": Icons.medication, "label": "Antibiotics"},
    {"icon": Icons.monitor_heart, "label": "Diabetes"},
    {"icon": Icons.visibility, "label": "View All"},
  ];

   MedicineAvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: <Widget>[
              Icon(Icons.medication, color: Colors.blueAccent, size: 28),
              SizedBox(width: 8),
              Text(
                "Medicine Availability",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.black87, size: 30),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    "Find Your Medicines",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Check availability and search by category",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: "Search medicine by name",
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.filter_list),
                filled: true,
                fillColor: Colors.blue.shade50,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Browse by Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Changed from 3 to 4 to make boxes smaller
                crossAxisSpacing: 8, // Adjusted spacing for smaller boxes
                mainAxisSpacing: 8, // Adjusted spacing for smaller boxes
                childAspectRatio: 1.0, // Ensures square boxes
              ),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          categories[index]["icon"] as IconData,
                          color: Colors.black87,
                          size: 28,
                        ), // Adjusted icon size slightly
                        SizedBox(height: 4), // Adjusted spacing
                        Text(
                          categories[index]["label"] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                12, // Adjusted font size for smaller boxes
                            fontWeight: FontWeight.w500,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 25),
            Text(
              "Previously Viewed Medicines",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: previouslyViewed.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, String> item = previouslyViewed[index];
                  Color statusColor = item["status"] == "Low Stock"
                      ? Colors.orange
                      : Colors.blueAccent;
                  return ListTile(
                    title: Text(
                      item["name"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    subtitle: Text(item["desc"]!),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        item["status"]!,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.cyan.shade100,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: "Book Consultation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "AI Symptom Checker",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: "Medicine Availability",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Health Records",
          ),
        ],
      ),
    );
  }
}
