import 'package:flutter/material.dart';
import 'event_details_page.dart';
import 'models/event_model.dart';
import 'package:iconsax/iconsax.dart';

class AllEventsPage extends StatelessWidget {
  final List<Event> events;

  const AllEventsPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(isTablet ? kToolbarHeight * 1.2 : kToolbarHeight),
        child: Container(
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
            title: Text(
              "All Events",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: isTablet ? 28 : 24,
                fontFamily: "Luxenta",
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Iconsax.arrow_left,
                color: Colors.black,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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
        child: events.isEmpty
            ? Center(
                child: Text(
                  "No events available",
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
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
    );
  }

  /// building event
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
        margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
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
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: isTablet ? 18 : 14,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: isTablet ? 8 : 4),
                        Expanded(
                          child: Text(
                            event.elocation,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.grey,
                            ),
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
                color: Colors.blueAccent,
                size: isTablet ? 28 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
