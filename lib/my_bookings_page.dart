import 'package:flutter/material.dart';
import 'package:smart_event/api_service.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool _isLoading = true;
  List<dynamic> _bookings = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getUserBookings();

    if (!mounted) return;

    setState(() {
      if (result['success']) {
        _bookings = result['data'];
      } else {
        _errorMessage = result['message'];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Check if device is tablet

    Widget content;
    if (_isLoading) {
      content = Center(
        child: SizedBox(
          width: isTablet ? 40 : 30,
          height: isTablet ? 40 : 30,
          child: const CircularProgressIndicator(color: Colors.blue),
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: isTablet ? 32 : 20),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: _fetchBookings,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_bookings.isEmpty) {
      content = Center(
        child: Text(
          'No bookings found',
          style: TextStyle(
            fontSize: isTablet ? 24 : 18,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      content = ListView.builder(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final event = booking['event'];
          final imageUrl =
              event?['image_url'] ?? 'https://via.placeholder.com/400x200';

          return Container(
            margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isTablet ? 20 : 15),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: isTablet ? 300 : 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading image for URL: $imageUrl');
                      debugPrint('Image loading error: $error');
                      return Container(
                        height: isTablet ? 300 : 200,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: isTablet ? 70 : 50,
                        ),
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
                        event?['ename'] ?? 'Event Name',
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Luxenta',
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: isTablet ? 24 : 20,
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Expanded(
                            child: Text(
                              event?['elocation'] ?? 'Location',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: isTablet ? 24 : 20,
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Text(
                            event?['estart_time']?.split(' ')[0] ?? 'Date',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.blue,
                            size: isTablet ? 24 : 20,
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Text(
                            event?['estart_time']
                                    ?.split(' ')[1]
                                    .substring(0, 5) ??
                                'Time',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.redAccent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(isTablet ? 35 : 30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: MaterialButton(
                            onPressed: () => _showCancelConfirmationDialog(
                                context, event?['id']),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 32 : 24,
                              vertical: isTablet ? 16 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 35 : 30),
                            ),
                            child: Text(
                              'Cancel Booking',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

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
                  'My Bookings',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Luxenta',
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: content,
        ),
      ),
    );
  }

  Future<void> _showCancelConfirmationDialog(
      BuildContext context, int? eventId) async {
    if (eventId == null) return;

    final isTablet = MediaQuery.of(context).size.width > 600;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Booking',
            style: TextStyle(fontSize: isTablet ? 24 : 20),
          ),
          content: Text(
            'Are you sure you want to cancel this booking?',
            style: TextStyle(fontSize: isTablet ? 18 : 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final response = await ApiService.cancelBooking(eventId);

      if (!mounted) return;

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchBookings(); // Refresh the bookings list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
