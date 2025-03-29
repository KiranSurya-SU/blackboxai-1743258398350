import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../services/search_service.dart';
import '../../services/search_history_service.dart';
import '../../utils/debouncer.dart';
import '../jobs/job_detail_screen.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _searchController = TextEditingController();
  final _searchService = SearchService();
  final SearchHistoryService _searchHistory = SearchHistoryService();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  String _query = '';
  bool _showHistory = false;
  List<String> _searchHistoryItems = [];
  String? _companyFilter;
  DateTime? _dateFilter;

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
      await _searchHistory.addSearchQuery(_query);
      await _loadSearchHistory();
    }
  }

  Future<void> _showFilters() async {
    final companies = await _searchService.getCompanies();
    final result = await showDialog(
      context: context,
      builder: (context) => SearchFilterDialog(
        isJobSearch: true,
        options: companies,
        initialStartDate: _dateFilter,
      ),
    );

      if (result != null) {
        setState(() {
          _companyFilter = result['option'];
          _dateFilter = result['startDate'];
        });
        if (result['option'] != null) {
          await AnalyticsService.logSearchFilter(
            filterType: 'company',
            filterValue: result['option'],
            searchType: 'job',
          );
        }
        if (result['startDate'] != null) {
          await AnalyticsService.logSearchFilter(
            filterType: 'date',
            filterValue: result['startDate'].toString(),
            searchType: 'job',
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
            hintText: 'Search jobs...',
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
                  : _searchService.getJobTitleSuggestions(_query),
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
                          searchType: 'job',
                        );
                      },
                    );
                  },
                );
              },
            )
          : StreamBuilder<List<JobModel>>(
              stream: _searchService.searchJobs(
                query: _query,
                company: _companyFilter,
                startDate: _dateFilter,
              ),
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
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Text(job.company),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailScreen(job: job),
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