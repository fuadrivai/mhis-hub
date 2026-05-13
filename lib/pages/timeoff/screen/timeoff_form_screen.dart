import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TimeoffFormScreen extends StatefulWidget {
  final Timeoff timeoff;
  const TimeoffFormScreen({super.key, required this.timeoff});

  @override
  State<TimeoffFormScreen> createState() => _TimeoffFormScreenState();
}

class _TimeoffFormScreenState extends State<TimeoffFormScreen> {
  GlobalKey<FormState>? _formKey;
  Map<String, TextEditingController>? _controllers;
  bool _isSubmitting = false;

  GlobalKey<FormState> _getFormKey() {
    _formKey ??= GlobalKey<FormState>();
    return _formKey!;
  }

  Map<String, TextEditingController> _getControllers() {
    if (_controllers == null) {
      _controllers = {};
      for (var field in widget.timeoff.schema ?? []) {
        _controllers![field.name ?? ''] = TextEditingController();
      }
    }
    return _controllers!;
  }

  @override
  void dispose() {
    if (_controllers != null) {
      for (var controller in _controllers!.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _selectDate(String fieldName) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.dark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _getControllers()[fieldName]?.text = picked.toString().split(' ')[0];
    }
  }

  Future<void> _submitForm() async {
    if (!_getFormKey().currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Prepare form data
      final formData = <String, String>{};
      _getControllers().forEach((key, controller) {
        formData[key] = controller.text;
      });

      // TODO: Submit to API
      // await TimeoffApi.submitRequest(widget.timeoff.id!, formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Timeoff request submitted successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildFormField(TimeoffSchema schema, int index) {
    final isDate = schema.type == 'date';
    final isRequired = schema.required ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                schema.label ?? schema.name ?? 'Field ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              if (isRequired)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        TextFormField(
          controller: _getControllers()[schema.name ?? ''],
          readOnly: isDate,
          onTap: isDate ? () => _selectDate(schema.name ?? '') : null,
          decoration: TextFormDecoration.box(
            hintText: schema.label ?? schema.name,
            suffixIcon: isDate
                ? const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary)
                : null,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '${schema.label ?? schema.name} is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  initState() {
    super.initState();
    context.read<TimeoffBloc>().add(const OnInitForm());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final schema = widget.timeoff.schema ?? <TimeoffSchema>[];

    return Scaffold(
        appBar: CustomAppbar(
          backgroundColor: AppColors.whiteshade,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: widget.timeoff.name ?? "Request Timeoff",
        ),
        body: BlocBuilder<TimeoffBloc, TimeoffState>(builder: (context, state) {
          if (state.isFormLoading) {
            return const LoadingWidget();
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width > 720 ? 32 : 16,
              vertical: 20,
            ),
            child: Form(
              key: _getFormKey(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card - Employee Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grayshade),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dark.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Employee Avatar/Picture
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                              child: state.employee?.personal?.avatar != null
                                  ? ClipOval(
                                      child: Image.network(
                                        state.employee?.personal!.avatar ?? "",
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              color: AppColors.primary,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.employee?.personal?.fullname ??
                                        'Employee',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.employee?.employment?.jobPosition
                                            ?.name ??
                                        '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: AppColors.grayshade,
                        ),
                        const SizedBox(height: 12),
                        // Employee Details
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Division',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.employee?.employment?.organization
                                            ?.name ??
                                        '-',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.employee?.personal?.email ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form fields
                  if (schema.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.grayshade),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dark.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ...schema.asMap().entries.map(
                                (entry) =>
                                    _buildFormField(entry.value, entry.key),
                              ),
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No fields required for this timeoff type',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit Request',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
