import 'package:file_picker/file_picker.dart';
import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/library/text_form_decoration.dart';
import 'package:fl_mhis_hr/library/valid_form.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/library/visitor_attachment_validation.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_attachment_preview.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_host_search_screen.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum _AttachmentSource { camera, gallery, file }

class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _notes = TextEditingController();
  final _visitorNotes = TextEditingController();
  final _host = TextEditingController();
  final _visitDateField = TextEditingController();
  final _arrivalDateField = TextEditingController();
  final _departureDateField = TextEditingController();
  final _arrivalTimeField = TextEditingController();
  final _departureTimeField = TextEditingController();
  VisitorFormOptions? _appliedOptions;
  int? _branchId, _categoryId, _purposeId, _hostId;
  bool _hostSelected = false;
  late DateTime _visitDate;
  late DateTime _arrivalDate;
  late DateTime _departureDate;
  TimeOfDay? _arrivalTime, _departureTime;
  VisitorAttachment? _attachment;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _visitDate = _arrivalDate = _departureDate = today;
    _updateDateFields();
    final bloc = context.read<VisitorBloc>();
    bloc.add(const LoadVisitorForm());
    bloc.add(const LoadVisitorCurrentHost());
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _phone,
      _email,
      _company,
      _notes,
      _visitorNotes,
      _host,
      _visitDateField,
      _arrivalDateField,
      _departureDateField,
      _arrivalTimeField,
      _departureTimeField,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateDateFields() {
    final format = DateFormat('d MMMM yyyy', 'en');
    _visitDateField.text = format.format(_visitDate);
    _arrivalDateField.text = format.format(_arrivalDate);
    _departureDateField.text = format.format(_departureDate);
  }

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _pickAttachment() async {
    final source = await showModalBottomSheet<_AttachmentSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(title: Text('Add Attachment')),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, _AttachmentSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, _AttachmentSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('File'),
            onTap: () => Navigator.pop(context, _AttachmentSource.file),
          ),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    try {
      XFile? file;
      if (source == _AttachmentSource.file) {
        final selected = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        );
        if (selected.isNotEmpty) file = selected.first.xFile;
      } else {
        file = await ImagePicker().pickImage(
          source: source == _AttachmentSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
        );
      }
      if (file == null || !mounted) return;
      final error = visitorAttachmentError(file.name, await file.length());
      if (!mounted) return;
      if (error != null) {
        _message(error);
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final bytesError = visitorAttachmentError(file.name, bytes.length);
      if (bytesError != null) {
        _message(bytesError);
        return;
      }
      setState(() => _attachment = VisitorAttachment(file!.name, bytes));
    } catch (error) {
      if (mounted) _message('Unable to select attachment: $error');
    }
  }

  Future<void> _selectHost() async {
    final host = await Navigator.of(context).push<VisitorHost>(
      MaterialPageRoute(builder: (_) => const VisitorHostSearchScreen()),
    );
    if (host != null && mounted) {
      setState(() {
        _hostSelected = true;
        _hostId = host.id;
        _host.text = host.name;
      });
    }
  }

  Future<void> _submit() async {
    if (context.read<VisitorBloc>().state.form.submitting) return;
    if (!_form.currentState!.validate()) {
      _message('Please correct the highlighted fields.');
      return;
    }
    if (_hostId == null) {
      _message('Please select a host.');
      return;
    }
    if (_arrivalTime == null || _departureTime == null) {
      _message('Please select arrival and departure times.');
      return;
    }
    final arrival = DateTime(_arrivalDate.year, _arrivalDate.month,
        _arrivalDate.day, _arrivalTime!.hour, _arrivalTime!.minute);
    final departure = DateTime(_departureDate.year, _departureDate.month,
        _departureDate.day, _departureTime!.hour, _departureTime!.minute);
    if (departure.isBefore(arrival)) {
      _message('Expected departure must not be before arrival.');
      return;
    }
    String? optional(TextEditingController controller) {
      final value = controller.text.trim();
      return value.isEmpty ? null : value;
    }

    final fields = <String, dynamic>{
      'full_name': _name.text.trim(),
      if (optional(_phone) != null) 'phone': optional(_phone),
      if (optional(_email) != null) 'email': optional(_email),
      if (optional(_company) != null) 'company': optional(_company),
      'visitor_category_id': _categoryId,
      'visitor_purpose_id': _purposeId,
      'branch_id': _branchId,
      'host_employee_id': _hostId,
      'visit_date': DateFormat('yyyy-MM-dd', 'en').format(_visitDate),
      'expected_arrival_date':
          DateFormat('d MMMM yyyy', 'en').format(_arrivalDate),
      'expected_arrival_time': _formatTime(_arrivalTime!),
      'expected_departure_date':
          DateFormat('d MMMM yyyy', 'en').format(_departureDate),
      'expected_departure_time': _formatTime(_departureTime!),
      if (optional(_notes) != null) 'notes': optional(_notes),
      if (optional(_visitorNotes) != null)
        'visitor_notes': optional(_visitorNotes),
    };
    context
        .read<VisitorBloc>()
        .add(SubmitVisitorInvitation(fields, _attachment));
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Flexible(
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
        if (required)
          const Text(' *',
              style: TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _field(String label, Widget input, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label(label, required: required),
        input,
      ]),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {String? Function(String?)? validator,
      TextInputType? keyboardType,
      bool required = false,
      int maxLines = 1,
      Key? key}) {
    return _field(
      label,
      TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: TextFormDecoration.box(hintText: label),
      ),
      required: required,
    );
  }

  Widget _dropdown(String label, List<VisitorOption> items, int? selected,
      ValueChanged<int?> onChange,
      {Key? key}) {
    return _field(
      label,
      DropdownButtonFormField<int>(
        key: key,
        initialValue: selected,
        decoration: TextFormDecoration.box(hintText: 'Select $label'),
        items: items
            .map((item) =>
                DropdownMenuItem(value: item.id, child: Text(item.name)))
            .toList(),
        onChanged: onChange,
        validator: (value) => ValidForm.dropDownEmpty(value?.toString()),
        isExpanded: true,
      ),
      required: true,
    );
  }

  Widget _dateField(String label, TextEditingController controller,
      DateTime date, ValueChanged<DateTime> onChange,
      {Key? key}) {
    return _field(
      label,
      TextFormField(
        key: key,
        controller: controller,
        readOnly: true,
        decoration: TextFormDecoration.box(
          hintText: label,
          suffixIcon:
              const Icon(Icons.calendar_today_rounded, color: AppColors.danger),
        ),
        validator: (value) => ValidForm.emptyValue(value?.trim() ?? ''),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null && mounted) {
            setState(() {
              onChange(picked);
              _updateDateFields();
            });
          }
        },
      ),
      required: true,
    );
  }

  Widget _timeField(String label, TextEditingController controller,
      TimeOfDay? value, ValueChanged<TimeOfDay> onChange,
      {Key? key}) {
    return _field(
      label,
      TextFormField(
        key: key,
        controller: controller,
        readOnly: true,
        decoration: TextFormDecoration.box(
          hintText: label,
          suffixIcon:
              const Icon(Icons.access_time_rounded, color: AppColors.danger),
        ),
        validator: (value) => ValidForm.emptyValue(value?.trim() ?? ''),
        onTap: () async {
          final picked = await showTimePicker(
              context: context, initialTime: value ?? TimeOfDay.now());
          if (picked != null && mounted) {
            setState(() {
              onChange(picked);
              controller.text = _formatTime(picked);
            });
          }
        },
      ),
      required: true,
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.dark)),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _attachmentSection() {
    final attachment = _attachment;
    return _section('Attachment', [
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _pickAttachment,
          icon: const Icon(Icons.attach_file_rounded),
          label:
              Text(attachment == null ? 'Add Attachment' : 'Change Attachment'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Text('JPG, JPEG, PNG or WEBP, up to 5 MB',
          style: TextStyle(color: Colors.grey, fontSize: 12)),
      if (attachment != null) ...[
        VisitorAttachmentPreview(
          attachment: attachment,
          onRemove: () => setState(() => _attachment = null),
        ),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitorBloc, VisitorState>(
      listenWhen: (previous, current) =>
          previous.currentHost != current.currentHost,
      listener: (context, state) {
        final host = state.currentHost.host;
        if (host != null && !_hostSelected) {
          setState(() {
            _hostId = host.id;
            _host.text = host.name;
          });
        }
      },
      child: BlocConsumer<VisitorBloc, VisitorState>(
        listenWhen: (previous, current) => previous.form != current.form,
        listener: (context, state) async {
          final form = state.form;
          if (form.options != null && form.options != _appliedOptions) {
            final options = form.options!;
            setState(() {
              _appliedOptions = options;
              if (options.branches
                  .any((branch) => branch.id == options.defaultBranchId)) {
                _branchId = options.defaultBranchId;
              }
            });
          }
          if (form.submissionError != null) {
            _message('Unable to create invitation: ${form.submissionError}');
          } else if (form.created) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visitor invitation created.')));
            await WidgetsBinding.instance.endOfFrame;
            if (context.mounted) Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final form = state.form;
          final options = form.options;
          final category = options?.categories
              .where((item) => item.id == _categoryId)
              .firstOrNull;
          final purpose = options?.purposes
              .where((item) => item.id == _purposeId)
              .firstOrNull;
          return PopScope(
            canPop: !form.submitting,
            child: ThemedPage(
              title: 'Create invitation',
              subtitle: 'Enter visitor information',
              onBack:
                  form.submitting ? () {} : () => Navigator.of(context).pop(),
              child: form.loading ||
                      (options == null && form.optionsError == null)
                  ? const Center(child: CircularProgressIndicator())
                  : form.optionsError != null
                      ? Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('Unable to load form: ${form.optionsError}',
                                textAlign: TextAlign.center),
                            TextButton(
                              onPressed: () => context
                                  .read<VisitorBloc>()
                                  .add(const LoadVisitorForm()),
                              child: const Text('Retry'),
                            ),
                          ]),
                        )
                      : Form(
                          key: _form,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                            child: Column(children: [
                              _section('Visitor information', [
                                _textField(_name, 'Visitor full name',
                                    required: true,
                                    key: const ValueKey('visitor-full-name'),
                                    validator: (value) => ValidForm.emptyValue(
                                        value?.trim() ?? '')),
                                _textField(_phone, 'Phone',
                                    key: const ValueKey('visitor-phone'),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) => (value == null ||
                                                value.trim().isEmpty) &&
                                            _email.text.trim().isEmpty
                                        ? 'Enter a phone number or email'
                                        : null),
                                _textField(_email, 'Email',
                                    key: const ValueKey('visitor-email'),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty &&
                                      _phone.text.trim().isEmpty) {
                                    return 'Enter a phone number or email';
                                  }
                                  if (email.isNotEmpty &&
                                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                          .hasMatch(email)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                }),
                                _textField(_company, 'Company / Organization'),
                              ]),
                              _section('Visit information', [
                                _dropdown(
                                    'Visitor category',
                                    options!.categories,
                                    _categoryId,
                                    (value) =>
                                        setState(() => _categoryId = value),
                                    key: const ValueKey('visitor-category')),
                                _dropdown(
                                    'Visit purpose',
                                    options.purposes,
                                    _purposeId,
                                    (value) =>
                                        setState(() => _purposeId = value),
                                    key: const ValueKey('visitor-purpose')),
                                _dropdown(
                                    'Branch (meeting location)',
                                    options.branches,
                                    _branchId,
                                    (value) =>
                                        setState(() => _branchId = value),
                                    key: const ValueKey('visitor-branch')),
                                _field(
                                  'Host employee',
                                  TextFormField(
                                    key: const ValueKey('visitor-host'),
                                    controller: _host,
                                    readOnly: true,
                                    onTap: _selectHost,
                                    validator: (value) => ValidForm.emptyValue(
                                        value?.trim() ?? ''),
                                    decoration: TextFormDecoration.box(
                                      hintText: state.currentHost.loading
                                          ? 'Loading employee...'
                                          : 'Select host',
                                      suffixIcon: const Icon(Icons.search,
                                          color: AppColors.danger),
                                    ),
                                  ),
                                  required: true,
                                ),
                                if (state.currentHost.error != null &&
                                    _hostId == null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Unable to load your employee profile: ${state.currentHost.error}',
                                          style: const TextStyle(
                                              color: AppColors.danger)),
                                      TextButton(
                                        onPressed: () => context
                                            .read<VisitorBloc>()
                                            .add(
                                                const LoadVisitorCurrentHost()),
                                        child: const Text(
                                            'Retry employee profile'),
                                      ),
                                    ],
                                  ),
                              ]),
                              _section('Schedule', [
                                _dateField(
                                    'Visit date', _visitDateField, _visitDate,
                                    (date) {
                                  _visitDate = date;
                                  _arrivalDate = date;
                                  _departureDate = date;
                                }, key: const ValueKey('visitor-date')),
                                _dateField(
                                    'Expected arrival date',
                                    _arrivalDateField,
                                    _arrivalDate,
                                    (date) => _arrivalDate = date,
                                    key:
                                        const ValueKey('visitor-arrival-date')),
                                _timeField(
                                    'Expected arrival time',
                                    _arrivalTimeField,
                                    _arrivalTime,
                                    (time) => _arrivalTime = time,
                                    key:
                                        const ValueKey('visitor-arrival-time')),
                                _dateField(
                                    'Expected departure date',
                                    _departureDateField,
                                    _departureDate,
                                    (date) => _departureDate = date,
                                    key: const ValueKey(
                                        'visitor-departure-date')),
                                _timeField(
                                    'Expected departure time',
                                    _departureTimeField,
                                    _departureTime,
                                    (time) => _departureTime = time,
                                    key: const ValueKey(
                                        'visitor-departure-time')),
                              ]),
                              _attachmentSection(),
                              _section('Notes', [
                                _textField(_visitorNotes,
                                    'Additional visitor information',
                                    required:
                                        category?.requiresAdditionalInfo ==
                                            true,
                                    maxLines: 3,
                                    validator: (value) =>
                                        category?.requiresAdditionalInfo == true
                                            ? ValidForm.emptyValue(
                                                value?.trim() ?? '')
                                            : null),
                                _textField(_notes, 'Visit notes', maxLines: 3),
                                if (category?.requiresApproval == true ||
                                    purpose?.requiresApproval == true)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Text(
                                        'An approval request will be sent to the host.'),
                                  ),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.danger),
                                    onPressed: form.submitting ? null : _submit,
                                    child: Text(form.submitting
                                        ? 'Submitting...'
                                        : 'Submit invitation'),
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                        ),
            ),
          );
        },
      ),
    );
  }
}
