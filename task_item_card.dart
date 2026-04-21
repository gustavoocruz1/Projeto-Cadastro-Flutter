import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';

class TaskItemCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;
  final VoidCallback? onToggle;

  const TaskItemCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onDismissed,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed?.call(),
        background: _buildDismissBackground(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: task.isCompleted
                ? null
                : LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.darkSurface, AppColors.darkCard],
                  ),
            color: task.isCompleted ? AppColors.darkSurface.withOpacity(0.5) : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: task.isCompleted ? Colors.transparent : AppColors.purple.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: task.isCompleted ? null : [
              BoxShadow(color: AppColors.purple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildCheckbox(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildContent()),
                    _buildTimeBadge(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, AppColors.pink.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: task.isCompleted ? const LinearGradient(colors: [Colors.green, Colors.green]) : null,
          color: task.isCompleted ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted ? Colors.green : AppColors.purple,
            width: 2,
          ),
          boxShadow: task.isCompleted ? [
            BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
          ] : null,
        ),
        child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
          child: Text(task.title),
        ),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            task.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withOpacity(task.isCompleted ? 0.5 : 0.7),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 12,
              color: AppColors.purple.withOpacity(task.isCompleted ? 0.3 : 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              task.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(task.isCompleted ? 0.5 : 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: task.isCompleted
            ? null
            : LinearGradient(
                colors: [AppColors.orange.withOpacity(0.2), AppColors.pink.withOpacity(0.2)],
              ),
        color: task.isCompleted ? AppColors.textSecondary.withOpacity(0.2) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: task.isCompleted ? AppColors.textSecondary : AppColors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            task.formattedTime,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: task.isCompleted ? AppColors.textSecondary : AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}