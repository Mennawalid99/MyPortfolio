import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_event/ask_question_page.dart';
import 'package:smart_event/login.dart';
import 'package:smart_event/make_review_page.dart';
import 'package:smart_event/models/event_model.dart';
import 'package:smart_event/signup.dart';
import 'package:smart_event/pages/finance_category_page.dart';
import 'package:smart_event/pages/tech_category_page.dart';
import 'package:smart_event/pages/medical_category_page.dart';
import 'package:smart_event/pages/music_category_page.dart';
import 'package:smart_event/pages/course_training_category_page.dart';
import 'package:smart_event/pages/real_estate_category_page.dart';
import 'package:smart_event/pages/product_demo_category_page.dart';
import 'package:smart_event/pages/workshop_category_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Event',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Luxenta',
      ),
      home: const MyHomePage(title: 'Smart Event'),
      routes: {
        '/makeReview': (context) => MakeReviewPage(
              event: ModalRoute.of(context)!.settings.arguments as Event,
            ),
        '/askQuestion': (context) => AskQuestionPage(
              event: ModalRoute.of(context)!.settings.arguments as Event,
            ),
        '/finance': (context) => FinanceCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
        '/tech': (context) => TechCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
        '/medical': (context) => MedicalCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
        '/music': (context) => MusicCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
        '/course-training': (context) => CourseTrainingCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
        '/real-estate': (context) => RealEstateCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
        '/product-demo': (context) => ProductDemoCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
        '/workshop': (context) => WorkshopCategoryPage(
              events: ModalRoute.of(context)!.settings.arguments as List<Event>,
            ),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 172, 219, 253), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
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
                      child: const Icon(
                        Icons.event,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontFamily: "Luxenta",
                        fontWeight: FontWeight.bold,
                        fontSize: 45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Where Every Event Comes\n to Life Effortlessly Organized!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Luxenta pro",
                        color: Colors.grey[700],
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Lottie.asset(
                    "assets/Animation - 1.json",
                    fit: BoxFit.contain,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 60,
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
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontFamily: "Luxenta",
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontFamily: "Luxenta",
                            fontSize: 18,
                            color: Colors.blue,
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
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController nextpage = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 172, 219, 253), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: nextpage,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildOnboardingPage(
                  animation: "assets/Animation - 1.json",
                  title: "Plan Events Effortlessly",
                  subtitle:
                      "Your ultimate tool for organizing events\nwith ease and precision.",
                ),
                _buildOnboardingPage(
                  animation: "assets/Animation - 2.json",
                  title: "Seamless Conference Experience",
                  subtitle:
                      "Stay informed, connected,\nand on time at every event.",
                ),
                _buildOnboardingPage(
                  animation: "assets/Animation - 3.json",
                  title: "Instant Feedback \nMade Simple",
                  subtitle:
                      "Capture insights and improve with\nreal-time feedback tools.",
                ),
              ],
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.blue
                              : Colors.blue.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      width: double.infinity,
                      height: 60,
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
                        onPressed: () {
                          if (_currentPage < 2) {
                            nextpage.animateToPage(
                              _currentPage + 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _currentPage == 2 ? "Get Started" : "Next",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: "Luxenta",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String animation,
    required String title,
    required String subtitle,
  }) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isTablet ? 90 : 5),
          Lottie.asset(
            animation,
            height:
                isTablet ? screenSize.height * 0.4 : screenSize.height * 0.35,
            fit: BoxFit.contain,
          ),
          SizedBox(height: isTablet ? 40 : 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 36 : 28,
              fontFamily: "Luxenta",
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 30 : 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontFamily: "Luxenta pro",
              color: Colors.black54,
            ),
          ),
          SizedBox(height: isTablet ? 80 : 60),
        ],
      ),
    );
  }
}
