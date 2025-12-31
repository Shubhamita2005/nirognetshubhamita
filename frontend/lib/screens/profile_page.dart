import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String? errorMessage;

  // Edit mode states
  bool isEditingBasicInfo = false;
  bool isEditingHealthInfo = false;
  bool isSaving = false;

  // Text controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _bloodPressureController;

  String? _selectedGender;
  String? _selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProfile();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _contactController = TextEditingController();
    _addressController = TextEditingController();
    _bloodPressureController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _bloodPressureController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('🔵 [PROFILE_PAGE] Starting _loadProfile()');

      final accessToken = await _storage.read(key: 'access_token');

      if (!mounted) return;

      if (accessToken == null) {
        print('❌ [PROFILE_PAGE] No token found in storage');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Please login first')));
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      print('✅ [PROFILE_PAGE] Token found (length: ${accessToken.length})');

      final profile = await authService.getProfile(accessToken);

      if (!mounted) return;

      print('✅ [PROFILE_PAGE] Profile data received: $profile');

      setState(() {
        userProfile = profile;
        isLoading = false;

        // Update controllers with profile data
        _nameController.text = profile['name'] ?? '';
        _ageController.text = profile['age']?.toString() ?? '';
        _contactController.text = profile['contact'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _bloodPressureController.text = profile['blood_pressure'] ?? '';
        _selectedGender = profile['gender'];
        _selectedBloodGroup = profile['blood_group'];
      });

      print(
        '✅ [PROFILE_PAGE] Blood Group from server: ${profile['blood_group']}',
      );
      print(
        '✅ [PROFILE_PAGE] Blood Pressure from server: ${profile['blood_pressure']}',
      );
    } catch (e, stackTrace) {
      print('❌ [PROFILE_PAGE] Error loading profile: $e');
      print('❌ [PROFILE_PAGE] Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });

      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        await _storage.delete(key: 'access_token');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  // Save Basic Info
  Future<void> _saveBasicInfo() async {
    setState(() => isSaving = true);

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('No token found');

      final updatedData = {
        'name': _nameController.text.trim(),
        'age': _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null,
        'gender': _selectedGender,
        'contact': _contactController.text.trim(),
        'address': _addressController.text.trim(),
      };

      print('🔵 [PROFILE_PAGE] Updating basic info: $updatedData');

      await authService.updateProfile(token, updatedData);

      if (!mounted) return;

      // Update local userProfile
      setState(() {
        userProfile?['name'] = _nameController.text.trim();
        userProfile?['age'] = _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null;
        userProfile?['gender'] = _selectedGender;
        userProfile?['contact'] = _contactController.text.trim();
        userProfile?['address'] = _addressController.text.trim();
        isEditingBasicInfo = false;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Basic info updated successfully!'),
          backgroundColor: Color(0xFF3ECFCF),
        ),
      );

      // Reload profile to ensure data is synced
      await _loadProfile();
    } catch (e) {
      print('❌ [PROFILE_PAGE] Save error: $e');

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ FIXED: Save Health Info
  Future<void> _saveHealthInfo() async {
    setState(() => isSaving = true);

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('No token found');

      // ✅ Build the data to send
      final updatedData = {
        'blood_group': _selectedBloodGroup ?? '',
        'blood_pressure': _bloodPressureController.text.trim(),
      };

      print('🔵 [PROFILE_PAGE] Updating health info: $updatedData');
      print('🔵 [PROFILE_PAGE] Selected Blood Group: $_selectedBloodGroup');
      print(
        '🔵 [PROFILE_PAGE] Blood Pressure: ${_bloodPressureController.text}',
      );

      // ✅ Call the API
      await authService.updateHealthInfo(token, updatedData);

      print('✅ [PROFILE_PAGE] Health info API call successful');

      if (!mounted) return;

      // ✅ Update local state immediately
      setState(() {
        userProfile?['blood_group'] = _selectedBloodGroup;
        userProfile?['blood_pressure'] = _bloodPressureController.text.trim();
        isEditingHealthInfo = false;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health info updated successfully!'),
          backgroundColor: Color(0xFF3ECFCF),
        ),
      );

      // Reload profile to ensure data is synced
      await _loadProfile();
    } catch (e) {
      print('❌ [PROFILE_PAGE] Save health info error: $e');

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update health info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Cancel editing
  void _cancelBasicInfoEdit() {
    setState(() {
      isEditingBasicInfo = false;
      _nameController.text = userProfile?['name'] ?? '';
      _ageController.text = userProfile?['age']?.toString() ?? '';
      _contactController.text = userProfile?['contact'] ?? '';
      _addressController.text = userProfile?['address'] ?? '';
      _selectedGender = userProfile?['gender'];
    });
  }

  void _cancelHealthInfoEdit() {
    setState(() {
      isEditingHealthInfo = false;
      _bloodPressureController.text = userProfile?['blood_pressure'] ?? '';
      _selectedBloodGroup = userProfile?['blood_group'];
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      await _storage.delete(key: 'access_token');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3ECFCF),
        title: Text(
          'Profile',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProfile,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3ECFCF)),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Failed to Load Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: SelectableText(
                  errorMessage!,
                  style: TextStyle(
                    color: Colors.red[900],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3ECFCF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: const Color(0xFF3ECFCF),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF3ECFCF),
                    child: Text(
                      (userProfile?['name'] ?? 'G')[0].toUpperCase(),
                      style: GoogleFonts.roboto(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userProfile?['name'] ?? 'Guest User',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfile?['email'] ?? '',
                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Language Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.language,
                        color: Color(0xFF3ECFCF),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Language',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: userProfile?['language'] ?? 'English',
                    underline: Container(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF3ECFCF),
                    ),
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(value: 'हिन्दी', child: Text('हिन्दी')),
                      DropdownMenuItem(value: 'বাংলা', child: Text('বাংলা')),
                      DropdownMenuItem(
                        value: 'ગુજરાતી',
                        child: Text('ગુજરાતી'),
                      ),
                    ],
                    onChanged: (String? newLanguage) async {
                      if (newLanguage == null) return;

                      try {
                        final token = await _storage.read(key: 'access_token');
                        if (token == null) throw Exception('No token found');

                        await authService.updateProfile(token, {
                          'language': newLanguage,
                        });

                        if (mounted) {
                          setState(() {
                            userProfile?['language'] = newLanguage;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Language updated to $newLanguage'),
                              backgroundColor: const Color(0xFF3ECFCF),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update language: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Basic Info Section
            _buildBasicInfoSection(),
            const SizedBox(height: 25),

            // Health Info Section
            _buildHealthInfoSection(),
            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Basic Info Section
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Basic Info',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isEditingBasicInfo)
              IconButton(
                onPressed: () => setState(() => isEditingBasicInfo = true),
                icon: const Icon(Icons.edit, color: Color(0xFF3ECFCF)),
                tooltip: 'Edit',
              )
            else
              Row(
                children: [
                  TextButton(
                    onPressed: isSaving ? null : _cancelBasicInfoEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSaving ? null : _saveBasicInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3ECFCF),
                      foregroundColor: Colors.white,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildEditableField('Name', _nameController, isEditingBasicInfo),
              _buildEditableField(
                'Age',
                _ageController,
                isEditingBasicInfo,
                keyboardType: TextInputType.number,
              ),
              _buildGenderField(isEditingBasicInfo),
              _buildEditableField(
                'Contact',
                _contactController,
                isEditingBasicInfo,
                keyboardType: TextInputType.phone,
              ),
              _buildReadOnlyField('Email', userProfile?['email']),
              _buildEditableField(
                'Address',
                _addressController,
                isEditingBasicInfo,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Health Info Section
  Widget _buildHealthInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Health Info',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isEditingHealthInfo)
              IconButton(
                onPressed: () {
                  setState(() {
                    isEditingHealthInfo = true;
                    // Initialize with current values
                    _selectedBloodGroup = userProfile?['blood_group'];
                    _bloodPressureController.text =
                        userProfile?['blood_pressure'] ?? '';
                  });
                },
                icon: const Icon(Icons.edit, color: Color(0xFF3ECFCF)),
                tooltip: 'Edit',
              )
            else
              Row(
                children: [
                  TextButton(
                    onPressed: isSaving ? null : _cancelHealthInfoEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSaving ? null : _saveHealthInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3ECFCF),
                      foregroundColor: Colors.white,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildBloodGroupField(isEditingHealthInfo),
              _buildBloodPressureField(isEditingHealthInfo),
            ],
          ),
        ),
      ],
    );
  }

  // Gender Field
  Widget _buildGenderField(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Gender:',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      underline: Container(),
                      hint: const Text('Select Gender'),
                      items: ['Male', 'Female', 'Other'].map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                  )
                : Text(
                    _selectedGender ?? 'N/A',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }

  // Blood Group Field
  Widget _buildBloodGroupField(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Blood Group:',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedBloodGroup,
                      isExpanded: true,
                      underline: Container(),
                      hint: const Text('Select Blood Group'),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          })
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBloodGroup = newValue;
                        });
                        print(
                          '🔵 [PROFILE_PAGE] Blood Group selected: $newValue',
                        );
                      },
                    ),
                  )
                : Text(
                    userProfile?['blood_group'] ?? 'N/A',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }

  // Blood Pressure Field
  Widget _buildBloodPressureField(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Blood Pressure:',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: _bloodPressureController,
                    decoration: InputDecoration(
                      hintText: 'e.g., 120/80',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF3ECFCF),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      print('🔵 [PROFILE_PAGE] Blood Pressure changed: $value');
                    },
                  )
                : Text(
                    userProfile?['blood_pressure'] ?? 'N/A',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }

  // Editable Field Widget
  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isEditing, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    decoration: InputDecoration(
                      hintText: hintText,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF3ECFCF),
                          width: 2,
                        ),
                      ),
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? 'N/A' : controller.text,
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }

  // Read-only Field Widget
  Widget _buildReadOnlyField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
