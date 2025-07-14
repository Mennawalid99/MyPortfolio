import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_event/api_service.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  bool isLoading = false;
  String? _emailError;
  String? _phoneError;

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Select Profile Picture",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image")),
      );
    }
  }

  Future<void> registerUser() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                "Please upload a profile picture",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      _emailError = null;
      _phoneError = null;
    });

    try {
      final response = await ApiService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        role: "user",
        profileImage: _selectedImage!,
      );

      setState(() {
        isLoading = false;
      });

      if (response['success']) {
        if (!mounted) return;

        // Show success message in SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  "Registration successful! Please login.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate to login page after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        });
      } else {
        if (response.containsKey('errors')) {
          setState(() {
            if (response['errors'].containsKey('email')) {
              _emailError = response['errors']['email'][0];
            }
            if (response['errors'].containsKey('phone')) {
              _phoneError = response['errors']['phone'][0];
            }
          });

          // Show error message in SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    "Please check the form for errors",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    response['message'] ?? "Registration failed",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                "An error occurred. Please try again.",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      registerUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 172, 219, 253), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? screenSize.width * 0.15 : 40,
                vertical: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isTablet ? 40 : 60),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: isTablet ? 36 : 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: isTablet ? 15 : 10),
                          Text(
                            "Create your account",
                            style: TextStyle(
                                fontSize: isTablet ? 18 : 15,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 30),

                    // Profile Picture Selection
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            Container(
                              width: isTablet ? 140 : 120,
                              height: isTablet ? 140 : 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: isTablet ? 90 : 80,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(isTablet ? 10 : 8),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: isTablet ? 24 : 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 30),

                    // Form Fields
                    makeInput(
                      label: "First Name",
                      controller: _firstNameController,
                      isTablet: isTablet,
                    ),
                    makeInput(
                      label: "Last Name",
                      controller: _lastNameController,
                      isTablet: isTablet,
                    ),
                    makeInput(
                      label: "Email",
                      controller: _emailController,
                      errorText: _emailError,
                      isTablet: isTablet,
                    ),
                    makeInput(
                      label: "Phone Number",
                      controller: _phoneController,
                      errorText: _phoneError,
                      isTablet: isTablet,
                    ),
                    makeInput(
                      label: "Password",
                      controller: _passwordController,
                      obsecureText: true,
                      isTablet: isTablet,
                    ),
                    makeInput(
                      label: "Confirm Password",
                      controller: _confirmPasswordController,
                      obsecureText: true,
                      isTablet: isTablet,
                    ),

                    SizedBox(height: isTablet ? 40 : 30),

                    // Sign Up Button
                    Center(
                      child: isLoading
                          ? SizedBox(
                              width: isTablet ? 30 : 24,
                              height: isTablet ? 30 : 24,
                              child: const CircularProgressIndicator(
                                  color: Colors.blue),
                            )
                          : Container(
                              width: double.infinity,
                              height: isTablet ? 70 : 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.blueAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                height: isTablet ? 70 : 60,
                                onPressed: _submitForm,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),

                    SizedBox(height: isTablet ? 30 : 20),

                    // Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                                fontSize: isTablet ? 18 : 15,
                                color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget makeInput({
  required String label,
  required TextEditingController controller,
  bool obsecureText = false,
  String? errorText,
  bool isTablet = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 18 : 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: isTablet ? 8 : 5),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obsecureText,
          style: TextStyle(
            fontSize: isTablet ? 18 : 15,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label cannot be empty";
            }
            if (label == "Email" && !value.contains("@")) {
              return "Please enter a valid email";
            }
            if (label == "Confirm Password" && value != controller.text) {
              return "Passwords do not match";
            }
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 25 : 20,
              vertical: isTablet ? 20 : 15,
            ),
            errorText: errorText,
            errorStyle: TextStyle(
              color: Colors.red,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ),
      ),
      SizedBox(height: isTablet ? 25 : 20),
    ],
  );
}
