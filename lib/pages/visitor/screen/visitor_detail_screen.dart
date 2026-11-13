import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VisitorDetailScreen extends StatefulWidget {
  const VisitorDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<VisitorDetailScreen> createState() => _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends State<VisitorDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VisitorBloc>().add(LoadVisitorDetail(widget.id));
  }

  Future<void> _cancel() async {
    final form = GlobalKey<FormState>();
    var reasonText = '';
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel invitation'),
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            maxLines: 3,
            onChanged: (value) => reasonText = value,
            decoration: const InputDecoration(labelText: 'Reason'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a cancellation reason'
                : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, reasonText.trim());
              }
            },
            child: const Text('Confirm cancellation'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    context.read<VisitorBloc>().add(CancelVisitorInvitation(widget.id, reason));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitorBloc, VisitorState>(
      listenWhen: (previous, current) => previous.detail != current.detail,
      listener: (context, state) async {
        final detail = state.detail;
        if (detail.cancelError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Unable to cancel: ${detail.cancelError}')));
        } else if (detail.cancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invitation cancelled.')));
          await WidgetsBinding.instance.endOfFrame;
          if (context.mounted) Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final detail = state.detail;
        return PopScope(
          canPop: !detail.cancelling,
          child: ThemedPage(
            title: 'Visit detail',
            subtitle: 'Visitor information',
            onBack:
                detail.cancelling ? () {} : () => Navigator.of(context).pop(),
            child: Builder(
              builder: (context) {
                if (detail.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (detail.error != null) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Unable to load visit: ${detail.error}',
                          textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () => context
                            .read<VisitorBloc>()
                            .add(LoadVisitorDetail(widget.id)),
                        child: const Text('Retry'),
                      ),
                    ]),
                  );
                }
                final visit = detail.visit;
                if (visit == null || visit.id != widget.id) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  children: [
                    _VisitorHero(visit: visit),
                    const SizedBox(height: 12),
                    _DetailSection(
                      title: 'Visit schedule',
                      icon: Icons.schedule_rounded,
                      children: [
                        _DetailRow(
                          label: 'Visit date',
                          value: _formatVisitDate(visit.date),
                          icon: Icons.calendar_today_outlined,
                        ),
                        _DetailRow(
                          label: 'Arrival',
                          value: _formatVisitTime(visit.arrival),
                          icon: Icons.login_rounded,
                        ),
                        _DetailRow(
                          label: 'Departure',
                          value: _formatVisitTime(visit.departure),
                          icon: Icons.logout_rounded,
                        ),
                        if (_hasValue(visit.checkIn))
                          _DetailRow(
                            label: 'Check in',
                            value: _formatVisitDateTime(visit.checkIn),
                            icon: Icons.login_rounded,
                          ),
                        if (_hasValue(visit.checkOut))
                          _DetailRow(
                            label: 'Check out',
                            value: _formatVisitDateTime(visit.checkOut),
                            icon: Icons.logout_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DetailSection(
                      title: 'Visitor information',
                      icon: Icons.person_outline,
                      children: [
                        _DetailRow(
                          label: 'Phone',
                          value: visit.phone,
                          icon: Icons.phone_outlined,
                        ),
                        _DetailRow(
                          label: 'Email',
                          value: visit.email,
                          icon: Icons.email_outlined,
                        ),
                        _DetailRow(
                          label: 'Company',
                          value: visit.company,
                          icon: Icons.business_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DetailSection(
                      title: 'Visit information',
                      icon: Icons.info_outline,
                      children: [
                        _DetailRow(
                          label: 'Host',
                          value: visit.host,
                          icon: Icons.badge_outlined,
                        ),
                        _DetailRow(
                          label: 'Branch',
                          value: visit.branch,
                          icon: Icons.location_on_outlined,
                        ),
                        _DetailRow(
                          label: 'Category',
                          value: visit.category,
                          icon: Icons.category_outlined,
                        ),
                        _DetailRow(
                          label: 'Purpose',
                          value: visit.purpose,
                          icon: Icons.event_note_outlined,
                        ),
                        _DetailRow(
                          label: 'Registration method',
                          value: visit.registrationMethod,
                          icon: Icons.how_to_reg_outlined,
                        ),
                      ],
                    ),
                    if (_hasValue(visit.notes) ||
                        _hasValue(visit.cancellationReason)) ...[
                      const SizedBox(height: 12),
                      _DetailSection(
                        title: 'Notes',
                        icon: Icons.notes_rounded,
                        children: [
                          _DetailRow(
                            label: 'Visit notes',
                            value: visit.notes,
                          ),
                          _DetailRow(
                            label: 'Cancellation reason',
                            value: visit.cancellationReason,
                          ),
                        ],
                      ),
                    ],
                    if (visit.attachments.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _DetailSection(
                        title: 'Attachments',
                        icon: Icons.attach_file_rounded,
                        children: [
                          for (final attachment in visit.attachments)
                            _VisitorMediaPreview(media: attachment),
                        ],
                      ),
                    ],
                    if (visit.canCancel)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger),
                          onPressed: detail.cancelling ? null : _cancel,
                          child: Text(detail.cancelling
                              ? 'Cancelling...'
                              : 'Cancel invitation'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

String _formatVisitDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : DateFormat('dd MMMM yyyy', 'en').format(date);
}

String _formatVisitTime(String? value) {
  if (!_hasValue(value)) return '—';
  final time = RegExp(r'(?:T|\s)(\d{2}):(\d{2})').firstMatch(value!);
  return time == null ? value : '${time.group(1)}:${time.group(2)}';
}

String _formatVisitDateTime(String? value) {
  if (!_hasValue(value)) return '—';
  final date = DateTime.tryParse(value!);
  return date == null
      ? value
      : DateFormat('dd MMM yyyy HH:mm', 'en').format(date);
}

class _VisitorHero extends StatelessWidget {
  const _VisitorHero({required this.visit});

  final Visit visit;

  @override
  Widget build(BuildContext context) {
    final color = visit.status.toLowerCase() == 'cancelled'
        ? AppColors.danger
        : visit.status.toLowerCase() == 'expected'
            ? const Color(0xFF2F6FED)
            : const Color(0xFF168A62);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E9EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_outline,
                size: 28, color: AppColors.danger),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.visitor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF252633),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Visit ${visit.code}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(visit.status),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final visibleChildren = children.where((child) {
      if (child is _DetailRow) return _hasValue(child.value);
      return true;
    }).toList();
    if (visibleChildren.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.danger),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF252633),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...visibleChildren,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.icon});

  final String label;
  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (!_hasValue(value)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: Colors.grey.shade600),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: icon == null ? 124 : 112,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF30313D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorMediaPreview extends StatelessWidget {
  const _VisitorMediaPreview({required this.media});

  final VisitorMedia media;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _mediaUrl(media.url);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: const Color(0xFFF7F7FA),
          child: InkWell(
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.black,
                insetPadding: const EdgeInsets.all(16),
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _MediaFallback(media: media),
                  ),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  imageUrl,
                  height: 190,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 190,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (_, __, ___) => _MediaFallback(media: media),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file_rounded,
                          size: 16, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          media.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.zoom_in_rounded,
                          size: 18, color: Colors.black54),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _mediaUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri?.hasScheme == true) return value;
  final path = value.replaceFirst(RegExp(r'^/+'), '');
  final storagePath = path.startsWith('storage/') ? path : 'storage/$path';
  return Uri.parse(Api.url).resolve(storagePath).toString();
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({required this.media});

  final VisitorMedia media;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file_outlined,
                size: 32, color: AppColors.danger),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                media.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status) => status
    .split(RegExp(r'[_\s-]+'))
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
