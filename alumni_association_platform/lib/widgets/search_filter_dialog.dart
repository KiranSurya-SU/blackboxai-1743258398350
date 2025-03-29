import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchFilterDialog extends StatefulWidget {
  final bool isJobSearch;
  final List<String>? options;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const SearchFilterDialog({
    super.key,
    required this.isJobSearch,
    this.options,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<SearchFilterDialog> createState() => _SearchFilterDialogState();
}

class _SearchFilterDialogState extends State<SearchFilterDialog> {
  String? _selectedOption;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter ${widget.isJobSearch ? 'Jobs' : 'Events'}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.options != null) ...[
              DropdownButtonFormField<String>(
                value: _selectedOption,
                decoration: InputDecoration(
                  labelText: widget.isJobSearch ? 'Company' : 'Location',
                ),
                items: widget.options!.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedOption = value),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                      _startDate == null 
                        ? 'Select Start Date'
                        : 'From: ${DateFormat.yMd().format(_startDate!)}',
                    ),
                  ),
                ),
                if (!widget.isJobSearch) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(
                        _endDate == null
                          ? 'Select End Date'
                          : 'To: ${DateFormat.yMd().format(_endDate!)}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {
            'option': _selectedOption,
            'startDate': _startDate,
            'endDate': _endDate,
          }),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}