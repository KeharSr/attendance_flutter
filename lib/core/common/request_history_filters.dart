import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestHistoryFilters extends StatelessWidget {
  const RequestHistoryFilters({
    required this.year,
    required this.month,
    required this.loading,
    required this.onYearChanged,
    required this.onMonthChanged,
    this.keyPrefix = 'request',
    super.key,
  });

  final String keyPrefix;
  final int year;
  final int month;
  final bool loading;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = {
      for (var y = currentYear - 10; y <= currentYear + 5; y++) y,
      year,
    }.toList()..sort((a, b) => b.compareTo(a));
    final yearField = DropdownButtonFormField<int>(
      key: ValueKey('$keyPrefix-year-$year'),
      initialValue: year,
      isExpanded: true,
      decoration: requestInput('Year').copyWith(labelText: 'Year'),
      items: [
        for (final value in years)
          DropdownMenuItem(value: value, child: Text('$value')),
      ],
      onChanged: loading
          ? null
          : (value) {
              if (value != null) onYearChanged(value);
            },
    );
    final monthField = DropdownButtonFormField<int>(
      key: ValueKey('$keyPrefix-month-$month'),
      initialValue: month,
      isExpanded: true,
      decoration: requestInput('Month').copyWith(labelText: 'Month'),
      items: [
        for (var value = 1; value <= 12; value++)
          DropdownMenuItem(
            value: value,
            child: Text(DateFormat.MMMM().format(DateTime(2000, value))),
          ),
      ],
      onChanged: loading
          ? null
          : (value) {
              if (value != null) onMonthChanged(value);
            },
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(14) > 20) {
            return Column(
              children: [yearField, const SizedBox(height: 16), monthField],
            );
          }
          return Row(
            children: [
              Expanded(child: yearField),
              const SizedBox(width: 12),
              Expanded(child: monthField),
            ],
          );
        },
      ),
    );
  }
}
