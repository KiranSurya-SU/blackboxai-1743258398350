import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../models/event_model.dart';
import '../../services/search_service.dart';
import '../jobs/job_detail_screen.dart';
import '../events/event_detail_screen.dart';

class CustomSearchDelegate extends SearchDelegate {
  final SearchService _searchService = SearchService();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return const Center(
        child: Text('Enter at least 3 characters to search'),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Jobs'),
              Tab(text: 'Events'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildJobResults(),
                _buildEventResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobResults() {
    return StreamBuilder<List<JobModel>>(
      stream: _searchService.searchJobs(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data!;
        if (jobs.isEmpty) {
          return const Center(child: Text('No jobs found'));
        }

        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return ListTile(
              title: Text(job.title),
              subtitle: Text(job.company),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailScreen(job: job),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEventResults() {
    return StreamBuilder<List<EventModel>>(
      stream: _searchService.searchEvents(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(child: Text('No events found'));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return ListTile(
              title: Text(event.title),
              subtitle: Text(event.location),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}