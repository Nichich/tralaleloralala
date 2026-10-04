import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/brainrot.dart';
import '../providers/brainrot_provider.dart';
import '../widgets/brainrot_grid.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<BrainrotProvider>().refresh();
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _open(Brainrot brainrot) => Navigator.of(context).push(DetailScreen.route(brainrot));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrainrotProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Брейнрот-декс')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Найти брейнрота',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Очистить поиск',
                          icon: const Icon(Icons.close),
                          onPressed: _clearSearch,
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BrainrotProvider provider) {
    switch (provider.status) {
      case LoadStatus.loading:
        return const LoadingView();
      case LoadStatus.error:
        return ErrorView(message: provider.errorMessage, onRetry: provider.retry);
      case LoadStatus.empty:
        return EmptyView(message: 'Брейнротов пока нет', onRetry: provider.retry);
      case LoadStatus.loaded:
        final items = provider.search(_query);
        if (items.isEmpty) {
          return const EmptyView(message: 'Никого не нашли', icon: Icons.search_off);
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: BrainrotGrid(items: items, onTap: _open),
        );
    }
  }
}
