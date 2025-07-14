import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_event/api_service.dart';
import 'package:smart_event/home.dart';
import 'package:smart_event/interests_page.dart';
import 'signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    setState(() => _isLoading = false);

    final userData = await ApiService.getUserData();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (userData.containsKey('id')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print("Session expired or no session found.");
    }
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        // Check if this is user's first login
        final prefs = await SharedPreferences.getInstance();
        final isFirstLogin =
            !(prefs.getBool('has_selected_interests') ?? false);

        if (!mounted) return;

        // Navigate to appropriate page based on whether it's first login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                isFirstLogin ? const InterestsPage() : const HomePage(),
          ),
          (route) => false,
        );
      } else {
        _showErrorDialog(response['message']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("An error occurred. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Error",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "OK",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      loginUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
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
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 60 : 100),
                    // Logo or App Icon
                    Container(
                      width: isTablet ? 120 : 100,
                      height: isTablet ? 120 : 100,
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
                      child: Icon(
                        Icons.event,
                        size: isTablet ? 60 : 50,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 30),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: isTablet ? 36 : 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isTablet ? 15 : 10),
                    Text(
                      "Login to your account",
                      style: TextStyle(
                          fontSize: isTablet ? 18 : 15, color: Colors.black54),
                    ),
                    SizedBox(height: isTablet ? 50 : 40),
                    // Email Input
                    makeInput(
                      label: "Email",
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      isTablet: isTablet,
                    ),
                    // Password Input
                    makeInput(
                      label: "Password",
                      controller: _passwordController,
                      obsecureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      isTablet: isTablet,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                          size: isTablet ? 24 : 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 30),
                    // Login Button
                    Container(
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
                        onPressed: _isLoading ? null : _submitForm,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: isTablet ? 30 : 24,
                                height: isTablet ? 30 : 24,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: isTablet ? 22 : 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 30 : 20),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                              fontSize: isTablet ? 18 : 15,
                              color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          ),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 40 : 30),
                    // Illustration
                    Container(
                      width: double.infinity,
                      height: isTablet ? 300 : 200,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/back.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
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
  bool obsecureText = false,
  required TextEditingController controller,
  IconData? prefixIcon,
  Widget? suffixIcon,
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
      SizedBox(height: isTablet ? 12 : 8),
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label cannot be empty";
            }
            if (label == "Email" && !value.contains("@")) {
              return "Please enter a valid email";
            }
            return null;
          },
          style: TextStyle(
            fontSize: isTablet ? 18 : 15,
          ),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey, size: isTablet ? 24 : 20)
                : null,
            suffixIcon: suffixIcon,
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
          ),
        ),
      ),
      SizedBox(height: isTablet ? 25 : 20),
    ],
  );
}
