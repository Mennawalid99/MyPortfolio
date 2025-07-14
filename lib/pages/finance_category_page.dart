import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class FinanceCategoryPage extends StatelessWidget {
  final List<Event> events;

  const FinanceCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Finance',
      categoryIcon: Iconsax.money,
      events: events,
    );
  }
}
