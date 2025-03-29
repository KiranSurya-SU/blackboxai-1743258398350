import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/search_service.dart';
import '../../services/search_history_service.dart';
import '../../services/analytics_service.dart';
import '../../utils/debouncer.dart';
import '../../widgets/search_filter_dialog.dart';
import '../events/event_detail_screen.dart';

class EventSearchScreen extends StatefulWidget {
  const EventSearchScreen({super.key});

  @override
  State<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  final _searchController = TextEditingController();
  final _searchService = SearchService();
  final SearchHistoryService _searchHistory = SearchHistoryService();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  String _query = '';
  bool _showHistory = false;
  List<String> _searchHistoryItems = [];
  String? _locationFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistory.getSearchHistory();
    setState(() {
      _searchHistoryItems = history;
    });
  }

  Future<void> _saveSearchQuery() async {
    if (_query.isNotEmpty) {
      await _searchHistory.addSearchQuery(
        _query,
        searchType: 'event',
      );
      await _loadSearchHistory();
    }
  }

  Future<void> _showFilters() async {
    final locations = await _searchService.getLocations();
    final result = await showDialog(
      context: context,
      builder: (context) => SearchFilterDialog(
        isJobSearch: false,
        options: locations,
        initialStartDate: _startDateFilter,
        initialEndDate: _endDateFilter,
      ),
    );

    if (result != null) {
      setState(() {
        _locationFilter = result['option'];
        _startDateFilter = result['startDate'];
        _endDateFilter = result['endDate'];
      });
      if (result['option'] != null) {
        await AnalyticsService.logSearchFilter(
          filterType: 'location',
          filterValue: result['option'],
          searchType: 'event',
        );
      }
      if (result['startDate'] != null) {
        await AnalyticsService.logSearchFilter(
          filterType: 'start_date',
          filterValue: result['startDate'].toString(),
          searchType: 'event',
        );
      }
      if (result['endDate'] != null) {
        await AnalyticsService.logSearchFilter(
          filterType: 'end_date',
          filterValue: result['endDate'].toString(),
          searchType: 'event',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_showHistory && _searchHistoryItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Clear history',
              onPressed: () async {
                await _searchHistory.clearSearchHistory();
                await _loadSearchHistory();
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilters,
          ),
        ],
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
              _showHistory = value.isEmpty;
            });
            if (value.isNotEmpty) {
              _debouncer.run(() async {
                await _loadSearchHistory();
                setState(() {});
              });
            }
          },
          onSubmitted: (value) async {
            await _saveSearchQuery();
            setState(() => _showHistory = false);
          },
          onTap: () async {
            await _loadSearchHistory();
            setState(() => _showHistory = _query.isEmpty);
          },
        ),
      ),
      body: _showHistory
          ? FutureBuilder<List<String>>(
              future: _query.isEmpty 
                  ? _searchHistory.getSearchHistory()
                  : _searchService.getEventTitleSuggestions(_query),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(child: Text('No suggestions found'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index]),
                      leading: Icon(_query.isEmpty 
                          ? Icons.history 
                          : Icons.search),
                      onTap: () async {
                        _searchController.text = items[index];
                        setState(() {
                          _query = items[index];
                          _showHistory = false;
                        });
                        await _searchHistory.addSearchQuery(
                          items[index],
                          isSuggestion: true,
                          searchType: 'event',
                        );
                      },
                    );
                  },
                );
              },
            )
          : StreamBuilder<List<EventModel>>(
              stream: _searchService.searchEvents(
                query: _query,
                location: _locationFilter,
                startDate: _startDateFilter,
                endDate: _endDateFilter,
              ),
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
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text(
                          '${DateFormat.yMMMd().format(event.date)} • ${event.location}',
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailScreen(event: event),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}