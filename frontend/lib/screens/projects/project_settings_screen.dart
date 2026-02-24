import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import '../../widgets/loading_widget.dart';

class ProjectSettingsScreen extends ConsumerWidget {
  final String projectId;

  const ProjectSettingsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(title: const Text('Project Settings')),
      body: projectAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (project) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project Info', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _infoRow('Name', project.name),
                    _infoRow('Key', project.key),
                    _infoRow('Description', project.description ?? 'No description'),
                    _infoRow('Visibility', project.visibility),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Members (${project.members?.length ?? 0})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (project.members != null)
                      ...project.members!.map((member) => ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                (member.user?.fullName ?? member.user?.username ?? '?')[0].toUpperCase(),
                              ),
                            ),
                            title: Text(member.user?.displayName ?? 'Unknown'),
                            subtitle: Text(member.user?.email ?? ''),
                            trailing: Chip(
                              label: Text(member.role, style: const TextStyle(fontSize: 11)),
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
