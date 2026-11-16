import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_host_search_screen.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VisitorInvitationLinkFormScreen extends StatefulWidget {
  const VisitorInvitationLinkFormScreen({super.key});

  @override
  State<VisitorInvitationLinkFormScreen> createState() =>
      _VisitorInvitationLinkFormScreenState();
}

class _VisitorInvitationLinkFormScreenState
    extends State<VisitorInvitationLinkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _visitDateField = TextEditingController();
  final _emailControllers = <TextEditingController>[TextEditingController()];
  final _arrival = TextEditingController(text: '09:00');
  final _departure = TextEditingController(text: '10:00');
  late DateTime _visitDate;
  VisitorFormOptions? _appliedOptions;
  int? _branchId;
  int? _categoryId;
  int? _purposeId;
  int? _hostId;
  bool _hostSelected = false;

  @override
  void initState() {
    super.initState();
    _visitDate = DateUtils.dateOnly(DateTime.now());
    _updateDateField();
    final bloc = context.read<VisitorBloc>();
    bloc.add(const ResetVisitorInvitationLinks());
    bloc.add(const LoadVisitorForm());
    bloc.add(const LoadVisitorCurrentHost());
  }

  @override
  void dispose() {
    _name.dispose();
    _host.dispose();
    _visitDateField.dispose();
    for (final controller in _emailControllers) {
      controller.dispose();
    }
    _arrival.dispose();
    _departure.dispose();
    super.dispose();
  }

  String _dateParam(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void _updateDateField() {
    _visitDateField.text = DateFormat('dd MMM yyyy').format(_visitDate);
  }

  List<String> _recipientEmails() => _emailControllers
      .map((controller) => controller.text.trim())
      .where((email) => email.isNotEmpty)
      .toList();

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Enter a valid email address.';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_hostId == null ||
        _branchId == null ||
        _categoryId == null ||
        _purposeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all required selections.')),
      );
      return;
    }

    final arrival = _parseTime(_arrival.text);
    final departure = _parseTime(_departure.text);
    if (arrival == null || departure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter time in 24-hour HH:mm format.')),
      );
      return;
    }
    if (departure.hour * 60 + departure.minute <=
        arrival.hour * 60 + arrival.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Departure time must be after arrival time.')),
      );
      return;
    }

    context.read<VisitorBloc>().add(CreateVisitorInvitationLinks({
          'name': _name.text.trim(),
          'host_employee_id': _hostId,
          'branch_id': _branchId,
          'visitor_category_id': _categoryId,
          'visitor_purpose_id': _purposeId,
          'visit_date': _dateParam(_visitDate),
          'expected_arrival_time': _arrival.text.trim(),
          'expected_departure_time': _departure.text.trim(),
          'share_link_count': 0,
          'recipient_emails': _recipientEmails(),
        }));
  }

  void _addEmail() {
    setState(() => _emailControllers.add(TextEditingController()));
  }

  void _removeEmail(int index) {
    final controller = _emailControllers.removeAt(index);
    controller.dispose();
    setState(() {});
  }

  TimeOfDay? _parseTime(String value) {
    final match =
        RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(value.trim());
    if (match == null) return null;
    return TimeOfDay(
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }

  Future<void> _selectHost() async {
    final host = await Navigator.of(context).push<VisitorHost>(
      MaterialPageRoute(builder: (_) => const VisitorHostSearchScreen()),
    );
    if (host == null || !mounted) return;
    setState(() {
      _hostSelected = true;
      _hostId = host.id;
      _host.text = host.name;
    });
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() {
        _visitDate = selected;
        _updateDateField();
      });
    }
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation link copied.')),
      );
    }
  }

  Widget _section(String title, List<Widget> children) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E9EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _field({
    Key? key,
    required String label,
    Widget? child,
    String? Function(String?)? validator,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: key,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFFFAFAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE9E9EF)),
            ),
            suffixIcon: child,
          ),
        ),
      );

  Widget _dropdown({
    required Key key,
    required String label,
    required List<VisitorOption> options,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DropdownButtonFormField<int>(
          key: key,
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFFFAFAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE9E9EF)),
            ),
          ),
          items: options
              .map((option) => DropdownMenuItem(
                    value: option.id,
                    child: Text(option.name),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (selected) => selected == null ? 'Select $label.' : null,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitorBloc, VisitorState>(
      listenWhen: (previous, current) =>
          previous.form != current.form ||
          previous.currentHost != current.currentHost ||
          previous.invitationLinks != current.invitationLinks,
      listener: (context, state) {
        final options = state.form.options;
        if (options != null && options != _appliedOptions) {
          setState(() {
            _appliedOptions = options;
            if (options.branches
                .any((branch) => branch.id == options.defaultBranchId)) {
              _branchId = options.defaultBranchId;
            }
          });
        }
        final host = state.currentHost.host;
        if (host != null && !_hostSelected) {
          setState(() {
            _hostId = host.id;
            _host.text = host.name;
          });
        }
        final error = state.invitationLinks.error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to create links: $error')),
          );
        }
      },
      builder: (context, state) {
        final status = state.invitationLinks;
        final options = state.form.options;
        return PopScope(
          canPop: !status.submitting,
          child: ThemedPage(
            title: status.result == null
                ? 'Create invitation link'
                : 'Invitation links',
            subtitle: status.result == null
                ? 'Create links for guest registration'
                : 'Copy and share the generated links',
            onBack: status.submitting
                ? () {}
                : () => Navigator.of(context).pop(status.result != null),
            child: status.result != null
                ? _resultView(status.result!)
                : state.form.loading ||
                        (options == null && state.form.optionsError == null)
                    ? const Center(child: CircularProgressIndicator())
                    : state.form.optionsError != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Unable to load form: ${state.form.optionsError}'),
                                TextButton(
                                  onPressed: () => context
                                      .read<VisitorBloc>()
                                      .add(const LoadVisitorForm()),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _formView(options!, status),
          ),
        );
      },
    );
  }

  Widget _formView(
      VisitorFormOptions options, VisitorInvitationLinksStatus status) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          _section('Link details', [
            _field(
              key: const ValueKey('visitor-link-name'),
              label: 'Link name',
              controller: _name,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a name for this link.'
                  : null,
            ),
            _field(
              key: const ValueKey('visitor-link-host'),
              label: 'Host',
              controller: _host,
              readOnly: true,
              onTap: _selectHost,
              child: const Icon(Icons.search, color: AppColors.danger),
              validator: (_) =>
                  _hostId == null ? 'Select a host employee.' : null,
            ),
            _dropdown(
              key: const ValueKey('visitor-link-branch'),
              label: 'Branch',
              options: options.branches,
              value: _branchId,
              onChanged: (value) => setState(() => _branchId = value),
            ),
            _dropdown(
              key: const ValueKey('visitor-link-category'),
              label: 'Visitor category',
              options: options.categories,
              value: _categoryId,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            _dropdown(
              key: const ValueKey('visitor-link-purpose'),
              label: 'Visit purpose',
              options: options.purposes,
              value: _purposeId,
              onChanged: (value) => setState(() => _purposeId = value),
            ),
          ]),
          _section('Visit schedule', [
            _field(
              key: const ValueKey('visitor-link-date'),
              label: 'Visit date',
              controller: _visitDateField,
              readOnly: true,
              onTap: _selectDate,
              child: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.danger),
            ),
            Row(
              children: [
                Expanded(
                  child: _field(
                    key: const ValueKey('visitor-link-arrival'),
                    label: 'Arrival (HH:mm)',
                    controller: _arrival,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    ],
                    validator: (value) =>
                        _parseTime(value ?? '') == null ? 'Use HH:mm.' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    key: const ValueKey('visitor-link-departure'),
                    label: 'Departure (HH:mm)',
                    controller: _departure,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    ],
                    validator: (value) =>
                        _parseTime(value ?? '') == null ? 'Use HH:mm.' : null,
                  ),
                ),
              ],
            ),
          ]),
          _section('Recipients', [
            for (var index = 0; index < _emailControllers.length; index++)
              _field(
                key: ValueKey('visitor-link-email-$index'),
                label: 'Recipient email ${index + 1} (optional)',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined,
                        color: AppColors.danger, size: 20),
                    IconButton(
                      key: ValueKey('visitor-link-remove-email-$index'),
                      tooltip: 'Remove recipient email ${index + 1}',
                      onPressed: () => _removeEmail(index),
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.danger),
                    ),
                  ],
                ),
                controller: _emailControllers[index],
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                key: const ValueKey('visitor-link-add-email'),
                onPressed: _addEmail,
                icon: const Icon(Icons.add),
                label: const Text('Add email'),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const ValueKey('create-invitation-links'),
            onPressed: status.submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: status.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.link),
            label: Text(status.submitting ? 'Creating...' : 'Create links'),
          ),
        ],
      ),
    );
  }

  Widget _resultView(VisitorInvitationLinksResult result) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _section('Links ready to share', [
          Text(result.name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Visit date: ${DateFormat('dd MMM yyyy').format(
            DateTime.parse(result.visitDate),
          )}'),
          if (result.expiresAt != null) ...[
            const SizedBox(height: 4),
            Text('Expires: ${DateFormat('dd MMM yyyy HH:mm').format(
              DateTime.parse(result.expiresAt!).toLocal(),
            )}'),
          ],
        ]),
        if (result.emailFailures.isNotEmpty)
          _section('Email delivery issues', [
            for (final failure in result.emailFailures)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.error_outline, color: AppColors.danger),
                title: Text(failure),
              ),
          ]),
        for (final link in result.links)
          _section(link.recipientEmail ?? 'Manual link', [
            if (link.deliveryStatus != null)
              Text('Status: ${link.deliveryStatus}'),
            const SizedBox(height: 8),
            SelectableText(link.url),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _copyLink(link.url),
                icon: const Icon(Icons.copy),
                label: const Text('Copy link'),
              ),
            ),
          ]),
        if (result.links.isEmpty)
          const Center(child: Text('No links were returned by the server.')),
      ],
    );
  }
}
