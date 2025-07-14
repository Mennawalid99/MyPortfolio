import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'models/event_model.dart';
import 'api_service.dart';

class AskQuestionPage extends StatefulWidget {
  final Event event;

  const AskQuestionPage({super.key, required this.event});

  @override
  State<AskQuestionPage> createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends State<AskQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  String? _username;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    _username = await ApiService.getUserNameFromStorage();
    if (mounted) {
      setState(() {});
    }
  }

  void _submitQuestion() async {
    final content = _questionController.text.trim();

    if (content.isEmpty || _username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your question.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.submitQuestion(
      eventId: widget.event.id,
      question: content,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Question submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit question'),
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
          backgroundColor: const Color.fromARGB(255, 80, 145, 219),
          title: Text(
            "Ask a Question",
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
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height,
            ),
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
                  SizedBox(height: isTablet ? 30 : 20),

                  // Event name
                  Text(
                    widget.event.ename,
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isTablet ? 30 : 20),

                  // Guidance text
                  Text(
                    "Have a question about the event? Ask the organizers directly.",
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 10),

                  // Question TextField
                  TextField(
                    controller: _questionController,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                    ),
                    decoration: InputDecoration(
                      labelText: "Your question",
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
                  SizedBox(height: isTablet ? 30 : 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 20 : 16,
                        ),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isTablet ? 16 : 12),
                        ),
                        shadowColor: Colors.blueAccent.withOpacity(0.5),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: isTablet ? 30 : 24,
                              height: isTablet ? 30 : 24,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Submit Question",
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 18,
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
      ),
    );
  }
}
