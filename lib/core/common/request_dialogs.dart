import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:flutter/material.dart';

class RequestEditDialog extends StatelessWidget {
  const RequestEditDialog({
    required this.title,
    required this.formKey,
    required this.loading,
    required this.onSave,
    required this.children,
    this.errorMessage,
    super.key,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final bool loading;
  final VoidCallback onSave;
  final List<Widget> children;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !loading,
    child: AlertDialog(
      title: Text(title),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...children,
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: loading ? null : onSave,
          child: loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    semanticsLabel: 'Saving changes',
                  ),
                )
              : const Text('Save changes'),
        ),
      ],
    ),
  );
}

Future<bool> showDeleteRequestDialog(
  BuildContext context, {
  required String title,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: const Text(
            'This pending request will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}
