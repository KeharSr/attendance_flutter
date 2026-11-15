import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_theme.dart';

/// Shared list-first layout for requests and their creation forms.
class RequestListPage extends StatefulWidget {
  const RequestListPage({
    required this.request,
    required this.history,
    required this.onLoad,
    required this.addLabel,
    required this.loading,
    super.key,
  });

  final Widget request;
  final Widget history;
  final VoidCallback onLoad;
  final String addLabel;
  final bool loading;

  @override
  State<RequestListPage> createState() => RequestListPageState();
}

class RequestListPageState extends State<RequestListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _adding = false;

  BuildContext? get feedbackContext => _scaffoldKey.currentContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoad();
    });
  }

  void _addRequest() {
    if (_adding || widget.loading) return;
    setState(() => _adding = true);
  }

  void showHistory() {
    if (_adding) setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_adding,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && _adding) showHistory();
    },
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ScaffoldMessenger(
          child: Scaffold(
            key: _scaffoldKey,
            body: _adding
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: TextButton.icon(
                          onPressed: showHistory,
                          icon: const Icon(LucideIcons.arrowLeft, size: 18),
                          label: const Text('Back to requests'),
                        ),
                      ),
                      Expanded(child: widget.request),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 88),
                    child: widget.history,
                  ),
            floatingActionButton: _adding
                ? null
                : FloatingActionButton(
                    heroTag: null,
                    tooltip: widget.addLabel,
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    onPressed: widget.loading ? null : _addRequest,
                    child: const Icon(LucideIcons.plus),
                  ),
          ),
        ),
      ),
    ),
  );
}
