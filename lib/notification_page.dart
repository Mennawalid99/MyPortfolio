import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final allNotifications = await ApiService.getAllNotifications();

    if (!mounted) return;

    setState(() {
      notifications = allNotifications;
      isLoading = false;
    });
  }

  void _deleteNotification(int index) {
    if (!mounted) return;

    // Store the deleted item for undo functionality
    final Map<String, dynamic> deletedNotification = notifications[index];

    setState(() {
      notifications.removeAt(index);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            if (!mounted) return;

            setState(() {
              // Restore the deleted notification at its original position
              notifications.insert(index, deletedNotification);
            });
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'upcoming_event':
        return Iconsax.calendar;
      case 'event_started':
        return Iconsax.message_question;
      case 'event_ended':
        return Iconsax.star;
      default:
        return Iconsax.notification;
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'upcoming_event':
        return 'Upcoming Event';
      case 'event_started':
        return 'Event Started';
      case 'event_ended':
        return 'Event Ended';
      default:
        return 'Notification';
    }
  }

  String _getNotificationMessage(Map<String, dynamic> notification) {
    final type = notification['type'];
    final eventName = notification['event_name'];

    switch (type) {
      case 'upcoming_event':
        final timeUntil = notification['time_until'] is int
            ? '${notification['time_until']} day${notification['time_until'] == 1 ? '' : 's'}'
            : notification['time_until']?.toString() ?? '';
        return '$eventName starts in $timeUntil';
      case 'event_started':
        return "$eventName has started. if any question goes on your mind don't hesitate to ask";
      case 'event_ended':
        return '$eventName has ended. provide your review';
      default:
        return 'New notification';
    }
  }

  String _formatNotificationTime(String? dateTimeString) {
    debugPrint(
        '*** _formatNotificationTime received: "$dateTimeString" ***'); // Diagnostic print
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'N/A'; // Or any other default string
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return DateFormat('MMM d, yyyy').format(dateTime);
      } else if (difference.inDays > 1) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      debugPrint('Error parsing date time: $dateTimeString - $e');
      return 'Invalid Date'; // Return a default string on parsing error
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isTablet ? 80 : 70),
          child: Container(
            padding: EdgeInsets.only(top: isTablet ? 25 : 20),
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
                  Icons.arrow_back,
                  color: Colors.black,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Padding(
                padding: EdgeInsets.only(top: isTablet ? 10 : 8.0),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Luxenta',
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: isTablet ? 40 : 30,
                    height: isTablet ? 40 : 30,
                    child: const CircularProgressIndicator(),
                  ),
                )
              : notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Dismissible(
                          key: ValueKey(notification['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: isTablet ? 30 : 20),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 20 : 15),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Confirm Deletion",
                                        style: TextStyle(
                                          fontSize: isTablet ? 22 : 18,
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete this notification?",
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize: isTablet ? 18 : 16,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(
                                              fontSize: isTablet ? 18 : 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;
                          },
                          onDismissed: (direction) {
                            _deleteNotification(index);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 20 : 15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 24 : 16,
                                vertical: isTablet ? 16 : 12,
                              ),
                              leading: Container(
                                padding: EdgeInsets.all(isTablet ? 10 : 6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 172, 219, 253)
                                          .withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getNotificationIcon(notification['type']),
                                  color:
                                      const Color.fromARGB(255, 80, 145, 219),
                                  size: isTablet ? 24 : 18,
                                ),
                              ),
                              title: Text(
                                _getNotificationTitle(notification['type']),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: isTablet ? 4 : 2),
                                  Text(
                                    _getNotificationMessage(notification),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: isTablet ? 15 : 13,
                                    ),
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                  SizedBox(height: isTablet ? 6 : 4),
                                  Text(
                                    _formatNotificationTime(
                                        notification['created_at'] as String?),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: isTablet ? 13 : 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
