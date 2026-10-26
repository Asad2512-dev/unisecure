import 'package:flutter/material.dart';
import '../../../app/modules/guard/views/tabs/guard_visitors_tab.dart';

export '../../../app/modules/guard/views/tabs/guard_visitors_tab.dart';

class VisitorView extends StatelessWidget {
  const VisitorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Visitors')),
      body: const GuardVisitorsTab(),
    );
  }
}
