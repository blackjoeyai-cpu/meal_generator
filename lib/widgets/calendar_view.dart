// Calendar view widget for meal plan visualization and date selection
// Uses table_calendar package for calendar functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/providers.dart';
import '../models/models.dart' as models;
import '../utils/utils.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late ValueNotifier<List<models.MealPlan>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlansProvider>(
      builder: (context, mealPlansProvider, child) {
        return Column(
          children: [
            // Calendar header with month navigation
            _buildCalendarHeader(mealPlansProvider),

            // Main calendar widget
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _buildCalendar(mealPlansProvider),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSelectedDateInfo(mealPlansProvider),
                    const SizedBox(height: AppSpacing.lg),
                    _buildMealPlanPreview(mealPlansProvider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarHeader(MealPlansProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _navigateMonth(provider, -1),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous month',
          ),
          Text(
            _getMonthYearText(provider.focusedDate),
            style: AppTypography.headlineSmall,
          ),
          IconButton(
            onPressed: () => _navigateMonth(provider, 1),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(MealPlansProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TableCalendar<models.MealPlan>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: provider.focusedDate,
          selectedDayPredicate: (day) => isSameDay(provider.selectedDate, day),
          calendarFormat: provider.calendarFormat,
          eventLoader: provider.getEventsForDay,
          headerVisible: false, // We use custom header
          // Calendar styling
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
            holidayTextStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
          ),

          // Header styling
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronVisible: false,
            rightChevronVisible: false,
          ),

          // Day cell builder
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return _buildEventMarker(events.length);
              }
              return null;
            },
            selectedBuilder: (context, date, focusedDate) {
              return _buildSelectedDay(date);
            },
            todayBuilder: (context, date, focusedDate) {
              return _buildTodayDay(date);
            },
          ),

          // Event handlers
          onDaySelected: (selectedDay, focusedDay) {
            provider.setSelectedDate(selectedDay);
            provider.setFocusedDate(focusedDay);

            final events = provider.getEventsForDay(selectedDay);
            _selectedEvents.value = events;
          },

          onFormatChanged: (format) {
            provider.setCalendarFormat(format);
          },

          onPageChanged: (focusedDay) {
            provider.setFocusedDate(focusedDay);
            _loadMonthData(provider, focusedDay);
          },
        ),
      ),
    );
  }

  Widget _buildEventMarker(int eventCount) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Text(
        eventCount.toString(),
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSelectedDay(DateTime date) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayDay(DateTime date) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo(MealPlansProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: AppSpacing.iconSize,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Selected Date', style: AppTypography.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getFormattedDate(provider.selectedDate),
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getDateDescription(provider.selectedDate),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanPreview(MealPlansProvider provider) {
    final mealPlan = provider.selectedMealPlan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                      size: AppSpacing.iconSize,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Meal Plan', style: AppTypography.titleMedium),
                  ],
                ),
                if (mealPlan != null)
                  IconButton(
                    onPressed: () => _editMealPlan(provider, mealPlan),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit meal plan',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            if (mealPlan == null)
              _buildNoMealPlanMessage()
            else
              _buildMealPlanSummary(mealPlan),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMealPlanMessage() {
    return Column(
      children: [
        Icon(Icons.no_meals, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'No meal plan for this date',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: _generateMealPlanForSelectedDate,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generate Meal Plan'),
        ),
      ],
    );
  }

  Widget _buildMealPlanSummary(models.MealPlan mealPlan) {
    return Column(
      children: [
        ...models.MealType.values.map((mealType) {
          final meal = mealPlan.getMeal(mealType);
          return _buildMealTypeSummary(mealType, meal);
        }),

        if (mealPlan.totalPreparationTime > 0) ...[
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Prep Time', style: AppTypography.bodyMedium),
              Text(
                '${mealPlan.totalPreparationTime} min',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],

        if (mealPlan.totalCalories != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Calories', style: AppTypography.bodyMedium),
              Text(
                '${mealPlan.totalCalories} cal',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMealTypeSummary(models.MealType mealType, models.Meal? meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getMealTypeColor(
                mealType.toString().split('.').last,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
            child: Center(
              child: Text(mealType.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mealType.displayName, style: AppTypography.titleSmall),
                Text(
                  meal?.name ?? 'No meal planned',
                  style: AppTypography.bodySmall.copyWith(
                    color: meal != null
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (meal != null)
            Text(
              '${meal.preparationTime} min',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods
  void _navigateMonth(MealPlansProvider provider, int monthOffset) {
    final newDate = DateTime(
      provider.focusedDate.year,
      provider.focusedDate.month + monthOffset,
      1,
    );
    provider.setFocusedDate(newDate);
    _loadMonthData(provider, newDate);
  }

  Future<void> _loadMonthData(MealPlansProvider provider, DateTime date) async {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    await provider.loadMealPlansForRange(firstDay, lastDay);
  }

  String _getMonthYearText(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
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

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDateDescription(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == today) {
      return 'Today';
    } else if (selectedDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (selectedDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selectedDate.isAfter(today)) {
      final difference = selectedDate.difference(today).inDays;
      return 'In $difference days';
    } else {
      final difference = today.difference(selectedDate).inDays;
      return '$difference days ago';
    }
  }

  Future<void> _generateMealPlanForSelectedDate() async {
    final mealPlansProvider = context.read<MealPlansProvider>();
    final materialsProvider = context.read<MaterialsProvider>();

    final availableMaterials = materialsProvider.allMaterials
        .where((material) => material.isAvailable)
        .toList();

    if (availableMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No available materials found. Please add some materials first.',
          ),
        ),
      );
      return;
    }

    try {
      await mealPlansProvider.generateMealPlan(availableMaterials);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate meal plan: $e')),
        );
      }
    }
  }

  void _editMealPlan(MealPlansProvider provider, models.MealPlan mealPlan) {
    // Navigate to meal plan editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan editing coming soon!')),
    );
  }
}
