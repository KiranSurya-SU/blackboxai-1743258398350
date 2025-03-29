import 'package:flutter/material.dart';
import '../models/analytics_model.dart';

class SearchFrequencyChart extends StatelessWidget {
  final List<AnalyticsModel> analytics;
  final DateTime? startDate;
  final DateTime? endDate;

  const SearchFrequencyChart({
    super.key,
    required this.analytics,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Activity Over Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'Chart visualization will appear here\n'
                  'once fl_chart package is installed',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}