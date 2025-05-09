import 'package:flutter/material.dart';

class TextSettingWidget extends StatelessWidget {
  final String label;
  final String value;
  final String defaultValue;
  final bool isCustomized;
  final bool enabled;
  final String? Function(String? value)? validator;
  final Function(String) onSaved;

  const TextSettingWidget({
    super.key,
    required this.label,
    required this.value,
    required this.defaultValue,
    required this.isCustomized,
    required this.onSaved,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? () => _showEditDialog(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                if (isCustomized)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Custom',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                        )),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: enabled
                    ? theme.textTheme.bodyMedium?.color
                    : theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: value);
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: validator,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Default: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    Expanded(
                        child: Text(defaultValue,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.text = defaultValue;
                onSaved(defaultValue);
                Navigator.of(context).pop();
              },
              child: const Text('RESET TO DEFAULT'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onSaved(controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }
}
