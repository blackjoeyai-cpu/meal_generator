// Copy Meal Plan Dialog for copying meal plans from other dates
// Allows users to copy existing meal plans to the current date

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/models.dart' as models;
import '../../utils/utils.dart';

class CopyMealPlanDialog extends StatefulWidget {
  final DateTime targetDate;
  final Map<DateTime, models.MealPlan> availableMealPlans;
  final Function(models.MealPlan) onMealPlanSelected;

  const CopyMealPlanDialog({
    super.key,
    required this.targetDate,
    required this.availableMealPlans,
    required this.onMealPlanSelected,
  });

  @override
  State<CopyMealPlanDialog> createState() => _CopyMealPlanDialogState();
}

class _CopyMealPlanDialogState extends State<CopyMealPlanDialog> {
  DateTime _selectedDate = DateTime.now();
  models.MealPlan? _selectedMealPlan;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Find the most recent meal plan as initial selection
    if (widget.availableMealPlans.isNotEmpty) {
      final sortedDates = widget.availableMealPlans.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      _selectedDate = sortedDates.first;
      _selectedMealPlan = widget.availableMealPlans[_selectedDate];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.copy, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Copy Meal Plan'),
                Text(
                  'To ${_getFormattedDate(widget.targetDate)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Calendar
            _buildCalendar(),

            const SizedBox(height: AppSpacing.md),

            // Selected meal plan preview
            Expanded(child: _buildMealPlanPreview()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedMealPlan != null ? _copyMealPlan : null,
          child: const Text('Copy'),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: TableCalendar<models.MealPlan>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _selectedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          final mealPlan = widget.availableMealPlans[normalizedDay];
          return mealPlan != null ? [mealPlan] : [];
        },
        onDaySelected: (selectedDay, focusedDay) {
          final normalizedDay = DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          );
          final mealPlan = widget.availableMealPlans[normalizedDay];

          if (mealPlan != null) {
            setState(() {
              _selectedDate = selectedDay;
              _selectedMealPlan = mealPlan;
            });
          }
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.error,
          ),
          holidayTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.error,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          formatButtonTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMealPlanPreview() {
    if (_selectedMealPlan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No Meal Plan Selected', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Select a date with a meal plan from the calendar above',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: Row(
            children: [
              Icon(Icons.event, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Plan from ${_getFormattedDate(_selectedDate)}',
                      style: AppTypography.titleMedium,
                    ),
                    Text(
                      '${_selectedMealPlan!.allMeals.length} meals • ${_selectedMealPlan!.totalPreparationTime} min prep',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Meals list
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: models.MealType.values.map((mealType) {
                final meal = _selectedMealPlan!.getMeal(mealType);
                return _buildMealItem(mealType, meal);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(models.MealType mealType, models.Meal? meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Meal type indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.getMealTypeColor(
                  mealType.toString().split('.').last,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
              ),
              child: Center(
                child: Text(
                  mealType.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Meal details
            Expanded(
              child: meal != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.name, style: AppTypography.titleMedium),
                        Text(
                          meal.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: meal.materials.take(3).map((material) {
                            return Chip(
                              label: Text(material.name),
                              backgroundColor: AppColors.surfaceVariant,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No ${mealType.displayName}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          'No meal planned for this type',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
            ),

            // Status indicator
            Icon(
              meal != null ? Icons.check_circle : Icons.remove_circle,
              color: meal != null ? AppColors.success : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _copyMealPlan() {
    if (_selectedMealPlan != null) {
      // Create a copy with the target date
      final copiedPlan = _selectedMealPlan!.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: widget.targetDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onMealPlanSelected(copiedPlan);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meal plan copied from ${_getFormattedDate(_selectedDate)}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
