import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _noteController = TextEditingController();
  PlatformFile? _attachmentFile;

  @override
  void initState() {
    super.initState();
    context.read<TimeoffBloc>().add(const OnInitForm());
    _initControllers();
  }

  void _initControllers() {
    _controllers = {};
    for (final field in widget.timeoff.schema ?? []) {
      _controllers![field.name ?? ''] = TextEditingController();
    }
    // Add setState listeners to any controller referenced by a show_if condition.
    final watched = <String>{};
    for (final field in widget.timeoff.schema ?? []) {
      final watchedField = field.showIf?['field'] as String?;
      if (watchedField != null && watched.add(watchedField)) {
        _controllers![watchedField]?.addListener(() {
          if (mounted) setState(() {});
        });
      }
    }
  }

  bool _isFieldVisible(TimeoffSchema schema) {
    if (schema.showIf == null) return true;
    final watchedField = schema.showIf!['field'] as String?;
    final expectedValue = schema.showIf!['value'] as String?;
    if (watchedField == null || expectedValue == null) return true;
    return (_controllers?[watchedField]?.text ?? '') == expectedValue;
  }

  bool _isImageAttachment(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    return extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png' ||
        extension == 'gif' ||
        extension == 'webp' ||
        extension == 'bmp';
  }

  bool _isPdfAttachment(PlatformFile file) {
    return file.extension?.toLowerCase() == 'pdf';
  }

  GlobalKey<FormState> _getFormKey() {
    _formKey ??= GlobalKey<FormState>();
    return _formKey!;
  }

  Map<String, TextEditingController> _getControllers() {
    _controllers ??= {};
    return _controllers!;
  }

  @override
  void dispose() {
    if (_controllers != null) {
      for (var controller in _controllers!.values) {
        controller.dispose();
      }
    }
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final choice = await showModalBottomSheet<_AttachmentSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.grayshade,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Add Attachment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, _AttachmentSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, _AttachmentSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_rounded,
                  color: AppColors.primary),
              title: const Text('File'),
              onTap: () => Navigator.pop(ctx, _AttachmentSource.file),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (choice == null || !mounted) return;

    try {
      if (choice == _AttachmentSource.file) {
        final result = await FilePicker.pickFiles(
          allowMultiple: false,
          withData: true,
        );
        if (result != null && result.files.isNotEmpty && mounted) {
          setState(() => _attachmentFile = result.files.first);
        }
      } else {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: choice == _AttachmentSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          imageQuality: 85,
        );
        if (image != null && mounted) {
          final bytes = await image.readAsBytes();
          setState(() {
            _attachmentFile = PlatformFile(
              name: image.name,
              size: bytes.length,
              bytes: bytes,
              path: image.path,
            );
          });
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick attachment'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext ctx, String fieldName) async {
    if (!mounted) return;
    final controller = _getControllers()[fieldName];
    if (controller == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    TimeOfDay initialTime = TimeOfDay.now();
    final currentValue = controller.text.trim();
    if (currentValue.isNotEmpty) {
      final parts = currentValue.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          initialTime = TimeOfDay(
            hour: hour.clamp(0, 23),
            minute: minute.clamp(0, 59),
          );
        }
      }
    }

    try {
      final picked = await showCupertinoModalPopup<TimeOfDay>(
        context: ctx,
        builder: (modalContext) {
          var selectedTime = DateTime(
            2000,
            1,
            1,
            initialTime.hour,
            initialTime.minute,
          );

          return Container(
            height: 320 + MediaQuery.of(modalContext).padding.bottom,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                          child: const Text('Cancel'),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          onPressed: () {
                            Navigator.pop(
                              modalContext,
                              TimeOfDay.fromDateTime(selectedTime),
                            );
                          },
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: selectedTime,
                      use24hFormat: true,
                      onDateTimeChanged: (value) {
                        selectedTime = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (picked == null || !mounted) return;

      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      controller.text = '$h:$m';
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Failed to open time picker'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _selectDuration(BuildContext ctx, String fieldName) async {
    if (!mounted) return;
    final controller = _getControllers()[fieldName];
    if (controller == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    int initialHour = 0;
    int initialMinute = 0;
    final currentValue = controller.text.trim();
    final durationMatch = RegExp(
      r'^(\d{1,2})\s+hours\s*:\s*(\d{1,2})\s+minutes$',
      caseSensitive: false,
    ).firstMatch(currentValue);
    if (durationMatch != null) {
      final parsedHour = int.tryParse(durationMatch.group(1) ?? '0');
      final parsedMinute = int.tryParse(durationMatch.group(2) ?? '0');
      if (parsedHour != null) initialHour = parsedHour.clamp(0, 23);
      if (parsedMinute != null) initialMinute = parsedMinute.clamp(0, 59);
    }

    try {
      final picked = await showCupertinoModalPopup<Duration>(
        context: ctx,
        builder: (modalContext) {
          int selectedHour = initialHour;
          int selectedMinute = initialMinute;

          return Container(
            height: 340 + MediaQuery.of(modalContext).padding.bottom,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                          child: const Text('Cancel'),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          onPressed: () {
                            Navigator.pop(
                              modalContext,
                              Duration(
                                hours: selectedHour,
                                minutes: selectedMinute,
                              ),
                            );
                          },
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: initialHour,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              selectedHour = index;
                            },
                            children: List.generate(24, (index) {
                              final text = index.toString().padLeft(2, '0');
                              return Center(
                                child: Text('$text hours'),
                              );
                            }),
                          ),
                        ),
                        Container(width: 1, color: AppColors.grayshade),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: initialMinute,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              selectedMinute = index;
                            },
                            children: List.generate(60, (index) {
                              final text = index.toString().padLeft(2, '0');
                              return Center(
                                child: Text('$text minutes'),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (picked == null || !mounted) return;

      final h = picked.inHours.toString().padLeft(2, '0');
      final m = picked.inMinutes.remainder(60).toString().padLeft(2, '0');
      controller.text = '$h hours : $m minutes';
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Failed to open duration picker'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
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
    final schemaMap = Map.fromEntries(
      (widget.timeoff.schema ?? []).map((s) => MapEntry(s.name ?? '', s)),
    );
    final formData = <String, String>{};
    _getControllers().forEach((key, controller) {
      final fieldSchema = schemaMap[key];
      if (fieldSchema == null || _isFieldVisible(fieldSchema)) {
        if (controller.text.isNotEmpty) formData[key] = controller.text;
      }
    });

    if (mounted) {
      context.read<TimeoffBloc>().add(
            OnSubmitTimeoffForm(
              timeoffId: widget.timeoff.id ?? 0,
              formData: formData,
              note: _noteController.text,
              attachmentPath: _attachmentFile?.path,
            ),
          );
    }
  }

  Future<void> _handleFormSubmissionState(TimeoffState state) async {
    if (state.isSuccess) {
      Common.flushBar(
        context,
        title: 'Success',
        message: 'Timeoff request submitted successfully!',
      ).then((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                RequestDetailScreen(requestId: state.requestId ?? 0),
          ),
        );
      });
    } else if (state.isFormError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.errorMessage}'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildFormField(BuildContext ctx, TimeoffSchema schema, int index) {
    if (!_isFieldVisible(schema)) return const SizedBox.shrink();

    final fieldName = schema.name ?? '';
    final label = schema.label ?? schema.name ?? 'Field ${index + 1}';
    final isRequired = schema.required ?? false;
    final controller = _getControllers()[fieldName];

    Widget input;

    if (schema.type == 'select') {
      final options = (schema.options ?? []).map((e) => e.toString()).toList();
      input = DropdownButtonFormField<String>(
        initialValue:
            (controller?.text.isNotEmpty == true) ? controller!.text : null,
        decoration: TextFormDecoration.box(hintText: label),
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: (value) {
          if (value != null) controller?.text = value;
        },
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      );
    } else if (schema.type == 'time') {
      input = TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => fieldName == 'duration'
            ? _selectDuration(ctx, fieldName)
            : _selectTime(ctx, fieldName),
        decoration: TextFormDecoration.box(
          hintText: fieldName == 'duration' ? '00 hours : 00 minutes' : label,
          suffixIcon: const Icon(
            Icons.access_time_rounded,
            color: AppColors.primary,
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      );
    } else if (schema.type == 'date') {
      input = TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(fieldName),
        decoration: TextFormDecoration.box(
          hintText: label,
          suffixIcon: const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      );
    } else {
      input = TextFormField(
        controller: controller,
        decoration: TextFormDecoration.box(hintText: label),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                label,
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
        input,
        const SizedBox(height: 16),
        const SizedBox(height: 16),
      ],
    );
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
      resizeToAvoidBottomInset: false,
      body: BlocListener<TimeoffBloc, TimeoffState>(
        listenWhen: (previous, current) {
          final successTriggered = !previous.isSuccess && current.isSuccess;
          final errorTriggered = !previous.isFormError && current.isFormError;
          return successTriggered || errorTriggered;
        },
        listener: (context, state) {
          _handleFormSubmissionState(state);
        },
        child: BlocBuilder<TimeoffBloc, TimeoffState>(
          builder: (context, state) {
            if (state.isFormLoading) {
              return const LoadingWidget();
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: size.width > 720 ? 20 : 10,
                vertical: 10,
              ),
              child: Form(
                key: _getFormKey(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                ),
                                child: state.employee?.personal?.avatar != null
                                    ? ClipOval(
                                        child: Image.network(
                                          state.employee?.personal!.avatar ??
                                              "",
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
                    const SizedBox(height: 10),

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
                                  (entry) => _buildFormField(
                                      context, entry.value, entry.key),
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
                    const SizedBox(height: 10),

                    // Additional fields
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
                          const Text(
                            'Attachment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 22, 21, 21),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickAttachment,
                              icon: const Icon(Icons.attach_file_rounded),
                              label: Text(
                                _attachmentFile == null
                                    ? 'Add Attachment'
                                    : 'Attachment Selected',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side:
                                    const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_attachmentFile != null) ...[
                            const SizedBox(height: 8),
                            if (_isImageAttachment(_attachmentFile!) &&
                                _attachmentFile!.bytes != null) ...[
                              Container(
                                width: double.infinity,
                                height: 180,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.grayshade),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.memory(
                                  _attachmentFile!.bytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                            if (_isPdfAttachment(_attachmentFile!)) ...[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: Colors.red.shade600,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PDF Document',
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.grayshade),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _isPdfAttachment(_attachmentFile!)
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : AppColors.secondary
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _isPdfAttachment(_attachmentFile!)
                                          ? Icons.picture_as_pdf_rounded
                                          : _isImageAttachment(_attachmentFile!)
                                              ? Icons.image_rounded
                                              : Icons.insert_drive_file_rounded,
                                      size: 20,
                                      color: _isPdfAttachment(_attachmentFile!)
                                          ? Colors.red.shade600
                                          : _isImageAttachment(_attachmentFile!)
                                              ? Colors.blue.shade600
                                              : AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _attachmentFile!.name,
                                          style: const TextStyle(
                                            color: AppColors.dark,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${(_attachmentFile!.size / 1024).toStringAsFixed(2)} KB',
                                          style: TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() => _attachmentFile = null);
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: AppColors.danger,
                                      size: 20,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    tooltip: 'Delete attachment',
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 22, 21, 21),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 4,
                            decoration: TextFormDecoration.box(
                              hintText: 'Type note',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: state.isFormLoading ? null : _submitForm,
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
                        icon: state.isFormLoading
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
                          state.isFormLoading
                              ? 'Submitting...'
                              : 'Submit Request',
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
          },
        ),
      ),
    );
  }
}

enum _AttachmentSource { camera, gallery, file }
