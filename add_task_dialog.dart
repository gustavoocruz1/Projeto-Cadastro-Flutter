import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';

class AddTaskDialog extends StatefulWidget {
  final DateTime initialDate;

  const AddTaskDialog({Key? key, required this.initialDate}) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.purple,
              secondary: AppColors.pink,
              surface: AppColors.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.purple,
              secondary: AppColors.pink,
              surface: AppColors.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        isCompleted: false,
      );

      context.read<TaskProvider>().addTask(task);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Tarefa adicionada!'),
            ],
          ),
          backgroundColor: AppColors.purple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkSurface, AppColors.darkCard],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.purple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDateTimePickers(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.pink],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_task, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Text(
          'Nova Tarefa',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Título da tarefa',
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.task_alt, color: AppColors.purple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, insira um título';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(child: _buildDatePicker()),
        const SizedBox(width: 12),
        Expanded(child: _buildTimePicker()),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pink.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.pink, size: 20),
            const SizedBox(width: 8),
            Text(
              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.orange.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              _selectedTime.format(context),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withOpacity(0.2), width: 1),
      ),
      child: TextFormField(
        controller: _descriptionController,
        style: const TextStyle(color: AppColors.textPrimary),
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Descrição (opcional)',
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 48),
            child: Icon(Icons.notes, color: AppColors.purple),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.3), width: 1),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Adicionar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}