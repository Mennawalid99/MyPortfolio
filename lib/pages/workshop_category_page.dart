import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class WorkshopCategoryPage extends StatelessWidget {
  final List<Event> events;

  const WorkshopCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Workshop',
      categoryIcon: Iconsax.briefcase,
      events: events,
    );
  }
}
