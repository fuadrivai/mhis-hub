import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:flutter/material.dart';

class VisitorAttachmentPreview extends StatelessWidget {
  const VisitorAttachmentPreview({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  final VisitorAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            attachment.bytes,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            semanticLabel: 'Attachment preview',
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              height: 80,
              child: Center(child: Text('Unable to preview this image.')),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.image_rounded, color: AppColors.danger),
          title: Text(attachment.name,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
              '${(attachment.bytes.lengthInBytes / 1024).toStringAsFixed(2)} KB'),
          trailing: IconButton(
            tooltip: 'Remove attachment',
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}
