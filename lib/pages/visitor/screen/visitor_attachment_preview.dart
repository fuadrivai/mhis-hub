import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:material_ui/material_ui.dart';

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
    final isPdf = attachment.name.toLowerCase().endsWith('.pdf');
    return Column(
      children: [
        const SizedBox(height: 12),
        if (isPdf)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, size: 44, color: AppColors.danger),
                SizedBox(height: 6),
                Text('PDF attachment'),
              ],
            ),
          )
        else
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
          leading: Icon(
            isPdf ? Icons.picture_as_pdf : Icons.image_rounded,
            color: AppColors.danger,
          ),
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
