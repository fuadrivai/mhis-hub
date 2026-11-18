import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/library/text_form_decoration.dart';
import 'package:fl_mhis_hr/library/valid_form.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_host_search_screen.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_monitor_search_screen.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  final _host = TextEditingController();
  final _visitDateField = TextEditingController();
  final _departureDateField = TextEditingController();
  final _arrivalTimeField = TextEditingController();
  final _departureTimeField = TextEditingController();
  final List<VisitorHost> _monitorEmployees = [];
  VisitorFormOptions? _appliedOptions;
  VisitorOption? _loginEmployee;
  int? _branchId, _categoryId, _purposeId, _hostId;
  int? _autoMonitorId;
  bool _hostSelected = false, _monitorSelectionSet = false;
  late DateTime _visitDate;
  DateTime? _departureDate;
  TimeOfDay? _arrivalTime, _departureTime;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _visitDate = today;
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
      _host,
      _visitDateField,
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
    _visitDateField.text = DateFormat('d MMMM yyyy', 'en').format(_visitDate);
    _departureDateField.text = _departureDate == null
        ? ''
        : DateFormat('d MMMM yyyy', 'en').format(_departureDate!);
  }

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _selectHost() async {
    final host = await Navigator.of(context).push<VisitorHost>(
      MaterialPageRoute(builder: (_) => const VisitorHostSearchScreen()),
    );
    if (host != null && mounted) {
      setState(() {
        _hostSelected = true;
        _hostId = host.id;
        _host.text = host.name;
        _syncDefaultMonitor();
      });
    }
  }

  Future<void> _selectMonitors() async {
    final selected = await Navigator.of(context).push<List<VisitorHost>>(
      MaterialPageRoute(
        builder: (_) => VisitorMonitorSearchScreen(
          initialSelection: List<VisitorHost>.unmodifiable(_monitorEmployees),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _monitorSelectionSet = true;
      _monitorEmployees
        ..clear()
        ..addAll(selected);
      if (!_monitorEmployees.any((employee) => employee.id == _autoMonitorId)) {
        _autoMonitorId = null;
      }
    });
  }

  void _syncDefaultMonitor() {
    final loginEmployee = _loginEmployee;
    if (loginEmployee == null || _hostId == null) return;
    if (_hostId != loginEmployee.id) {
      if (!_monitorEmployees
          .any((employee) => employee.id == loginEmployee.id)) {
        _monitorEmployees.add(
          VisitorHost(id: loginEmployee.id, name: loginEmployee.name),
        );
        _monitorSelectionSet = true;
        _autoMonitorId = loginEmployee.id;
      }
    } else if (_autoMonitorId == loginEmployee.id) {
      _monitorEmployees
          .removeWhere((employee) => employee.id == loginEmployee.id);
      _autoMonitorId = null;
    }
  }

  void _removeMonitor(VisitorHost employee) {
    setState(() {
      _monitorEmployees.removeWhere((item) => item.id == employee.id);
      if (_autoMonitorId == employee.id) _autoMonitorId = null;
    });
  }

  Future<void> _submit() async {
    if (context.read<VisitorBloc>().state.form.submitting) return;
    if (_loginEmployee == null) {
      final currentHost = context.read<VisitorBloc>().state.currentHost;
      _message(currentHost.error == null
          ? 'Loading your employee profile. Please wait.'
          : 'Unable to load your employee profile: ${currentHost.error}');
      return;
    }
    if (!_form.currentState!.validate()) {
      _message('Please correct the highlighted fields.');
      return;
    }
    if (_hostId == null) {
      _message('Please select a host.');
      return;
    }
    if (_arrivalTime == null) {
      _message('Please select an arrival time.');
      return;
    }
    if (_departureDate != null && _departureTime == null) {
      _message(
          'Select an expected departure time or clear the departure date.');
      return;
    }
    final arrival = DateTime(_visitDate.year, _visitDate.month, _visitDate.day,
        _arrivalTime!.hour, _arrivalTime!.minute);
    final departureDate = _departureDate ?? _visitDate;
    if (_departureTime != null) {
      final departure = DateTime(
        departureDate.year,
        departureDate.month,
        departureDate.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );
      if (departure.isBefore(arrival)) {
        _message('Expected departure must not be before arrival.');
        return;
      }
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
      'expected_arrival_time': _formatTime(_arrivalTime!),
      if (_departureTime != null && _departureDate != null)
        'expected_departure_date':
            DateFormat('yyyy-MM-dd', 'en').format(_departureDate!),
      if (_departureTime != null)
        'expected_departure_time': _formatTime(_departureTime!),
      if (_monitorSelectionSet)
        'monitor_employee_ids':
            _monitorEmployees.map((employee) => employee.id).toList(),
      if (optional(_notes) != null) 'notes': optional(_notes),
    };
    context.read<VisitorBloc>().add(SubmitVisitorInvitation(fields, null));
  }

  Widget _label(String text, {bool required = false, bool compact = false}) {
    final label = Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
        child: Text(text,
            maxLines: compact ? 1 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
            style: TextStyle(
                color: AppColors.dark,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w600)),
      ),
      if (required)
        const Text(' *',
            style: TextStyle(
                color: AppColors.danger, fontWeight: FontWeight.bold)),
    ]);
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 18,
          width: double.infinity,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: label,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: label,
    );
  }

  Widget _field(String label, Widget input,
      {bool required = false, bool compact = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label(label, required: required, compact: compact),
        input,
      ]),
    );
  }

  Widget _dateTimeRow(Widget dateField, Widget timeField) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: dateField),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: timeField),
      ],
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {String? Function(String?)? validator,
      TextInputType? keyboardType,
      bool required = false,
      int maxLines = 1,
      int? maxLength,
      TextInputAction? textInputAction = TextInputAction.next,
      Key? key}) {
    return _field(
      label,
      TextFormField(
          key: key,
          controller: controller,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          decoration: TextFormDecoration.box(hintText: label),
          textInputAction: textInputAction ??
              (maxLines > 1 ? TextInputAction.newline : TextInputAction.next)),
      required: required,
    );
  }

  Widget _dropdown(String label, List<VisitorOption> items, int? selected,
      ValueChanged<int?> onChange,
      {Key? key, bool required = true}) {
    return _field(
      label,
      DropdownButtonFormField<int?>(
        key: key,
        initialValue: selected,
        decoration: TextFormDecoration.box(hintText: 'Select $label'),
        items: [
          if (!required)
            const DropdownMenuItem<int?>(
                value: null, child: Text('Not selected')),
          ...items.map((item) =>
              DropdownMenuItem<int?>(value: item.id, child: Text(item.name))),
        ],
        onChanged: onChange,
        validator: required
            ? (value) => ValidForm.dropDownEmpty(value?.toString())
            : null,
        isExpanded: true,
      ),
      required: required,
    );
  }

  Widget _dateField(String label, TextEditingController controller,
      DateTime? date, ValueChanged<DateTime> onChange,
      {Key? key,
      bool compact = false,
      bool required = true,
      DateTime? minimumDate}) {
    return _field(
      label,
      TextFormField(
        key: key,
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        readOnly: true,
        decoration: TextFormDecoration.box(
          hintText: label,
          suffixIcon:
              const Icon(Icons.calendar_today_rounded, color: AppColors.danger),
        ),
        validator: required
            ? (value) => ValidForm.emptyValue(value?.trim() ?? '')
            : null,
        onTap: () async {
          final firstDate = DateUtils.dateOnly(minimumDate ?? DateTime.now());
          final initialDate =
              date == null || date.isBefore(firstDate) ? firstDate : date;
          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate,
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
      required: required,
      compact: compact,
    );
  }

  Widget _timeField(String label, TextEditingController controller,
      TimeOfDay? value, ValueChanged<TimeOfDay> onChange,
      {Key? key, bool compact = false, bool required = true}) {
    return _field(
      label,
      TextFormField(
        key: key,
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        readOnly: true,
        decoration: TextFormDecoration.box(
          hintText: label,
          suffixIcon:
              const Icon(Icons.access_time_rounded, color: AppColors.danger),
        ),
        validator: required
            ? (value) => ValidForm.emptyValue(value?.trim() ?? '')
            : (value) {
                final text = value?.trim() ?? '';
                return text.isEmpty || RegExp(r'^\d{2}:\d{2}$').hasMatch(text)
                    ? null
                    : 'Select a valid time.';
              },
        onTap: () async {
          FocusScope.of(context).unfocus();
          final initialTime = value ?? TimeOfDay.now();
          final picked = await showCupertinoModalPopup<TimeOfDay>(
            context: context,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              onPressed: () => Navigator.pop(modalContext),
                              child: const Text('Cancel'),
                            ),
                            CupertinoButton(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              onPressed: () => Navigator.pop(
                                modalContext,
                                TimeOfDay.fromDateTime(selectedTime),
                              ),
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: CupertinoDatePicker(
                          key: const ValueKey('visitor-time-picker'),
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: selectedTime,
                          use24hFormat: true,
                          onDateTimeChanged: (time) => selectedTime = time,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          if (picked != null && mounted) {
            setState(() {
              onChange(picked);
              controller.text = _formatTime(picked);
            });
          }
        },
      ),
      required: required,
      compact: compact,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitorBloc, VisitorState>(
      listenWhen: (previous, current) =>
          previous.currentHost != current.currentHost,
      listener: (context, state) {
        final host = state.currentHost.host;
        if (host != null) {
          setState(() {
            _loginEmployee = host;
            if (!_hostSelected) {
              _hostId = host.id;
              _host.text = host.name;
            }
            _syncDefaultMonitor();
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
            _message(form.pendingApproval
                ? 'Visitor invitation submitted and waiting for approval.'
                : 'Visitor invitation created.');
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
                                    key: const ValueKey('visitor-category'),
                                    required: false),
                                _dropdown(
                                    'Visit purpose',
                                    options.purposes,
                                    _purposeId,
                                    (value) =>
                                        setState(() => _purposeId = value),
                                    key: const ValueKey('visitor-purpose'),
                                    required: false),
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
                                    onTapOutside: (_) =>
                                        FocusScope.of(context).unfocus(),
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
                                    _loginEmployee == null)
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
                                _field(
                                  'Monitor employees',
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      OutlinedButton.icon(
                                        key: const ValueKey(
                                            'visitor-monitor-employees'),
                                        onPressed: _selectMonitors,
                                        icon: const Icon(Icons.group_add),
                                        label: Text(_monitorEmployees.isEmpty
                                            ? 'Select monitors (optional)'
                                            : 'Select monitors (${_monitorEmployees.length})'),
                                      ),
                                      if (_monitorEmployees.isNotEmpty)
                                        Wrap(
                                          spacing: 6,
                                          children: _monitorEmployees
                                              .map((employee) => Chip(
                                                    label: Text(employee.name),
                                                    onDeleted: () =>
                                                        _removeMonitor(
                                                            employee),
                                                  ))
                                              .toList(),
                                        ),
                                    ],
                                  ),
                                ),
                              ]),
                              _section('Schedule', [
                                _dateTimeRow(
                                  _dateField(
                                      'Visit date', _visitDateField, _visitDate,
                                      (date) {
                                    _visitDate = date;
                                  },
                                      key: const ValueKey('visitor-date'),
                                      compact: true),
                                  _timeField(
                                      'Expected arrival time',
                                      _arrivalTimeField,
                                      _arrivalTime,
                                      (time) => _arrivalTime = time,
                                      key: const ValueKey(
                                          'visitor-arrival-time'),
                                      compact: true),
                                ),
                                _dateTimeRow(
                                  _dateField(
                                      'Expected departure date',
                                      _departureDateField,
                                      _departureDate,
                                      (date) => _departureDate = date,
                                      key: const ValueKey(
                                          'visitor-departure-date'),
                                      required: false,
                                      minimumDate: _visitDate,
                                      compact: true),
                                  _timeField(
                                      'Expected departure time',
                                      _departureTimeField,
                                      _departureTime,
                                      (time) => _departureTime = time,
                                      key: const ValueKey(
                                          'visitor-departure-time'),
                                      required: false,
                                      compact: true),
                                ),
                              ]),
                              _section('Notes', [
                                _textField(_notes, 'Visit notes',
                                    required:
                                        category?.requiresAdditionalInfo ==
                                            true,
                                    maxLines: 3,
                                    textInputAction: TextInputAction.done,
                                    maxLength: 3000,
                                    key: const ValueKey('visitor-notes'),
                                    validator: (value) =>
                                        category?.requiresAdditionalInfo == true
                                            ? ValidForm.emptyValue(
                                                value?.trim() ?? '')
                                            : null),
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
