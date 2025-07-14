import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'models/event_model.dart';
import 'event_details_page.dart';
import 'api_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<Map<String, dynamic>> categories = [
    {"icon": Iconsax.money, "label": "Finance"},
    {"icon": Iconsax.cpu, "label": "Tech"},
    {"icon": Iconsax.health, "label": "Medical"},
    {"icon": Iconsax.music, "label": "Music"},
    {"icon": Iconsax.teacher, "label": "Course-Training"},
    {"icon": Iconsax.building_3, "label": "Real-Estate"},
    {"icon": Iconsax.box, "label": "Product-Demo"},
    {"icon": Iconsax.briefcase, "label": "Workshop"},
  ];

  List<Event> events = [];
  List<Event> filteredEvents = [];
  bool isLoading = true;
  String selectedCategory = "All";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await ApiService.getEvents();

      if (!mounted) return;

      setState(() {
        isLoading = false;
        if (result['success']) {
          events = result['data']
              .map<Event>((json) => Event.fromJson(json))
              .toList();
          filteredEvents = events;
        } else {
          // Show error message if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      print("Error in fetchEvents: $e");
    }
  }

  void filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        bool matchesSearch = event.ename
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            event.elocation.toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesCategory = selectedCategory == "All" ||
            event.ecategory.toLowerCase() == selectedCategory.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

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
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isTablet),
              _buildSearchBar(isTablet),
              _buildCategoryFilter(isTablet),
              Expanded(
                child: _buildEventsList(isTablet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Text(
        "Explore Events",
        style: TextStyle(
          fontSize: isTablet ? 36 : 28,
          fontWeight: FontWeight.bold,
          fontFamily: "Luxenta",
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      child: Container(
        height: isTablet ? 60 : 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              filterEvents();
            });
          },
          style: TextStyle(fontSize: isTablet ? 18 : 16),
          decoration: InputDecoration(
            hintText: "Search events...",
            hintStyle: TextStyle(fontSize: isTablet ? 18 : 16),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: isTablet ? 24 : 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 20,
              vertical: isTablet ? 18 : 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isTablet) {
    return Container(
      height: isTablet ? 50 : 40,
      margin: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip("All", true, isTablet: isTablet);
          }
          final category = categories[index - 1];
          return _buildCategoryChip(
            category["label"],
            false,
            icon: category["icon"],
            isTablet: isTablet,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isAll,
      {IconData? icon, required bool isTablet}) {
    final isSelected = selectedCategory == label;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = label;
            filterEvents();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isAll ? (isTablet ? 24 : 20) : (isTablet ? 20 : 16),
            vertical: isTablet ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 80, 145, 219)
                : Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
            border: Border.all(
              color: isSelected
                  ? const Color.fromARGB(255, 80, 145, 219)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isTablet ? 20 : 16,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                SizedBox(width: isTablet ? 8 : 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(bool isTablet) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: isTablet ? 40 : 30,
          height: isTablet ? 40 : 30,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (filteredEvents.isEmpty) {
      return Center(
        child: Text(
          "No events found",
          style: TextStyle(
            fontSize: isTablet ? 20 : 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return _buildEventCard(event, isTablet);
      },
    );
  }

  Widget _buildEventCard(Event event, bool isTablet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(event: event),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isTablet ? 20 : 16),
              ),
              child: Image.network(
                event.imageUrl,
                height: isTablet ? 300 : 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/error.jpg',
                    height: isTablet ? 300 : 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.ename,
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: isTablet ? 20 : 16,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 8 : 4),
                      Expanded(
                        child: Text(
                          event.elocation,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 80, 145, 219)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                    ),
                    child: Text(
                      event.ecategory,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: const Color.fromARGB(255, 80, 145, 219),
                        fontWeight: FontWeight.bold,
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
}
