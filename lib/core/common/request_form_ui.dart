import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_theme.dart';
import 'app_loading_indicator.dart';

InputDecoration cleanRequestInput(String hint, {IconData? icon}) {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Color(0xFFD0D5DD)),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    suffixIcon: icon == null
        ? null
        : Icon(icon, size: 18, color: AppColors.muted),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
    ),
    errorMaxLines: 3,
  );
}

class RequestFieldLabel extends StatelessWidget {
  const RequestFieldLabel(this.label, {this.requiredField = false, super.key});
  final String label;
  final bool requiredField;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text.rich(
      TextSpan(
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: label),
          if (requiredField)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    ),
  );
}

class RequestFieldPair extends StatelessWidget {
  const RequestFieldPair({
    required this.first,
    required this.second,
    super.key,
  });
  final Widget first, second;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(13) > 18) {
        return Column(children: [first, const SizedBox(height: 16), second]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 12),
          Expanded(child: second),
        ],
      );
    },
  );
}

class RequestReasonField extends StatelessWidget {
  const RequestReasonField({
    required this.controller,
    required this.enabled,
    this.hint = 'Briefly explain your request',
    super.key,
  });
  final TextEditingController controller;
  final bool enabled;
  final String hint;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const RequestFieldLabel('Reason', requiredField: true),
      TextFormField(
        controller: controller,
        enabled: enabled,
        minLines: 4,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: cleanRequestInput(hint),
        style: const TextStyle(color: AppColors.ink, fontSize: 14, height: 1.5),
        validator: (value) => (value?.trim().length ?? 0) < 5
            ? 'Please provide a little more detail.'
            : null,
      ),
    ],
  );
}

class CleanRequestForm extends StatelessWidget {
  const CleanRequestForm({
    required this.title,
    required this.description,
    required this.formKey,
    required this.fields,
    required this.loading,
    required this.onSubmit,
    this.editing = false,
    this.errorMessage,
    super.key,
  });
  final String title, description;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final bool loading, editing;
  final VoidCallback onSubmit;
  final String? errorMessage;
  @override
  Widget build(BuildContext context) => ListView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        description,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 24),
      Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...fields,
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton.icon(
                onPressed: loading ? null : onSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: loading
                    ? const AppLoadingIndicator(
                        size: 16,
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                    : Icon(
                        editing ? LucideIcons.check : LucideIcons.send,
                        size: 16,
                      ),
                label: Text(
                  loading
                      ? (editing ? 'Saving...' : 'Submitting...')
                      : (editing ? 'Save changes' : 'Submit request'),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class RequestTimeField extends StatelessWidget {
  const RequestTimeField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.clearable = false,
    this.initialTime = const TimeOfDay(hour: 9, minute: 0),
    super.key,
  });
  final String label;
  final TimeOfDay? value;
  final bool enabled, clearable;
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay?> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RequestFieldLabel(label),
      TextFormField(
        key: ValueKey('$label-${value?.hour}:${value?.minute}'),
        readOnly: true,
        enabled: enabled,
        initialValue: value?.format(context),
        style: const TextStyle(color: AppColors.ink, fontSize: 14),
        decoration: cleanRequestInput('Select time', icon: LucideIcons.clock)
            .copyWith(
              suffixIcon: clearable && value != null
                  ? IconButton(
                      tooltip: 'Clear $label',
                      onPressed: enabled ? () => onChanged(null) : null,
                      icon: const Icon(LucideIcons.x, size: 18),
                    )
                  : const Icon(
                      LucideIcons.clock,
                      size: 18,
                      color: AppColors.muted,
                    ),
            ),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: value ?? initialTime,
            switchToInputEntryModeIcon: const Icon(LucideIcons.keyboard),
            switchToTimerEntryModeIcon: const Icon(LucideIcons.clock),
          );
          if (time != null && context.mounted) onChanged(time);
        },
      ),
    ],
  );
}
