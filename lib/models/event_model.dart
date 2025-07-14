class Event {
  final int id;
  final String ename;
  final String elocation;
  final String ecategory;
  final String edescription;
  final String imageUrl;
  final DateTime estartTime;
  final DateTime eendTime;

  Event({
    required this.id,
    required this.ename,
    required this.elocation,
    required this.ecategory,
    required this.edescription,
    required this.imageUrl,
    required this.estartTime,
    required this.eendTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String getString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString(); // Convert non-string values to string
    }

    DateTime parseDateTime(String dateStr) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr');
        print('Error details: $e');
        // Return a future date to avoid null issues
        return DateTime.now().add(const Duration(days: 1));
      }
    }

    return Event(
      id: json['id'] as int? ?? 0,
      ename: getString(json['ename']),
      elocation: getString(json['elocation']),
      ecategory: getString(json['ecategory']),
      edescription: getString(json['edescription']),
      imageUrl: getString(json['image_url']),
      estartTime: parseDateTime(getString(json['estart_time'])),
      eendTime: parseDateTime(getString(json['eend_time'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ename': ename,
        'edescription': edescription,
        'elocation': elocation,
        'ecategory': ecategory,
        'imageUrl': imageUrl,
      };
}
