import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final List<Map<String, dynamic>> categories = [
    {
      "icon": Iconsax.money,
      "label": "Finance",
      "isSelected": false,
    },
    {
      "icon": Iconsax.cpu,
      "label": "Tech",
      "isSelected": false,
    },
    {
      "icon": Iconsax.health,
      "label": "Medical",
      "isSelected": false,
    },
    {
      "icon": Iconsax.music,
      "label": "Music",
      "isSelected": false,
    },
    {
      "icon": Iconsax.teacher,
      "label": "Course-Training",
      "isSelected": false,
    },
    {
      "icon": Iconsax.building_3,
      "label": "Real-Estate",
      "isSelected": false,
    },
    {
      "icon": Iconsax.box,
      "label": "Product-Demo",
      "isSelected": false,
    },
    {
      "icon": Iconsax.briefcase,
      "label": "Workshop",
      "isSelected": false,
    },
  ];

  int selectedCount = 0;

  Future<void> _saveInterestsAndNavigate() async {
    // Save selected interests
    final prefs = await SharedPreferences.getInstance();
    final selectedInterests = categories
        .where((category) => category["isSelected"])
        .map((category) => category["label"].toString())
        .toList();

    await prefs.setStringList('user_interests', selectedInterests);

    // Get the user ID and save user-specific flag
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final userKey = 'user_${userId}_has_selected_interests';
      await prefs.setBool(userKey, true);
    }

    await prefs.setBool('has_selected_interests', true);

    if (!mounted) return;

    // Navigate to home page and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isTablet ? 60 : 40),
                Text(
                  "Choose Your Interests",
                  style: TextStyle(
                    fontSize: isTablet ? 36 : 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Luxenta',
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Text(
                  "Select categories you're interested in to personalize your event feed",
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: isTablet ? 60 : 40),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      childAspectRatio: isTablet ? 1.8 : 1.5,
                      crossAxisSpacing: isTablet ? 24 : 16,
                      mainAxisSpacing: isTablet ? 24 : 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            category["isSelected"] = !category["isSelected"];
                            selectedCount += category["isSelected"] ? 1 : -1;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: category["isSelected"]
                                ? const Color.fromARGB(255, 80, 145, 219)
                                    .withOpacity(0.2)
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(isTablet ? 20 : 15),
                            border: Border.all(
                              color: category["isSelected"]
                                  ? const Color.fromARGB(255, 80, 145, 219)
                                  : Colors.grey.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category["icon"],
                                size: isTablet ? 40 : 32,
                                color: category["isSelected"]
                                    ? const Color.fromARGB(255, 80, 145, 219)
                                    : Colors.grey,
                              ),
                              SizedBox(height: isTablet ? 12 : 8),
                              Text(
                                category["label"],
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w500,
                                  color: category["isSelected"]
                                      ? const Color.fromARGB(255, 80, 145, 219)
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 20),
                Container(
                  width: double.infinity,
                  height: isTablet ? 70 : 60,
                  margin: EdgeInsets.only(bottom: isTablet ? 32 : 20),
                  child: ElevatedButton(
                    onPressed:
                        selectedCount > 0 ? _saveInterestsAndNavigate : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 80, 145, 219),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      selectedCount > 0
                          ? "Continue with $selectedCount categories"
                          : "Select at least one category",
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Luxenta',
                      ),
                    ),
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
