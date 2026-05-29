import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';

class _SupportSnapshot {
  const _SupportSnapshot(this.threads, this.issues);

  final List<SupportThread> threads;
  final List<SupportIssue> issues;
}

class SupportInboxScreen extends StatefulWidget {
  const SupportInboxScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SupportInboxScreen> createState() => _SupportInboxScreenState();
}

class _SupportInboxScreenState extends State<SupportInboxScreen> {
  late Future<_SupportSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_SupportSnapshot> _loadData() async {
    final threads = await widget.appState.fetchSupportThreads();
    final issues = await widget.appState.fetchSupportIssues();
    return _SupportSnapshot(threads, issues);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support inbox'.tr(context))),
      body: RefreshIndicator(
        onRefresh: () => _reload(),
        child: FutureBuilder<_SupportSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Unable to load support data'.tr(context)),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _reload,
                        child: Text('Retry'.tr(context)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const SizedBox.shrink();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                _InboxSectionHeader(
                  title: '${'Threads'.tr(context)} (${data.threads.length})',
                  subtitle: 'Order-linked live chats'.tr(context),
                ),
                const SizedBox(height: 8),
                if (data.threads.isEmpty)
                  _EmptyCard(message: 'No open support threads.'.tr(context))
                else
                  ...data.threads.map((thread) {
                    final lastMessage = thread.messages.isEmpty
                        ? 'No messages yet'.tr(context)
                        : thread.messages.last.text;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.forum_outlined),
                        title: Text('Order ${thread.orderId}'),
                        subtitle: Text(
                          '${thread.messages.length} messages\n$lastMessage',
                        ),
                        trailing: Text('Thread ${thread.id}'),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                _InboxSectionHeader(
                  title: '${'Issues'.tr(context)} (${data.issues.length})',
                  subtitle: 'Escalations and resolution tracking'.tr(context),
                ),
                const SizedBox(height: 8),
                if (data.issues.isEmpty)
                  _EmptyCard(message: 'No active support issues.'.tr(context))
                else
                  ...data.issues.map((issue) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.report_problem_outlined),
                        title: Text('Order ${issue.orderId}'),
                        subtitle: Text(issue.description),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(issue.type.name),
                            Text(issue.status.name),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InboxSectionHeader extends StatelessWidget {
  const _InboxSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text(message)),
    );
  }
}
