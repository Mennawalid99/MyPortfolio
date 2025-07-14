import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_event/login.dart';
import 'package:smart_event/home.dart';
import 'package:smart_event/my_bookings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from the API
  Future<void> _fetchUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url =
        Uri.parse('http://192.168.191.146:8000/api/user'); // API endpoint
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (!mounted) return;

      if (token == null) {
        setState(() {
          _errorMessage = 'User is not logged in. Please login.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add token to the request
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body)['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load user data.';
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
          ),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: isTablet ? 18 : 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // If user confirms logout
    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showFullScreenImage() {
    if (_userData != null && _userData!['profile_image_url'] != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 172, 219, 253),
                    Color(0xFFFFFFFF)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        _userData!['profile_image_url'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.black, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    Widget content;
    if (_isLoading) {
      content = Center(
        child: SizedBox(
          width: isTablet ? 40 : 30,
          height: isTablet ? 40 : 30,
          child: const CircularProgressIndicator(color: Colors.blue),
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: isTablet ? 32 : 20),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: _fetchUserData,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
              child: Column(
                children: [
                  SizedBox(height: isTablet ? 20 : 10),
                  // Profile Image
                  GestureDetector(
                    onTap: _showFullScreenImage,
                    child: Container(
                      width: isTablet ? 180 : 120,
                      height: isTablet ? 180 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _userData!['profile_image_url'] != null
                            ? Image.network(
                                _userData!['profile_image_url'],
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: isTablet ? 120 : 80,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 20),
                  // User Info
                  Text(
                    '${_userData!['fname']} ${_userData!['lname']}',
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Luxenta',
                    ),
                  ),
                  SizedBox(height: isTablet ? 40 : 30),
                  // Info Cards
                  Container(
                    padding: EdgeInsets.all(isTablet ? 28 : 20),
                    margin: EdgeInsets.only(bottom: isTablet ? 20 : 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 14 : 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(isTablet ? 14 : 10),
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                        SizedBox(width: isTablet ? 20 : 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: isTablet ? 8 : 5),
                              Text(
                                _userData!['email'],
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 28 : 20),
                    margin: EdgeInsets.only(bottom: isTablet ? 40 : 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 14 : 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(isTablet ? 14 : 10),
                          ),
                          child: Icon(
                            Icons.phone_outlined,
                            color: Colors.blue,
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                        SizedBox(width: isTablet ? 20 : 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: isTablet ? 8 : 5),
                              Text(
                                _userData!['phone'],
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Saved Events Button
                  Container(
                    width: double.infinity,
                    height: isTablet ? 70 : 56,
                    margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 80, 145, 219),
                          Colors.blueAccent
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        final homeState =
                            context.findAncestorStateOfType<HomePageState>();
                        if (homeState != null) {
                          homeState.navigateToTab(2);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      ),
                      child: Text(
                        'Saved Events',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Luxenta',
                        ),
                      ),
                    ),
                  ),
                  // My Bookings Button
                  Container(
                    width: double.infinity,
                    height: isTablet ? 70 : 56,
                    margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 80, 145, 219),
                          Colors.blueAccent
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyBookingsPage(),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      ),
                      child: Text(
                        'My Bookings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Luxenta',
                        ),
                      ),
                    ),
                  ),
                  // Logout Button
                  Container(
                    width: double.infinity,
                    height: isTablet ? 70 : 56,
                    margin: EdgeInsets.only(bottom: isTablet ? 24 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      border: Border.all(color: Colors.red.shade300, width: 1),
                    ),
                    child: MaterialButton(
                      onPressed: _logout,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Luxenta',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 172, 219, 253), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isTablet ? 90 : 70),
          child: Container(
            padding: EdgeInsets.only(top: isTablet ? 30 : 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 172, 219, 253),
                  Color.fromARGB(255, 172, 219, 253)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Padding(
                padding: EdgeInsets.only(top: isTablet ? 12 : 8),
                child: Text(
                  'Account Info',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Luxenta',
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: isTablet ? 24 : 20),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Add any cleanup here if needed
    super.dispose();
  }
}
