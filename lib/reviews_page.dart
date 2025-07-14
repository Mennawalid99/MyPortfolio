import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'models/event_model.dart';
import 'api_service.dart';

class ReviewsPage extends StatefulWidget {
  final Event event;

  const ReviewsPage({super.key, required this.event});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  Future<List<dynamic>>? _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _getReviews();
  }

  Future<List<dynamic>> _getReviews() async {
    return ApiService.getEventReviews(widget.event.id);
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 172, 219, 253),
        elevation: 1,
        toolbarHeight: isTablet ? 80 : 60,
        title: Text(
          "Reviews",
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
        child: FutureBuilder<List<dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  width: isTablet ? 40 : 30,
                  height: isTablet ? 40 : 30,
                  child: const CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error loading reviews",
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _reviewsFuture = _getReviews();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 24,
                          vertical: isTablet ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isTablet ? 20 : 15),
                        ),
                      ),
                      child: Text(
                        "Retry",
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final review = snapshot.data![index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
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
                                  color: Colors.blue,
                                  size: isTablet ? 24 : 20,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  review['user_name'],
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 16,
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
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
