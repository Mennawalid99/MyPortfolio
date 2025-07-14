import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class CourseTrainingCategoryPage extends StatelessWidget {
  final List<Event> events;

  const CourseTrainingCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Course-Training',
      categoryIcon: Iconsax.teacher,
      events: events,
    );
  }
}
