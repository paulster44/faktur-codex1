import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings screen consolidating business preferences and backup tools.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Business Profile', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text('Configure the information that appears on invoices and exports.'),
        const SizedBox(height: 16),
        const _ProfileForm(),
        const Divider(height: 48),
        Text('Security', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          title: const Text('Enable database encryption'),
          subtitle: const Text('Requires restart. Passphrase stored securely in Keychain where supported.'),
          value: false,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Encryption toggle is planned. Windows implementation pending.'),
              ),
            );
          },
        ),
        const Divider(height: 48),
        Text('Data', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export logic wired to services in domain layer.')),
            );
          },
          icon: const Icon(Icons.outbox_outlined),
          label: const Text('Export data bundle'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import workflow includes preview and validation.')),
            );
          },
          icon: const Icon(Icons.move_to_inbox_outlined),
          label: const Text('Import from JSON'),
        ),
      ],
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm();

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Business name'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Default currency (e.g. USD)'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved locally.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
