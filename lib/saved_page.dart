import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'models/event_model.dart';
import 'event_details_page.dart';
import 'home.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    // Get the saved events from the HomePage state
    final homeState = context.findAncestorStateOfType<HomePageState>();
    final savedEvents = homeState?.savedEvents ?? [];

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
                  "Saved Events",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Luxenta",
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: isTablet ? 24 : 20),
            child: savedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.bookmark,
                          size: isTablet ? 96 : 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          "No saved events yet",
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      childAspectRatio: isTablet ? 0.75 : 0.7,
                      crossAxisSpacing: isTablet ? 24 : 16,
                      mainAxisSpacing: isTablet ? 24 : 16,
                    ),
                    itemCount: savedEvents.length,
                    itemBuilder: (context, index) {
                      final event = savedEvents[index];
                      return _buildSavedEventCard(context, event, isTablet);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedEventCard(
      BuildContext context, Event event, bool isTablet) {
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
                height: isTablet ? 180 : 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/error.jpg',
                    height: isTablet ? 180 : 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.ename,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
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
                            fontSize: isTablet ? 14 : 12,
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
}
