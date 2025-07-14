import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://192.168.191.146:8000";

  // Get stored user name
  static Future<String?> getUserNameFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('user_name');
    print("Retrieved user name from storage: $userName");
    return userName;
  }

  // Login and save token + user ID + user name
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/login');
    final client = http.Client();

    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          print("Token saved: $token");

          // Get user data using token
          final responseData = await getUserData();
          print("User data fetched: $responseData");

          if (responseData.containsKey('user')) {
            final userData = responseData['user'];

            if (userData.containsKey('id')) {
              await prefs.setInt('user_id', userData['id']);
              print("User ID saved: ${userData['id']}");
            } else {
              print("No user ID found in userData");
            }

            if (userData.containsKey('fname') &&
                userData.containsKey('lname')) {
              final fullName = '${userData['fname']} ${userData['lname']}';
              await prefs.setString('user_name', fullName);
              print("User name saved: $fullName");
            } else {
              print("First name or last name missing in userData");
            }

            if (userData.containsKey('profile_image_url')) {
              await prefs.setString(
                  'profile_image_url', userData['profile_image_url']);
              print("Profile image URL saved");
            }
          } else {
            print("'user' key not found in getUserData response");
          }

          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
          };
        } else {
          print("Token is null");
          return {'success': false, 'message': "No token received from server"};
        }
      } else {
        print("Login failed: ${response.body}");
        return {
          'success': false,
          'message': jsonDecode(response.body)['message']
        };
      }
    } catch (e) {
      print("Exception during login: $e");
      return {
        'success': false,
        'message': "An error occurred. Please try again."
      };
    } finally {
      client.close();
    }
  }

  // Get user info using Bearer token
  static Future<Map<String, dynamic>> getUserData() async {
    final url = Uri.parse('$baseUrl/api/user');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("No token found in getUserData");
      return {'error': "No token found"};
    }

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      print("getUserData success: $userData");
      return userData;
    } else if (response.statusCode == 401) {
      await prefs.remove('token');
      print("Token expired");
      return {'error': "Session expired, please log in again"};
    } else {
      print("getUserData failed: ${response.body}");
      return {'error': "Failed to fetch user data"};
    }
  }

  // Get stored user ID
  static Future<int?> getUserIdFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print("Retrieved user ID from storage: $userId");
    return userId;
  }

  // Get stored token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print("Retrieved token from storage: $token");
    return token;
  }

  // Send booking request with user ID
  static Future<Map<String, dynamic>> sendBookingRequest(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');

    print("Sending booking request...");
    print("Token: $token");
    print("User ID: $userId");

    if (token == null) {
      return {'error': 'Token is required for authentication.'};
    }

    if (userId == null) {
      return {'error': 'User ID is required.'};
    }

    final url = Uri.parse('$baseUrl/api/book-event');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "user_id": userId,
        "event_id": eventId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("Booking successful: $data");
      return {'success': true, 'message': 'Booking successful'};
    } else {
      print("Booking failed: ${response.body}");
      return {'success': false, 'message': 'Failed to book the event'};
    }
  }

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String role,
    required File profileImage,
  }) async {
    final url = Uri.parse('$baseUrl/api/register');

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['firstname'] = firstName
        ..fields['lastname'] = lastName
        ..fields['phone'] = phone
        ..fields['email'] = email
        ..fields['password'] = password
        ..fields['role'] = role;

      request.files.add(await http.MultipartFile.fromPath(
          'profile_image', profileImage.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Registration successful'};
      } else {
        // Check for specific validation errors
        if (data.containsKey('errors')) {
          return {
            'success': false,
            'message': 'Validation failed',
            'errors': data['errors']
          };
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      print("Exception during registration: $e");
      return {
        'success': false,
        'message': "An error occurred. Please try again."
      };
    }
  }

  // Get event reviews
  static Future<List<dynamic>> getEventReviews(int eventId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return [];

      final url = Uri.parse('$baseUrl/api/event-feedbacks/$eventId');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Reviews fetched successfully");
        return data['feedbacks'] ?? [];
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while fetching reviews");
        return [];
      } else {
        print("Failed to fetch reviews: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception fetching reviews: $e");
      return [];
    }
  }

  // Submit event review
  static Future<Map<String, dynamic>> submitReview({
    required int eventId,
    required String reviewText,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userName = prefs.getString('user_name');
      int? userId = prefs.getInt('user_id');

      if (token == null || userName == null || userId == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final url = Uri.parse('$baseUrl/api/feedback');
      print("Submitting review to URL: $url");
      print(
          "Review data - EventID: $eventId, UserName: $userName, UserID: $userId");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "event_id": eventId,
          "user_name": userName,
          "user_id": userId,
          "review": reviewText,
        }),
      );

      print("Review submission response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Review submitted successfully");
        return {
          'success': true,
          'message': responseData['message'] ?? 'Review submitted successfully'
        };
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while submitting review");
        return {
          'success': false,
          'message': 'Session expired, please login again'
        };
      } else {
        print("Failed to submit review: ${response.body}");
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          final errorMessages =
              errors.values.expand((e) => e as List).join(', ');
          return {'success': false, 'message': errorMessages};
        }
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to submit review'
        };
      }
    } catch (e) {
      print("Exception submitting review: $e");
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Get all events with proper error handling
  static Future<Map<String, dynamic>> getEvents() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("Token not found");
        return {
          'success': false,
          'message': 'Authentication required',
          'data': []
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/getevents'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Events fetched successfully");
        return {
          'success': true,
          'message': 'Events fetched successfully',
          'data': data
        };
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while fetching events");
        return {
          'success': false,
          'message': 'Session expired, please login again',
          'data': []
        };
      } else {
        print("Failed to load events: ${response.body}");
        return {
          'success': false,
          'message': 'Failed to load events',
          'data': []
        };
      }
    } catch (e) {
      print("Error fetching events: $e");
      return {
        'success': false,
        'message': 'An error occurred while fetching events',
        'data': []
      };
    }
  }

  // Get user interests
  static Future<List<String>> getUserInterests() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('user_id');

      if (token == null || userId == null) return [];

      final url = Uri.parse('$baseUrl/api/user-interests/$userId');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("User interests fetched successfully");
        return List<String>.from(data['interests'] ?? []);
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while fetching interests");
        return [];
      } else {
        print("Failed to fetch interests: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception fetching interests: $e");
      return [];
    }
  }

  // Save user interests
  static Future<bool> saveUserInterests(List<String> interests) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('user_id');

      if (token == null || userId == null) return false;

      final url = Uri.parse('$baseUrl/api/save-interests');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": userId,
          "interests": interests,
        }),
      );

      if (response.statusCode == 200) {
        print("User interests saved successfully");
        await prefs.setStringList('user_interests', interests);
        return true;
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while saving interests");
        return false;
      } else {
        print("Failed to save interests: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception saving interests: $e");
      return false;
    }
  }

  // Submit question during event
  static Future<Map<String, dynamic>> submitQuestion({
    required int eventId,
    required String question,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userName = prefs.getString('user_name');

      if (token == null || userName == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final url = Uri.parse('$baseUrl/api/question/');

      print("Submitting question to URL: $url");
      print("Question data - EventID: $eventId, Username: $userName");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "username": userName,
          "event_id": eventId,
          "content": question,
        }),
      );

      print("Question submission response status: ${response.statusCode}");

      // Check for HTML response which indicates a redirect
      if (response.body.toLowerCase().contains('<!doctype html>') ||
          response.body.toLowerCase().contains('<html')) {
        print("Received HTML response instead of JSON");
        return {
          'success': false,
          'message': 'Server configuration error. Please contact support.'
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Question submitted successfully");
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Question submitted successfully'
        };
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while submitting question");
        return {
          'success': false,
          'message': 'Session expired, please login again'
        };
      } else {
        print(
            "Failed to submit question: ${response.statusCode} - ${response.body}");
        try {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            final errorMessages =
                errors.values.expand((e) => e as List).join(', ');
            return {'success': false, 'message': errorMessages};
          }
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to submit question'
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to submit question. Please try again.'
          };
        }
      }
    } catch (e) {
      print("Exception submitting question: $e");
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Get saved event IDs
  static Future<Set<int>> getSavedEventIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('saved_events') ?? [])
        .map((id) => int.parse(id))
        .toSet();
  }

  // Save event IDs
  static Future<void> saveEventIds(Set<int> savedEventIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'saved_events',
      savedEventIds.map((id) => id.toString()).toList(),
    );
    print("Saved event IDs updated successfully");
  }

  // Get user interests from preferences
  static Future<List<String>> getUserInterestsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('user_interests') ?? [];
  }

  // Sort categories based on user interests
  static Future<List<Map<String, dynamic>>> getSortedCategories(
      List<Map<String, dynamic>> allCategories) async {
    final userInterests = await getUserInterestsFromPrefs();
    print("User interests from SharedPreferences: $userInterests");

    final sortedCategories = List<Map<String, dynamic>>.from(allCategories);
    sortedCategories.sort((a, b) {
      bool isASelected = userInterests.contains(a["label"]);
      bool isBSelected = userInterests.contains(b["label"]);

      if (isASelected && !isBSelected) {
        return -1;
      } else if (!isASelected && isBSelected) {
        return 1;
      } else {
        return allCategories
            .indexWhere((c) => c["label"] == a["label"])
            .compareTo(
                allCategories.indexWhere((c) => c["label"] == b["label"]));
      }
    });

    return sortedCategories;
  }

  // Get user bookings
  static Future<Map<String, dynamic>> getUserBookings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return {
          'success': false,
          'message': 'Authentication required',
          'data': []
        };
      }

      final url = Uri.parse('$baseUrl/api/user-bookings/$userId');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("User bookings fetched successfully");
        // Handle both array and object response formats
        List<dynamic> bookings = [];
        if (data is List) {
          bookings = data;
        } else if (data is Map && data.containsKey('bookings')) {
          bookings = data['bookings'] ?? [];
        }
        return {
          'success': true,
          'message': 'Bookings fetched successfully',
          'data': bookings
        };
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while fetching bookings");
        return {
          'success': false,
          'message': 'Session expired, please login again',
          'data': []
        };
      } else {
        print("Failed to fetch bookings: ${response.body}");
        return {
          'success': false,
          'message': 'Failed to fetch bookings',
          'data': []
        };
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      return {
        'success': false,
        'message': 'An error occurred while fetching bookings',
        'data': []
      };
    }
  }

  // Filter and sort events based on search, category and user interests
  static Future<List<dynamic>> filterAndSortEvents({
    required List<dynamic> events,
    required String searchQuery,
    String? selectedCategory,
  }) async {
    final userInterests = await getUserInterestsFromPrefs();

    // First filter based on search and category
    List<dynamic> filtered = events.where((event) {
      bool matchesSearch =
          event.ename.toLowerCase().contains(searchQuery.toLowerCase()) ||
              event.elocation.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesCategory = selectedCategory == null ||
          event.ecategory.toLowerCase() == selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    // Then sort based on user interests
    filtered.sort((a, b) {
      bool isAFromSelectedCategory = userInterests.contains(a.ecategory);
      bool isBFromSelectedCategory = userInterests.contains(b.ecategory);

      if (isAFromSelectedCategory && !isBFromSelectedCategory) {
        return -1;
      } else if (!isAFromSelectedCategory && isBFromSelectedCategory) {
        return 1;
      }
      return 0;
    });

    return filtered;
  }

  // Cancel booking
  static Future<Map<String, dynamic>> cancelBooking(int eventId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final url = Uri.parse('$baseUrl/api/cancel-booking');

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": userId,
          "event_id": eventId,
        }),
      );

      if (response.statusCode == 200) {
        print("Booking cancelled successfully");
        return {'success': true, 'message': 'Booking cancelled successfully'};
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while cancelling booking");
        return {
          'success': false,
          'message': 'Session expired, please login again'
        };
      } else {
        print("Failed to cancel booking: ${response.body}");
        return {'success': false, 'message': 'Failed to cancel booking'};
      }
    } catch (e) {
      print("Error cancelling booking: $e");
      return {
        'success': false,
        'message': 'An error occurred while cancelling booking'
      };
    }
  }

  // Get upcoming event notifications (2 days before)
  static Future<List<Map<String, dynamic>>>
      getUpcomingEventNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return [];

      final url = Uri.parse('$baseUrl/api/upcoming-event-notifications');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifications =
            List<Map<String, dynamic>>.from(data['notifications'] ?? []);

        // Transform the notifications to include event_name from ename
        return notifications.map((notification) {
          return {
            'id': notification['id'],
            'type': notification['type'],
            'event_id': notification['id'], // Using id as event_id
            'event_name': notification['ename'],
            'event_time': notification['estart_time'],
            'time_until': notification['time_until'],
            'created_at': notification['created_at'],
            'image_url': notification['image_url'],
          };
        }).toList();
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while fetching upcoming notifications");
        return [];
      } else {
        print("Failed to fetch upcoming notifications: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching upcoming notifications: $e");
      return [];
    }
  }

  // Get active event notifications (events that have started)
  static Future<List<Map<String, dynamic>>>
      getActiveEventNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return [];

      final url = Uri.parse('$baseUrl/api/started-event-notifications');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifications =
            List<Map<String, dynamic>>.from(data['notifications'] ?? []);

        // Transform the notifications to include event_name from ename
        return notifications.map((notification) {
          return {
            'id': notification['id'],
            'type': notification['type'],
            'event_id': notification['id'], // Using id as event_id
            'event_name': notification['ename'],
            'event_time': notification['estart_time'],
            'created_at': notification['created_at'],
            'image_url': notification['image_url'],
          };
        }).toList();
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while fetching active notifications");
        return [];
      } else {
        print("Failed to fetch active notifications: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching active notifications: $e");
      return [];
    }
  }

  // Get ended event notifications (events that have ended)
  static Future<List<Map<String, dynamic>>> getEndedEventNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return [];

      final url = Uri.parse('$baseUrl/api/ended-event-notifications');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifications =
            List<Map<String, dynamic>>.from(data['notifications'] ?? []);

        // Transform the notifications to include event_name from ename
        return notifications.map((notification) {
          return {
            'id': notification['id'],
            'type': notification['type'],
            'event_id': notification['id'], // Using id as event_id
            'event_name': notification['ename'],
            'event_time':
                notification['eend_time'], // Using eend_time for ended events
            'created_at': notification['created_at'],
            'image_url': notification['image_url'],
          };
        }).toList();
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        print("Token expired while fetching ended notifications");
        return [];
      } else {
        print("Failed to fetch ended notifications: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching ended notifications: $e");
      return [];
    }
  }

  // Get all notifications
  static Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      final upcoming = await getUpcomingEventNotifications();
      final active = await getActiveEventNotifications();
      final ended = await getEndedEventNotifications();

      // Combine all notifications and sort by creation time
      final allNotifications = [...upcoming, ...active, ...ended];
      allNotifications.sort((a, b) {
        final aTime = DateTime.parse(a['created_at']);
        final bTime = DateTime.parse(b['created_at']);
        return bTime.compareTo(aTime); // Most recent first
      });

      return allNotifications;
    } catch (e) {
      print("Error fetching all notifications: $e");
      return [];
    }
  }
}
