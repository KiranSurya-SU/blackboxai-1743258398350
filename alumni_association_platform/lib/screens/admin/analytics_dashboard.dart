import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/analytics_model.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _eventTypeFilter = 'all';
  String _searchTypeFilter = 'all';

  Widget _buildAnalyticsCard(AnalyticsModel analytics) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analytics.eventName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(analytics.timestamp),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ...analytics.parameters.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldInclude(AnalyticsModel analytics) {
    if (_eventTypeFilter != 'all') {
      if (_eventTypeFilter == 'search' && !analytics.isSearchEvent()) return false;
      if (_eventTypeFilter == 'search_filter' && !analytics.isFilterEvent()) return false;
    }
    if (_searchTypeFilter != 'all' && !analytics.matchesSearchType(_searchTypeFilter)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Search Analytics Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _eventTypeFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Events')),
                      DropdownMenuItem(value: 'search', child: Text('Searches')),
                      DropdownMenuItem(value: 'search_filter', child: Text('Filters')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _eventTypeFilter = value ?? 'all';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Event Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _searchTypeFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(value: 'job', child: Text('Job Searches')),
                      DropdownMenuItem(value: 'event', child: Text('Event Searches')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _searchTypeFilter = value ?? 'all';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _startDate == null 
                            ? 'Select Start Date' 
                            : DateFormat('MMM d, y').format(_startDate!),
                        ),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _endDate == null 
                            ? 'Select End Date' 
                            : DateFormat('MMM d, y').format(_endDate!),
                        ),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                    if (_startDate != null || _endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                        tooltip: 'Clear dates',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SearchFrequencyChart(
            analytics: const [], // Empty list for now - will be populated when Firebase is ready
            startDate: _startDate,
            endDate: _endDate,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('analytics')
                  .orderBy('timestamp', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final analytics = snapshot.data!.docs
                    .map((doc) => AnalyticsModel.fromFirestore(doc))
                    .where(_shouldInclude)
                    .toList();

                if (analytics.isEmpty) {
                  return const Center(child: Text('No matching analytics found'));
                }

                return ListView.builder(
                  itemCount: analytics.length,
                  itemBuilder: (context, index) {
                    return _buildAnalyticsCard(analytics[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}