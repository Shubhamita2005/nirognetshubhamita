// lib/screens/book_consultation_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ❌ REMOVED: import 'homepage.dart';

// Data model for a medical specialty. (Kept)
class Specialty {
  final IconData icon;
  final String name;

  const Specialty({required this.icon, required this.name});
}

// Data for medical specialties. (Kept)
const List<Specialty> kMedicalSpecialties = [
  Specialty(icon: Icons.favorite, name: 'Cardiology'),
  Specialty(icon: FontAwesomeIcons.bacteria, name: 'Dermatology'),
  Specialty(icon: FontAwesomeIcons.bone, name: 'Orthopedics'),
  Specialty(icon: Icons.psychology, name: 'Neurology'),
  Specialty(icon: Icons.child_care, name: 'Pediatrics'),
  Specialty(icon: Icons.woman, name: 'Gynecology'),
  Specialty(icon: Icons.remove_red_eye, name: 'Ophthalmology'),
  Specialty(icon: FontAwesomeIcons.brain, name: 'Psychiatry'),
  Specialty(icon: FontAwesomeIcons.stethoscope, name: 'General Medicine'),
  Specialty(icon: FontAwesomeIcons.tooth, name: 'Dentistry'),
];

// Widget for displaying an information chip (e.g., "10 Specialties"). (Kept)
class InfoChip extends StatelessWidget {
  final String text;
  const InfoChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ❌ REMOVED: The custom 'NavItem' widget. It was part of the old nav bar.

// ✅ CHANGED: Converted to a StatelessWidget
class BookConsultationScreen extends StatelessWidget {
  const BookConsultationScreen({super.key});

  // ❌ REMOVED: _selectedIndex variable and State class

  @override
  Widget build(BuildContext context) {
    // ❌ REMOVED: Scaffold wrapper
    // ✅ CHANGED: Returning SafeArea directly
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top icon and title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Row(
                    children: [
                      const Icon(
                        Icons.medical_information,
                        size: 24,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Book",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        " Consultation",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                "Find the right doctor for your needs",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink.shade800,
                ),
              ),
              Text(
                "Search from our network of specialists",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.pink.shade400,
                ),
              ),
              const SizedBox(height: 18),

              // Specialties and Doctors available chips
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: InfoChip(text: "10\nSpecialties")),
                  SizedBox(width: 20),
                  Flexible(child: InfoChip(text: "10\nDoctors\nAvailable")),
                ],
              ),

              const SizedBox(height: 20),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF9EE3E0),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search doctors by name",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.black87,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Choose Your Specialty",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink.shade800,
                ),
              ),

              const SizedBox(height: 16),

              // Grid for Specialties
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: kMedicalSpecialties.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final Specialty specialty = kMedicalSpecialties[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          specialty.icon,
                          color: Colors.blue.shade800,
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          specialty.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Emergency Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "EMERGENCY CONSULTATION",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 80), // Keep space for the main nav bar
            ],
          ),
        ),
      ),
    );
    // ❌ REMOVED: The entire 'bottomNavigationBar: Container(...)' block
  }
}