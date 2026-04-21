import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import '../widgets/task_item_card.dart';
import 'add_task_dialog.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              _buildSearchBar(),
              _buildTabBar(),
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
              colors: [AppColors.pink, AppColors.orange],
            ).createShader(bounds),
            child: const Text(
              'Minhas Tarefas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Consumer<TaskProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.pink.withOpacity(0.2), AppColors.orange.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.task_alt, size: 16, color: AppColors.pink),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.tasks.length}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar tarefas...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: AppColors.purple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.purple, AppColors.pink],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Pendentes'),
          Tab(text: 'Concluídas'),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllTasksList(),
        _buildPendingTasksList(),
        _buildCompletedTasksList(),
      ],
    );
  }

  Widget _buildAllTasksList() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = _filterTasks(taskProvider.tasks);
        if (tasks.isEmpty) return _buildEmptyState('Nenhuma tarefa');
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskItemCard(
              task: tasks[index],
              onDismissed: () => _deleteTask(tasks[index].id),
              onToggle: () => _toggleTask(tasks[index].id),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingTasksList() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = _filterTasks(taskProvider.incompleteTasks);
        if (tasks.isEmpty) return _buildEmptyState('Todas concluídas!');
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskItemCard(
              task: tasks[index],
              onDismissed: () => _deleteTask(tasks[index].id),
              onToggle: () => _toggleTask(tasks[index].id),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedTasksList() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = _filterTasks(taskProvider.completedTasks);
        if (tasks.isEmpty) return _buildEmptyState('Nenhuma concluída');
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskItemCard(
              task: tasks[index],
              onDismissed: () => _deleteTask(tasks[index].id),
              onToggle: () => _toggleTask(tasks[index].id),
            );
          },
        );
      },
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_searchQuery.isEmpty) return tasks;
    return tasks.where((task) => 
      task.title.toLowerCase().contains(_searchQuery) ||
      task.description.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  Widget _buildEmptyState(String message) {
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
              _tabController.index == 2 
                  ? Icons.check_circle_outline 
                  : Icons.inbox_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
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
      builder: (context) => AddTaskDialog(initialDate: DateTime.now()),
    );
  }

  void _deleteTask(String taskId) {
    context.read<TaskProvider>().removeTask(taskId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarefa removida'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleTask(String taskId) {
    context.read<TaskProvider>().toggleTaskCompletion(taskId);
  }
}