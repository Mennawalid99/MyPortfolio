import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'models/event_model.dart';
import 'event_details_page.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final List<Event> events;

  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.events,
  });

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
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Padding(
                padding: EdgeInsets.only(top: isTablet ? 12 : 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      categoryIcon,
                      color: Colors.black,
                      size: isTablet ? 32 : 24,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      categoryName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isTablet ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Luxenta",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: isTablet ? 24 : 20),
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.calendar_1,
                          size: isTablet ? 96 : 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          "No events in this category",
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventCard(context, event, isTablet);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, bool isTablet) {
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
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(isTablet ? 20 : 16),
              ),
              child: Image.network(
                event.imageUrl,
                width: isTablet ? 140 : 100,
                height: isTablet ? 140 : 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/error.jpg',
                    width: isTablet ? 140 : 100,
                    height: isTablet ? 140 : 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
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
                          size: isTablet ? 18 : 14,
                          color: const Color.fromARGB(255, 80, 145, 219),
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
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
            ),
            Padding(
              padding: EdgeInsets.only(right: isTablet ? 16 : 12),
              child: Icon(
                Iconsax.arrow_right_3,
                color: const Color.fromARGB(255, 80, 145, 219),
                size: isTablet ? 28 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
