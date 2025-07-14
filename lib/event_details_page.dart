import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/event_model.dart';
import 'package:iconsax/iconsax.dart';
import 'reviews_page.dart';
import 'api_service.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  void _handleBooking(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: const Text("Are you sure you want to book this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Book"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.sendBookingRequest(widget.event.id);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booked successfully! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to book the event'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<dynamic>> _fetchReviews(int eventId) async {
    return ApiService.getEventReviews(eventId);
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) {
      return 'N/A'; // Or a suitable default value
    }
    try {
      final DateTime date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, y').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    // Format the dates for better readability
    String formattedStartDate =
        DateFormat('EEE, MMM d, y').format(widget.event.estartTime);
    String formattedStartTime =
        DateFormat('hh:mm a').format(widget.event.estartTime);
    String formattedEndDate =
        DateFormat('EEE, MMM d, y').format(widget.event.eendTime);
    String formattedEndTime =
        DateFormat('hh:mm a').format(widget.event.eendTime);

    // Create the combined date-time strings
    String startDateTime = "$formattedStartDate at $formattedStartTime";
    String endDateTime =
        widget.event.estartTime.day == widget.event.eendTime.day
            ? formattedEndTime
            : "$formattedEndDate at $formattedEndTime";

    DateTime now = DateTime.now();
    bool eventEnded = now.isAfter(widget.event.eendTime);
    bool eventOngoing = now.isAfter(widget.event.estartTime) &&
        now.isBefore(widget.event.eendTime);
    bool eventNotStarted = now.isBefore(widget.event.estartTime);

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 1,
          title: Text(
            widget.event.ename,
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Luxenta",
              fontSize: isTablet ? 28 : 24,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left,
              color: Colors.black,
              size: isTablet ? 28 : 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 24 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 12),
                        child: Image.network(
                          widget.event.imageUrl,
                          height: isTablet ? 300 : 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/error.jpg',
                              height: isTablet ? 300 : 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 30 : 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 30 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.ename,
                              style: TextStyle(
                                fontSize: isTablet ? 32 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isTablet ? 20 : 14),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.location,
                                  color: Colors.red,
                                  size: isTablet ? 24 : 20,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Expanded(
                                  child: Text(
                                    widget.event.elocation,
                                    style:
                                        TextStyle(fontSize: isTablet ? 20 : 16),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Iconsax.clock,
                                  color: Colors.blue,
                                  size: isTablet ? 24 : 20,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Starts: ",
                                            style: TextStyle(
                                              fontSize: isTablet ? 20 : 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              startDateTime,
                                              style: TextStyle(
                                                fontSize: isTablet ? 20 : 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isTablet ? 8 : 4),
                                      Row(
                                        children: [
                                          Text(
                                            "Ends: ",
                                            style: TextStyle(
                                              fontSize: isTablet ? 20 : 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              endDateTime,
                                              style: TextStyle(
                                                fontSize: isTablet ? 20 : 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
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
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isTablet ? 12 : 8),
                          Text(
                            widget.event.edescription,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    FutureBuilder<List<dynamic>>(
                      future: _fetchReviews(widget.event.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              width: isTablet ? 40 : 30,
                              height: isTablet ? 40 : 30,
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildReviewsSection(snapshot.data ?? []);
                      },
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    Container(
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
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: eventEnded
                                      ? null
                                      : () => _handleBooking(context),
                                  icon: Icon(
                                    Iconsax.ticket,
                                    size: isTablet ? 24 : 20,
                                  ),
                                  label: Text(
                                    eventEnded ? "Event Ended" : "Book Now",
                                    style:
                                        TextStyle(fontSize: isTablet ? 22 : 18),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: eventEnded
                                        ? const Color.fromARGB(
                                            255, 222, 222, 222)
                                        : const Color.fromARGB(
                                            255, 80, 145, 219),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 18 : 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          isTablet ? 16 : 12),
                                    ),
                                    elevation: 5,
                                    disabledBackgroundColor:
                                        const Color.fromARGB(
                                            255, 232, 232, 232),
                                  ),
                                ),
                              ),
                              if (eventOngoing && !eventEnded) ...[
                                SizedBox(width: isTablet ? 16 : 10),
                                Container(
                                  height: isTablet ? 60 : 50,
                                  width: isTablet ? 60 : 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.question_mark,
                                      color: Colors.blue,
                                      size: isTablet ? 28 : 24,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/askQuestion",
                                        arguments: widget.event,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (eventEnded) ...[
                            SizedBox(height: isTablet ? 20 : 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/makeReview",
                                    arguments: widget.event,
                                  );
                                },
                                icon: Icon(
                                  Iconsax.edit_2,
                                  size: isTablet ? 24 : 20,
                                ),
                                label: Text(
                                  "Make a Review",
                                  style:
                                      TextStyle(fontSize: isTablet ? 22 : 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 80, 145, 219),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 18 : 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isTablet ? 16 : 12),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildReviewsSection(List<dynamic> reviews) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewsPage(event: widget.event),
          ),
        );
      },
      child: Container(
        width: double.infinity,
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
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reviews",
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "See all",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                    SizedBox(width: isTablet ? 8 : 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: isTablet ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            if (reviews.isEmpty)
              Center(
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 14,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              Column(
                children: reviews.take(2).map((review) {
                  return Container(
                    margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.user,
                                  size: isTablet ? 20 : 16,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  review['user_name'],
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatDate(review['created_at']),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          review['feedback_text'],
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (reviews.length > 2) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Center(
                child: Text(
                  "View all ${reviews.length} reviews",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
