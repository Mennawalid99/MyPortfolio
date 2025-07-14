import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class TechCategoryPage extends StatelessWidget {
  final List<Event> events;

  const TechCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Tech',
      categoryIcon: Iconsax.cpu,
      events: events,
    );
  }
}
