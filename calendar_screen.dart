import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import '../widgets/task_item_card.dart';
import 'add_task_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              AppColors.purple.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCalendar(),
              const SizedBox(height: 16),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.purple, AppColors.pink],
            ).createShader(bounds),
            child: const Text(
              'Calendário',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.purple),
                const SizedBox(width: 6),
                Text(
                  '${_focusedDay.month}/${_focusedDay.year}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.purple.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              final tasks = taskProvider.getTasksForDate(day);
              return tasks.isNotEmpty ? tasks : [];
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
              weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
              todayDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple.withOpacity(0.3), AppColors.pink.withOpacity(0.3)],
                ),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.pink],
                ),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              markerSize: 6,
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
              titleTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppColors.purple,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppColors.purple,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.textSecondary),
              weekendStyle: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = _selectedDay != null 
            ? taskProvider.getTasksForDate(_selectedDay!)
            : <Task>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.purple.withOpacity(0.3), AppColors.pink.withOpacity(0.3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.list_alt, color: AppColors.purple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDay != null
                        ? 'Tarefas de ${_selectedDay!.day}/${_selectedDay!.month}'
                        : 'Selecione um dia',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: const TextStyle(
                        color: AppColors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return TaskItemCard(
                          task: tasks[index],
                          onTap: () => _showTaskDetails(tasks[index]),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkSurface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa neste dia',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.purple, AppColors.pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(initialDate: _selectedDay ?? DateTime.now()),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.purple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: task.isCompleted 
                        ? Colors.green.withOpacity(0.2)
                        : AppColors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.isCompleted ? 'Concluída' : 'Pendente',
                    style: TextStyle(
                      color: task.isCompleted ? Colors.green : AppColors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.purple),
                const SizedBox(width: 8),
                Text(
                  task.formattedDate,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.access_time, size: 18, color: AppColors.pink),
                const SizedBox(width: 8),
                Text(
                  task.formattedTime,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.darkCard),
              const SizedBox(height: 16),
              Text(
                task.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}