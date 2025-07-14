import 'package:flutter/material.dart';
import 'package:smart_event/api_service.dart';
import 'package:smart_event/models/event_model.dart';

class MakeReviewPage extends StatefulWidget {
  final Event event;

  const MakeReviewPage({super.key, required this.event});

  @override
  State<MakeReviewPage> createState() => _MakeReviewPageState();
}

class _MakeReviewPageState extends State<MakeReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    // Validate review text
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write a review before submitting"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.submitReview(
        eventId: widget.event.id,
        reviewText: _reviewController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(result['message'] ?? "Review submitted successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(
            context, true); // Return true to indicate successful submission
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text(result['message'] ?? 'Failed to submit review'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while submitting the review"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        appBar: AppBar(
          title: Text(
            "Write a Review",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Luxenta",
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 80, 145, 219),
          toolbarHeight: isTablet ? 70 : 56,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event image
                ClipRRect(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                  child: Image.network(
                    widget.event.imageUrl,
                    height: isTablet ? 300 : 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 20),

                // Guidance text
                Text(
                  "Please share your thoughts on the event. Your feedback helps us improve.",
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 10),

                // Review TextField
                TextField(
                  controller: _reviewController,
                  maxLines: isTablet ? 8 : 5,
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                  decoration: InputDecoration(
                    labelText: "Your review",
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: isTablet ? 18 : 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 70 : 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                      elevation: 5,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: isTablet ? 30 : 24,
                            height: isTablet ? 30 : 24,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Submit Review",
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              color: Colors.white,
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
