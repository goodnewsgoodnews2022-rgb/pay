// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  Uint8List? _pickedImageBytes; 
  String? _serverImageUrl;

  // Form Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  
  String _selectedGender = 'Male';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
    
    _loadUserProfileData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _accountNumberController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Fetch real user data from Supabase Auth and Public Tables
  Future<void> _loadUserProfileData() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      _userEmail = user.email ?? '';

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        setState(() {
          _fullNameController.text = profile['full_name'] ?? '';
          _phoneController.text = profile['mobile_number'] ?? '';
          _addressController.text = profile['address'] ?? '';
          _dobController.text = profile['date_of_birth'] ?? '';
          _selectedGender = profile['gender'] ?? 'Male';
          _serverImageUrl = profile['avatar_url'];
          
          _accountNumberController.text = profile['account_number'] ?? 
              '102${(user.id.hashCode % 10000000).toString().padLeft(7, '0')}';
        });
      }
    } catch (e) {
      _showSnackbar('Error loading profile configurations: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Select image from device gallery safely using memory bytes
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, 
        maxWidth: 510,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
        });
        await _uploadAvatarToSupabaseBucket(pickedFile);
      }
    } catch (e) {
      _showSnackbar('Image collection rejected: $e', isError: true);
    }
  }

  /// Upload image binary directly to Supabase Storage Bucket
  Future<void> _uploadAvatarToSupabaseBucket(XFile pickedFile) async {
    if (_pickedImageBytes == null) return;
    
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final fileExtension = pickedFile.name.split('.').last;
      final pathName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await _supabase.storage.from('avatars').uploadBinary(
            pathName,
            _pickedImageBytes!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(pathName);

      setState(() {
        _serverImageUrl = publicUrl;
      });
      _showSnackbar('Profile photo uploaded successfully!');
    } catch (e) {
      _showSnackbar('Storage bucket upload configuration failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Persist mutated forms to Public Profile rows
  Future<void> _updateProfileDatabaseRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('profiles').upsert({
        'id': userId,
        'full_name': _fullNameController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
        'mobile_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'date_of_birth': _dobController.text.trim(),
        'gender': _selectedGender,
        'avatar_url': _serverImageUrl,
      });

      _showSnackbar('Account profile preferences updated successfully!');
    } catch (e) {
      _showSnackbar('Database record updates encountered an error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Color(0xFF00E676), size: 28),
            onPressed: _isLoading ? null : _updateProfileDatabaseRecord,
          )
        ],
      ),
      body: _isLoading && _fullNameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                children: [
                  // --- Avatar Section ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: theme.cardColor,
                          backgroundImage: _pickedImageBytes != null
                              ? MemoryImage(_pickedImageBytes!)
                              : (_serverImageUrl != null ? NetworkImage(_serverImageUrl!) : null) as ImageProvider?,
                          child: _pickedImageBytes == null && _serverImageUrl == null
                              ? Icon(Icons.person_rounded, size: 60, color: theme.hintColor)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: InkWell(
                            onTap: _pickImageFromGallery,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.onPrimary, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Account Number Display Card ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FINTECH ACCOUNT NUMBER',
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: 10,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _accountNumberController.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.copy_rounded, color: theme.hintColor),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _accountNumberController.text));
                            _showSnackbar('Account number copied to clipboard.');
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Form Section ---
                  _buildSectionLabel(context, 'PERSONAL INFORMATION'),
                  _buildInputField(context, label: 'Full Name', controller: _fullNameController, icon: Icons.badge_outlined),
                  _buildInputField(context, label: 'Mobile Number', controller: _phoneController, icon: Icons.phone_android, keyboardType: TextInputType.phone),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      dropdownColor: theme.cardColor,
                      decoration: _inputDecoration(context, 'Gender', Icons.wc_outlined),
                      items: ['Male', 'Female', 'Other'].map((String category) {
                        return DropdownMenuItem(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedGender = value!),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: _inputDecoration(context, 'Date of Birth', Icons.calendar_today_outlined),
                      onTap: _selectDateOfBirth,
                    ),
                  ),

                  _buildInputField(context, label: 'Residential Address', controller: _addressController, icon: Icons.home_outlined, maxLines: 2),

                  _buildSectionLabel(context, 'SYSTEM GATEWAY INTEGRATION'),
                  TextFormField(
                    initialValue: _userEmail,
                    readOnly: true,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6)),
                    decoration: _inputDecoration(context, 'Registered Email Address', Icons.email_outlined).copyWith(
                      filled: true,
                      fillColor: theme.disabledColor.withOpacity(0.05),
                      helperText: 'Email parameters cannot be changed manually without system authorization.',
                      helperStyle: TextStyle(color: theme.hintColor.withOpacity(0.7), fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- Primary Action Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: isDark ? 0 : 2,
                    ),
                    onPressed: _isLoading ? null : _updateProfileDatabaseRecord,
                    child: _isLoading 
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                        : const Text('Save Profile Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary, 
          fontSize: 11, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(context, label, icon),
        validator: (value) => value == null || value.trim().isEmpty ? '$label cannot be left empty.' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData prefixIcon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.hintColor, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: theme.hintColor, size: 20),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.error, width: 2)),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF00E676), 
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}