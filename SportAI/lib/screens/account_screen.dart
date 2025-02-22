import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Add this import for ImageFilter
import '../services/auth_service.dart';
import 'career_screen.dart';
import '../main.dart';
import 'update_profile_screen.dart';
import 'settings_screen.dart';
import 'update_password_screen.dart';
import 'login_screen.dart'; // Add this import if not already present

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/user/account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 100.0, // Reduced from 120.0
                  floating: false,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade900.withOpacity(0.8),
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 8), // Reduced padding
                      child: Text(
                        userData['name'] ?? 'User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        SizedBox(height: 24),
                        _buildInfoCard(),
                        SizedBox(height: 24),
                        _buildQuickActions(),
                        SizedBox(height: 24),
                        _buildAccountActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    String? profilePicture = userData['profile_picture'];
    String imageUrl = profilePicture != null && profilePicture.isNotEmpty
        ? 'http://localhost:5000/static/user/profile_pictures/$profilePicture'
        : '';

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.transparent,
            backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: profilePicture == null || profilePicture.isEmpty
                ? Text(
                    userData['name']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${userData['username'] ?? 'username'}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                userData['email'] ?? 'email@example.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionTile(
          'Career\nGrowth',
          Icons.trending_up,
          Colors.blue.shade700,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CareerScreen()),
          ),
        ),
        _buildActionTile(
          'Edit\nProfile',
          Icons.edit,
          Colors.green.shade700,
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateProfileScreen(userData: userData),
              ),
            );
            if (result == true) {
              _fetchUserData(); // Refresh user data after update
            }
          },
        ),
        _buildActionTile(
          'Update\nPassword',
          Icons.lock_outline,
          Colors.orange.shade700,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpdatePasswordScreen()),
          ),
        ),
        _buildActionTile(
          'Settings\n ',
          Icons.settings,
          Colors.purple.shade700,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        _buildDangerButton(
          'Delete Account',
          Icons.delete_forever,
          Colors.red.shade700,
          _showDeleteAccountConfirmation,
        ),
        SizedBox(height: 12),
        _buildDangerButton(
          'Logout',
          Icons.logout,
          Colors.grey.shade700,
          _logout,
        ),
      ],
    );
  }

  Widget _buildDangerButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.grey[900],
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone. Please enter your password to confirm.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              _buildPasswordField(
                label: 'Password',
                controller: passwordController,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[400],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final token = await AuthService.getToken();
                          final response = await http.delete(
                            Uri.parse('http://localhost:5000/api/user/account'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: json.encode({
                              'password': passwordController.text,
                            }),
                          );

                          if (response.statusCode == 200) {
                            await AuthService.removeToken();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoginScreen()), // Changed to LoginScreen
                              (route) => false,
                            );
                          } else {
                            final responseData = json.decode(response.body);
                            throw Exception(responseData['error'] ??
                                'Failed to delete account');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/user/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await AuthService.removeToken();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen()), // Changed to LoginScreen
          (route) => false,
        );
      } else {
        throw Exception('Failed to logout');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error logging out'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[900]!, Colors.grey[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildModernInfoRow(
                    Icons.phone, 'Phone', userData['phone'] ?? 'N/A'),
                SizedBox(height: 16),
                _buildModernInfoRow(Icons.calendar_today, 'Birth Date',
                    userData['dob'] ?? 'N/A'),
                SizedBox(height: 16),
                _buildModernInfoRow(
                  Icons.person,
                  'Gender',
                  (userData['gender'] ?? 'N/A').toString().toUpperCase(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    // Format the date if this is the Birth Date row
    String displayValue = value;
    if (label == 'Birth Date' && value != 'N/A') {
      displayValue = value.split('T')[0]; // Remove time portion
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.grey[850],
      ),
    );
  }
}
