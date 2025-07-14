import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class RealEstateCategoryPage extends StatelessWidget {
  final List<Event> events;

  const RealEstateCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Real-Estate',
      categoryIcon: Iconsax.building_3,
      events: events,
    );
  }
}
