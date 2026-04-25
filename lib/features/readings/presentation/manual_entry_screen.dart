import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/blood_pressure_reading.dart';
import 'readings_controller.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:pressao_arterial_historico/l10n/app_localizations.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _saveReading() {
    final sys = int.tryParse(_sysController.text);
    final dia = int.tryParse(_diaController.text);

    if (sys == null || dia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.manualEntryErrorInvalid),
        ),
      );
      return;
    }

    if (sys <= dia) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.manualEntryErrorSysDia),
        ),
      );
      return;
    }

    final reading = BloodPressureReading()
      ..systolic = sys
      ..diastolic = dia
      ..measuredAt = _selectedDate;

    ref.read(readingsControllerProvider.notifier).addReading(reading);
    context.pop();
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      if (!mounted) return;
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _sysController.dispose();
    _diaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.manualEntryTitle,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Icon Area
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.manualEntryRecord,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.displaySmall?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.manualEntryFillDetails,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),

            // Date & Time Picker
            AppCard(
              padding: EdgeInsets.zero,
              cornerRadius: 16,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                ),
                title: Text(
                  AppLocalizations.of(context)!.manualEntryDate,
                  style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                subtitle: Text(
                  '${_selectedDate.day.toString().padLeft(2, "0")}/${_selectedDate.month.toString().padLeft(2, "0")}/${_selectedDate.year} at ${_selectedDate.hour.toString().padLeft(2, "0")}:${_selectedDate.minute.toString().padLeft(2, "0")}',
                  style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: 32),

            // BP Input Section
            Row(
              children: [
                Expanded(
                  child: _buildBPInput(
                    controller: _sysController,
                    label: AppLocalizations.of(context)!.manualEntrySys,
                    unit: 'mmHg',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildBPInput(
                    controller: _diaController,
                    label: AppLocalizations.of(context)!.manualEntryDia,
                    unit: 'mmHg',
                    color: const Color(0xFF3498DB), // Subtle Blue for DIA
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            
            AppButton(
              text: AppLocalizations.of(context)!.manualEntrySave,
              leading: const Icon(Icons.check_circle_outline),
              onPressed: _saveReading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBPInput({
    required TextEditingController controller,
    required String label,
    required String unit,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 0.6,
              ),
              side: BorderSide(color: color.withValues(alpha: 0.2), width: 1.5),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.displaySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              border: InputBorder.none,
              hintText: '---',
              hintStyle: TextStyle(color: color.withValues(alpha: 0.2)),
              suffixText: unit,
              suffixStyle: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
