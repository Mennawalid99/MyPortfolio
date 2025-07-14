import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_event/AllEventsPage.dart';
import 'models/event_model.dart';
import 'event_details_page.dart';
import 'explore_page.dart';
import 'saved_page.dart';
import 'profile_page.dart';
import 'api_service.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Event> events = [];
  List<Event> filteredEvents = [];
  Set<int> savedEventIds = {};
  bool isLoading = true;
  int _selectedIndex = 0;
  DateTime? _lastPressedAt;
  String searchQuery = '';
  String? selectedCategory;
  int _notificationCount = 0;

  final List<Widget> _pages = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchEvents().then((_) {
      filterEvents();
    });
    _loadSavedEvents();
    _fetchNotificationCount();
  }

  Future<void> _fetchNotificationCount() async {
    final notifications = await ApiService.getAllNotifications();
    if (!mounted) return;
    setState(() {
      _notificationCount = notifications.length;
    });
  }

  void _toggleSaveEvent(Event event) async {
    setState(() {
      if (savedEventIds.contains(event.id)) {
        savedEventIds.remove(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event removed from saved'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        savedEventIds.add(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
    await ApiService.saveEventIds(savedEventIds);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    _pages.clear();
    _pages.add(_buildHomePage(isTablet));
    _pages.add(const ExplorePage());
    _pages.add(const SavedPage());
    _pages.add(ProfilePage());

    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) >
                const Duration(seconds: 2)) {
          _lastPressedAt = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _pages[_selectedIndex]),
        bottomNavigationBar: _buildBottomNavigationBar(isTablet),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color.fromARGB(255, 172, 219, 253)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 80, 145, 219),
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: isTablet ? 14 : 12,
        unselectedFontSize: isTablet ? 14 : 12,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home, size: isTablet ? 28 : 24),
            activeIcon: Icon(Iconsax.home_15, size: isTablet ? 28 : 24),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.discover, size: isTablet ? 28 : 24),
            activeIcon: Icon(Iconsax.discover5, size: isTablet ? 28 : 24),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.bookmark, size: isTablet ? 28 : 24),
            activeIcon: Icon(Iconsax.bookmark_25, size: isTablet ? 28 : 24),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle, size: isTablet ? 28 : 24),
            activeIcon: Icon(Iconsax.profile_circle5, size: isTablet ? 28 : 24),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(bool isTablet) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 172, 219, 253), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isTablet),
            SizedBox(height: isTablet ? 32 : 24),
            _buildSearchBar(isTablet),
            SizedBox(height: isTablet ? 40 : 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              child: Text(
                "Categories",
                style: TextStyle(
                  fontSize: isTablet ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Luxenta",
                ),
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            _buildCategories(isTablet),
            SizedBox(height: isTablet ? 40 : 32),
            _buildUpcomingEvents(isTablet),
            SizedBox(height: isTablet ? 32 : 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Smart Event",
            style: TextStyle(
              fontSize: isTablet ? 32 : 25,
              fontWeight: FontWeight.bold,
              fontFamily: "Luxenta",
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Iconsax.notification,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  ).then((_) => _fetchNotificationCount());
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 4 : 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: isTablet ? 20 : 16,
                      minHeight: isTablet ? 20 : 16,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 12 : 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: isTablet ? 18 : 16),
                decoration: InputDecoration(
                  hintText: "Search for events...",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: isTablet ? 18 : 16,
                  ),
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
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    filterEvents();
                  });
                },
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Iconsax.setting_4,
                color: Colors.grey,
                size: isTablet ? 24 : 20,
              ),
              offset: Offset(0, isTablet ? 60 : 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              ),
              onSelected: (String value) {
                setState(() {
                  selectedCategory = value == 'All' ? null : value;
                  filterEvents();
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'All',
                  child: Text(
                    'All Categories',
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Finance',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.money,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Finance',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Tech',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.cpu,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Tech',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Medical',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.health,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Medical',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Music',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.music,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Music',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Course-Training',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.teacher,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Course-Training',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Real-Estate',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.building_3,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Real-Estate',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Product-Demo',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.box,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Product-Demo',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Workshop',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.briefcase,
                        size: isTablet ? 24 : 20,
                        color: const Color.fromARGB(255, 80, 145, 219),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Workshop',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: isTablet ? 12 : 8),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> allCategories = [
    {"icon": Iconsax.money, "label": "Finance", "route": "/finance"},
    {"icon": Iconsax.cpu, "label": "Tech", "route": "/tech"},
    {"icon": Iconsax.health, "label": "Medical", "route": "/medical"},
    {"icon": Iconsax.music, "label": "Music", "route": "/music"},
    {
      "icon": Iconsax.teacher,
      "label": "Course-Training",
      "route": "/course-training"
    },
    {
      "icon": Iconsax.building_3,
      "label": "Real-Estate",
      "route": "/real-estate"
    },
    {"icon": Iconsax.box, "label": "Product-Demo", "route": "/product-demo"},
    {"icon": Iconsax.briefcase, "label": "Workshop", "route": "/workshop"},
  ];

  Future<List<Map<String, dynamic>>> _getSortedCategories() async {
    return ApiService.getSortedCategories(allCategories);
  }

  Widget _buildCategories(bool isTablet) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSortedCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: isTablet ? 160 : 120,
            child: Center(
              child: SizedBox(
                width: isTablet ? 40 : 30,
                height: isTablet ? 40 : 30,
                child: const CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: isTablet ? 160 : 120,
            child: Center(
              child: Text(
                "Error loading categories",
                style: TextStyle(fontSize: isTablet ? 18 : 14),
              ),
            ),
          );
        }

        final categories = snapshot.data ?? allCategories;

        return SizedBox(
          height: isTablet ? 160 : 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: EdgeInsets.only(right: isTablet ? 32 : 24),
                child: GestureDetector(
                  onTap: () {
                    final categoryEvents = events
                        .where((event) =>
                            event.ecategory.toLowerCase() ==
                            category["label"].toString().toLowerCase())
                        .toList();

                    Navigator.pushNamed(
                      context,
                      category["route"],
                      arguments: categoryEvents,
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: isTablet ? 100 : 80,
                        height: isTablet ? 100 : 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          category["icon"],
                          size: isTablet ? 45 : 35,
                          color: const Color.fromARGB(255, 80, 145, 219),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Text(
                        category["label"],
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingEvents(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upcoming Events",
                style: TextStyle(
                  fontSize: isTablet ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Luxenta",
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AllEventsPage(events: filteredEvents),
                    ),
                  );
                },
                child: Text(
                  "See all",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 80, 145, 219),
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 18 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 24 : 16),
        isLoading
            ? Center(
                child: SizedBox(
                  width: isTablet ? 40 : 30,
                  height: isTablet ? 40 : 30,
                  child: const CircularProgressIndicator(),
                ),
              )
            : filteredEvents.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Text(
                        "No events found",
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: isTablet ? 400 : 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(filteredEvents[index], isTablet);
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildEventCard(Event event, bool isTablet) {
    final bool isSaved = savedEventIds.contains(event.id);

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
        width: isTablet ? 280 : 220,
        height: isTablet ? 360 : 280,
        margin: EdgeInsets.only(right: isTablet ? 24 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          color: Colors.white,
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isTablet ? 20 : 16),
                  ),
                  child: Image.network(
                    event.imageUrl,
                    height: isTablet ? 200 : 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/error.jpg',
                        height: isTablet ? 200 : 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: isTablet ? 12 : 8,
                  right: isTablet ? 12 : 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Iconsax.bookmark,
                        color: isSaved
                            ? const Color.fromARGB(255, 80, 145, 219)
                            : Colors.grey,
                        size: isTablet ? 24 : 20,
                      ),
                      onPressed: () => _toggleSaveEvent(event),
                      constraints: BoxConstraints(
                        minWidth: isTablet ? 44 : 36,
                        minHeight: isTablet ? 44 : 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.ename,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // navigate to a specific tab
  void navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // filter events
  Future<void> filterEvents() async {
    if (!mounted) return;

    final filtered = await ApiService.filterAndSortEvents(
      events: events,
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
    );

    if (!mounted) return;

    setState(() {
      filteredEvents = filtered.cast<Event>();
    });
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
          filterEvents();
        }
      });
    } catch (e) {
      print("Error fetching events: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load saved events
  Future<void> _loadSavedEvents() async {
    final savedIds = await ApiService.getSavedEventIds();
    if (!mounted) return;
    setState(() {
      savedEventIds = savedIds;
    });
  }

  // Get saved events
  List<Event> get savedEvents =>
      events.where((event) => savedEventIds.contains(event.id)).toList();
}
